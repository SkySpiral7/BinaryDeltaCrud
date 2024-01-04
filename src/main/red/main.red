Red [
   Title: "All functionality"
]

#include %deltaIterator.red

main: context [
   applyDelta: func [
      {Modify the beforeStream according to the deltaStream and return the afterStream.
      @param beforeStream isn't mutated instead see return value
      @returns afterStream}
      beforeStream[binary!] deltaStreamParam[binary!]
   ] [
      afterStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext beforeStream
         switch deltaItr/operationType reduce [
            deltaItr/operation/add [
               append afterStream deltaItr/newData
            ]
            deltaItr/operation/unchanged [
               append afterStream copy/part beforeStream deltaItr/operationSize
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/replace [
               append afterStream deltaItr/newData
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/remove [
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/reversibleReplace [
               append afterStream deltaItr/newData
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/reversibleRemove [
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
         ]
      ]
      return afterStream
   ]
   generateDelta: func [
      {Generate a delta that describes the changes needed for beforeStream to become afterStream.
      Note that this problem is unsolvable (TSP).
      @param all of both streams will be looked at. They are expected to start at head
      @returns deltaStream}
      beforeStream[binary!] afterStream[binary!]
   ] [
      beforeStream: head beforeStream
      afterStream: head afterStream
      ;unchanged remaining (empty or not). defensive copy
      ;TODO: use constants
      if beforeStream == afterStream [return copy 2#{00100000}]
      deltaStream: copy #{}

      headUnchangedCount: 0
      while [(not tail? beforeStream) and (not tail? afterStream) and (beforeStream/1 == afterStream/1)] [
         headUnchangedCount: headUnchangedCount + 1
         beforeStream: next beforeStream
         afterStream: next afterStream
      ]
      if headUnchangedCount > 0 [
         ;unchanged op size size 4
         deltaStream: append deltaStream 2#{00110100}
         ;TODO: inefficent packing. the other delta func should also compact
         ;a massage func makes sense to have: it should also shrink op sizes to fit
         deltaStream: append deltaStream to binary! headUnchangedCount
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
         ;replace op size size 4
         deltaStream: append deltaStream 2#{01010100}
         ;replace as much as possible. will be the rest of at least 1 stream
         replaceLength: min (length? beforeStream) (length? afterStream)
         deltaStream: append deltaStream to binary! replaceLength
         deltaStream: append deltaStream copy/part afterStream replaceLength
         beforeStream: skip beforeStream replaceLength
         afterStream: skip afterStream replaceLength
      ]

      if (tail? beforeStream) and (tail? afterStream) [
         ;unchanged remaining (done)
         deltaStream: append deltaStream 2#{00100000}
         return deltaStream
      ]
      if tail? beforeStream [
         ;add remaining
         deltaStream: append deltaStream 2#{00000000}
         deltaStream: append deltaStream afterStream
         return deltaStream
      ]
      if not tail? afterStream [throw "Bug in generateDelta: afterStream should be at tail at bottom"]
      ;remove remaining
      deltaStream: append deltaStream 2#{01100000}
      return deltaStream
   ]
   makeDeltaNonReversible: func [
      {Modify a deltaStream so that the deltaStream it is no longer reversible (and thus more compact).
      The reversible information is stripped without validation and thus this function doesn't require beforeStream.
      @param deltaStreamParam isn't mutated instead see return value
      @returns the new deltaStream}
      deltaStreamParam[binary!]
   ] [
      nonReversibleDeltaStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext none
         switch deltaItr/operationType reduce [
            deltaItr/operation/add [
               append nonReversibleDeltaStream deltaItr/operationAndData
            ]
            deltaItr/operation/unchanged [
               append nonReversibleDeltaStream deltaItr/operationBinary
            ]
            deltaItr/operation/replace [
               append nonReversibleDeltaStream deltaItr/operationAndData
            ]
            deltaItr/operation/remove [
               append nonReversibleDeltaStream deltaItr/operationBinary
            ]
            deltaItr/operation/reversibleReplace [
               deltaItr/clearReversibleFlag
               append nonReversibleDeltaStream deltaItr/operationBinary
               ;ignore deltaItr/oldData
               append nonReversibleDeltaStream deltaItr/newData
            ]
            deltaItr/operation/reversibleRemove [
               deltaItr/clearReversibleFlag
               append nonReversibleDeltaStream deltaItr/operationBinary
               ;ignore deltaItr/oldData
            ]
         ]
      ]
      return nonReversibleDeltaStream
   ]
   makeDeltaReversible: func [
      {Modify a deltaStream according to beforeStream so that the deltaStream could be reversed
      (and thus less compact).
      @param deltaStreamParam isn't mutated instead see return value
      @returns the new deltaStream}
      beforeStream[binary!] deltaStreamParam[binary!]
   ] [
      reversibleDeltaStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext beforeStream
         switch deltaItr/operationType reduce [
            deltaItr/operation/add [
               append reversibleDeltaStream deltaItr/operationAndData
            ]
            deltaItr/operation/unchanged [
               append reversibleDeltaStream deltaItr/operationBinary
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/replace [
               deltaItr/setReversibleFlag
               append reversibleDeltaStream deltaItr/operationBinary
               append reversibleDeltaStream copy/part beforeStream deltaItr/operationSize
               append reversibleDeltaStream deltaItr/newData
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/remove [
               deltaItr/setReversibleFlag
               append reversibleDeltaStream deltaItr/operationBinary
               append reversibleDeltaStream copy/part beforeStream deltaItr/operationSize
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/reversibleReplace [
               append reversibleDeltaStream deltaItr/operationAndData
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/reversibleRemove [
               append reversibleDeltaStream deltaItr/operationAndData
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
         ]
      ]
      return reversibleDeltaStream
   ]
   undoDelta: func [
      {Modify the afterStream according to the opposite of deltaStream and return the beforeStream.
      Only possible if deltaStream is reversible.
      @param afterStream isn't mutated instead see return value
      @returns beforeStream}
      afterStream[binary!] deltaStreamParam[binary!]
   ] [
      undoDeltaStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext none  ;don't run normal validation yet since we have an afterStream instead of a beforeStream
         switch deltaItr/operationType reduce [
            deltaItr/operation/add [
               deltaItr/setOperation deltaItr/operation/reversibleRemove
               append undoDeltaStream deltaItr/operationBinary
               append undoDeltaStream deltaItr/newData
            ]
            deltaItr/operation/unchanged [
               append undoDeltaStream deltaItr/operationBinary
            ]
            deltaItr/operation/replace [
               throw "Invalid: deltaStream isn't reversible"
            ]
            deltaItr/operation/remove [
               throw "Invalid: deltaStream isn't reversible"
            ]
            deltaItr/operation/reversibleReplace [
               ;don't need to edit operationBinary. just flip the data order
               append undoDeltaStream deltaItr/operationBinary
               append undoDeltaStream deltaItr/newData
               append undoDeltaStream deltaItr/oldData
            ]
            deltaItr/operation/reversibleRemove [
               deltaItr/setOperation deltaItr/operation/add
               append undoDeltaStream deltaItr/operationBinary
               append undoDeltaStream deltaItr/oldData
            ]
         ]
      ]
      ;this validates afterStream
      exception: catch [return applyDelta afterStream undoDeltaStream]
      ;in case red throws something
      if string! <> type? exception [throw exception]
      ;edit error message to match this undoDelta
      exception: replace/case copy exception "beforeStream" "afterStream"
      throw exception
   ]
]
