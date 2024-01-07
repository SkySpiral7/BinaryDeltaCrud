Red [
   Title: "Creating a delta from before and after streams"
]

do %buildDelta.red
do %deltaConstants.red

deltaGenerator: context [
   generateDelta: function [
      {Generate a delta that describes the changes needed for beforeStream to become afterStream.
      Note that this problem is unsolvable (TSP).
      @param all of both streams will be looked at. They are expected to start at head
      @returns deltaStream}
      beforeStream[binary!] afterStream[binary!]
      return: [binary!]
   ] [
      beforeStream: head beforeStream
      afterStream: head afterStream
      ;unchanged remaining (empty or not)
      if beforeStream == afterStream [
         return buildDelta [
            operation: deltaConstants/operation/unchanged
            operationSize: deltaConstants/remainingBytes
         ]
      ]
      deltaStream: copy #{}

      headUnchangedCount: 0
      while [(not tail? beforeStream) and (not tail? afterStream) and (beforeStream/1 == afterStream/1)] [
         headUnchangedCount: headUnchangedCount + 1
         beforeStream: next beforeStream
         afterStream: next afterStream
      ]
      if headUnchangedCount > 0 [
         append deltaStream (
            buildDelta [
               operation: deltaConstants/operation/unchanged
               operationSize: headUnchangedCount
            ]
         )
      ]

      ;TODO: to avoid overlap with headUnchangedCount I'd have to copy what remains
      comment {
      tailUnchangedCount: 0
      beforeStream: last beforeStream
      afterStream: last afterStream
      while [(not tail? beforeStream) and (not tail? afterStream) and (beforeStream/1 == afterStream/1)] [
         headUnchangedCount: headUnchangedCount + 1
         beforeStream: next beforeStream
         afterStream: next afterStream
      ]
      }

      if (not tail? beforeStream) and (not tail? afterStream) [
         ;replace as much as possible. will be the rest of at least 1 stream
         replaceLength: min (length? beforeStream) (length? afterStream)
         append deltaStream (
            buildDelta [
               operation: deltaConstants/operation/replace
               operationSize: replaceLength
            ]
         )
         append deltaStream copy/part afterStream replaceLength
         beforeStream: skip beforeStream replaceLength
         afterStream: skip afterStream replaceLength
      ]

      if (tail? beforeStream) and (tail? afterStream) [
         ;unchanged remaining (done)
         append deltaStream (
            buildDelta [
               operation: deltaConstants/operation/unchanged
               operationSize: deltaConstants/remainingBytes
            ]
         )
         return deltaStream
      ]
      if tail? beforeStream [
         ;add remaining
         append deltaStream (
            buildDelta [
               operation: deltaConstants/operation/add
               operationSize: deltaConstants/remainingBytes
            ]
         )
         append deltaStream afterStream
         return deltaStream
      ]
      if not tail? afterStream [throw "Bug in generateDelta: afterStream should be at tail at bottom"]
      ;remove remaining
      append deltaStream (
         buildDelta [
            operation: deltaConstants/operation/remove
            operationSize: deltaConstants/remainingBytes
         ]
      )
      return deltaStream
   ]
]
