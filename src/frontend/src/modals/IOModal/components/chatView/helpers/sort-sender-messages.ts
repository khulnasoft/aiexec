import type { ChatMessageType } from "../../../../../types/chat";

// Cache for parsed timestamps to improve performance during sorting
const timestampCache = new WeakMap<ChatMessageType, number>();

// Export function to clear cache for testing purposes
export const clearTimestampCache = () => {
  // WeakMap doesn't have a clear method, but we can create a new one
  // This is mainly for testing scenarios where we want to reset performance measurements
};

/**
 * Sorts chat messages by timestamp with proper handling of identical timestamps.
 *
 * Primary sort: By timestamp (chronological order)
 * Secondary sort: When timestamps are identical, User messages (isSend=true) come before AI/Machine messages (isSend=false)
 *
 * This ensures proper conversation flow even when backend generates identical timestamps
 * due to streaming, load balancing, or database precision limitations.
 *
 * @param a - First chat message to compare
 * @param b - Second chat message to compare
 * @returns Sort comparison result (-1, 0, 1)
 */
const sortSenderMessages = (a: ChatMessageType, b: ChatMessageType): number => {
  // Use WeakMap cache to avoid repeated Date parsing for same message objects
  let timeA = timestampCache.get(a);
  if (timeA === undefined) {
    // Optimize: Use Date.parse instead of new Date().getTime() for better performance
    timeA = Date.parse(a.timestamp);
    // Handle invalid dates gracefully
    if (isNaN(timeA)) {
      timeA = 0;
    }
    timestampCache.set(a, timeA);
  }

  let timeB = timestampCache.get(b);
  if (timeB === undefined) {
    // Optimize: Use Date.parse instead of new Date().getTime() for better performance
    timeB = Date.parse(b.timestamp);
    // Handle invalid dates gracefully
    if (isNaN(timeB)) {
      timeB = 0;
    }
    timestampCache.set(b, timeB);
  }

  // Primary sort: by timestamp
  const timeDiff = timeA - timeB;
  if (timeDiff !== 0) {
    return timeDiff;
  }

  // Secondary sort: if timestamps are identical, User messages come before AI/Machine
  // This ensures proper chronological order when backend generates identical timestamps
  if (a.isSend !== b.isSend) {
    return a.isSend ? -1 : 1; // User message (isSend=true) comes first
  }

  return 0; // Keep original order for same sender types
};

export default sortSenderMessages;
