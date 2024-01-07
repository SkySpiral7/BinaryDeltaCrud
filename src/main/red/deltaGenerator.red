Red [
   Title: "Creating a delta from before and after streams"
]

do %buildDelta.red
do %deltaApplier.red
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
      ;if they are the same then don't analyze them
      if beforeStream == afterStream [
         return buildDelta [
            operation: deltaConstants/operation/unchanged
            operationSize: deltaConstants/remainingBytes
         ]
      ]
      originalBeforeStream: copy beforeStream
      originalAfterStream: copy afterStream
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

      tailUnchangedCount: 0
      ;copy only keeps the current position onward. this prevents overlapping with headUnchangedCount
      ;back tail will put the cursor on the last element
      beforeStream: back tail copy beforeStream
      afterStream: back tail copy afterStream
      ;they can't both reach head since I know there's at least 1 byte different between them
      while [(not head? beforeStream) and (not head? afterStream) and (beforeStream/1 == afterStream/1)] [
         tailUnchangedCount: tailUnchangedCount + 1
         beforeStream: back beforeStream
         afterStream: back afterStream
      ]
      ;resets them back to where headUnchangedCount ended
      beforeStream: head beforeStream
      afterStream: head afterStream
      if tailUnchangedCount > 0 [
         ;remove the unchanged bytes from the end of them
         ;TODO: make sure no bug with them becoming empty
         beforeStream: copy/part beforeStream ((length? beforeStream) - tailUnchangedCount)
         afterStream: copy/part afterStream ((length? afterStream) - tailUnchangedCount)
      ]
      ;the streams now only have the middle part that's different (unchanged head and tail cut off)

      if (not tail? beforeStream) and (not tail? afterStream) [
         ;replace as much as possible. will be the rest of at least 1 stream
         replaceLength: min (length? beforeStream) (length? afterStream)
         append deltaStream (
            buildDelta [
               operation: deltaConstants/operation/replace
               operationSize: replaceLength
               newData: copy/part afterStream replaceLength
            ]
         )
         ;skip is fine since the streams won't go back anymore
         beforeStream: skip beforeStream replaceLength
         afterStream: skip afterStream replaceLength
      ]
      if (not tail? beforeStream) and (not tail? afterStream) [throw "Bug in generateDelta: 1 stream should be tail"]
      ;1 stream is tail, the other might have extra bytes

      if not tail? beforeStream [
         ;TODO: if tailUnchangedCount == 0 then op remaining
         append deltaStream (
            buildDelta [
               operation: deltaConstants/operation/remove
               operationSize: length? beforeStream
            ]
         )
      ]
      if not tail? afterStream [
         append deltaStream (
            buildDelta [
               operation: deltaConstants/operation/add
               operationSize: length? afterStream
               newData: afterStream
            ]
         )
      ]

      if tailUnchangedCount > 0 [
         append deltaStream (
            buildDelta [
               operation: deltaConstants/operation/unchanged
               operationSize: deltaConstants/remainingBytes
            ]
         )
      ]

      if (deltaApplier/applyDelta originalBeforeStream deltaStream) <> originalAfterStream
         [throw "Bug in generateDelta: deltaStream doesn't correctly describe changes"]
      return deltaStream
   ]
]
