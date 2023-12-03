Red [
   Title: "All functionality"
]

#include %deltaIterator.red

main: context [
   applyDelta: func [
      "Modify the inputStream according to the deltaStream and return the outputStream."
      inputStream[binary!] deltaStreamParam[binary!]
   ] [
      outputStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext
         validateInputStream inputStream deltaItr
         switch deltaItr/operationType reduce [
            deltaItr/operation/add [
               append outputStream deltaItr/newData
            ]
            deltaItr/operation/unchanged [
               append outputStream copy/part inputStream deltaItr/operationSize
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/replace [
               append outputStream deltaItr/newData
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/remove [
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/reversibleReplace [
               inputStream: skip inputStream deltaItr/operationSize
               append outputStream deltaItr/newData
            ]
            deltaItr/operation/reversibleRemove [
               inputStream: skip inputStream deltaItr/operationSize
            ]
         ]
      ]
      return outputStream
   ]
   generateDelta: func [
      "Generate a delta that describes the changes needed for beforeStream to become afterStream."
      "Note that this problem is unsolvable (TSP)."
      beforeStream[binary!] afterStream[binary!]
   ] [
      throw "Not yet implemented: generateDelta"
   ]
   makeDeltaNonReversible: func [
      "Modify a deltaStream so that the deltaStream it is no longer reversible (and thus more compact)."
      "Returns the new deltaStream."
      deltaStream[binary!]
   ] [
      throw "Not yet implemented: makeDeltaNonReversible"
   ]
   makeDeltaReversible: func [
      "Modify a deltaStream according to beforeStream so that the deltaStream could be reversed"
      "(and thus less compact)."
      "Returns the new deltaStream."
      inputStream[binary!] deltaStreamParam[binary!]
   ] [
      outputStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext
         validateInputStream inputStream deltaItr
         switch deltaItr/operationType reduce [
            deltaItr/operation/add [
               append outputStream deltaItr/operationAndData
            ]
            deltaItr/operation/unchanged [
               append outputStream deltaItr/operationBinary
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/replace [
               append outputStream (deltaItr/operationBinary or deltaItr/mask/reversibleFlag)
               append outputStream copy/part inputStream deltaItr/operationSize
               append outputStream deltaItr/newData
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/remove [
               append outputStream (deltaItr/operationBinary or deltaItr/mask/reversibleFlag)
               append outputStream copy/part inputStream deltaItr/operationSize
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/reversibleReplace [
               inputStream: skip inputStream deltaItr/operationSize
               append outputStream deltaItr/operationAndData
            ]
            deltaItr/operation/reversibleRemove [
               inputStream: skip inputStream deltaItr/operationSize
               append outputStream deltaItr/operationAndData
            ]
         ]
      ]
      return outputStream
   ]
   undoDelta: func [
      "Modify the inputStream according to the opposite of deltaStream and return the outputStream."
      "Only possible if deltaStream is reversible."
      inputStream[binary!] deltaStream[binary!]
   ] [
      throw "Not yet implemented: undoDelta"
   ]
   validateInputStream: func [
      "Validate inputStream according to deltaItr's current position."
      "@param inputStream not modified"
      "@param deltaItr is a deltaIterator. if deltaItr/operationSize = 0 then it will be set to length? inputStream"
      inputStream[binary!] deltaItr[object!]
   ] [
      switch deltaItr/operationType reduce [
         deltaItr/operation/add [
            ;do nothing (always valid)
         ]
         deltaItr/operation/unchanged [
            either deltaItr/operationSize == 0 [
               deltaItr/operationSize: length? inputStream
               ;op size 0 but empty input is allowed
            ] [
               if deltaItr/operationSize > length? inputStream
                  [throw "Invalid: Not enough bytes remaining in inputStream"]
            ]
         ]
         deltaItr/operation/replace [
            if deltaItr/operationSize > length? inputStream
               [throw "Invalid: Not enough bytes remaining in inputStream"]
         ]
         deltaItr/operation/remove [
            either deltaItr/operationSize == 0 [
               deltaItr/operationSize: length? inputStream
               if deltaItr/operationSize == 0 [throw "Invalid: Remove operation must remove bytes"]
            ] [
               if deltaItr/operationSize > length? inputStream
                  [throw "Invalid: Not enough bytes remaining in inputStream"]
            ]
         ]
         deltaItr/operation/reversibleReplace [
            if deltaItr/operationSize > length? inputStream
               [throw "Invalid: Not enough bytes remaining in inputStream"]
            removedInputBytes: copy/part inputStream deltaItr/operationSize
            if deltaItr/oldData <> removedInputBytes
               [throw "Invalid: bytes removed from inputStream didn't match deltaStream"]
         ]
         deltaItr/operation/reversibleRemove [
            if deltaItr/operationSize > length? inputStream
               [throw "Invalid: Not enough bytes remaining in inputStream"]
            removedInputBytes: copy/part inputStream deltaItr/operationSize
            if deltaItr/oldData <> removedInputBytes
               [throw "Invalid: bytes removed from inputStream didn't match deltaStream"]
         ]
      ]
      if deltaItr/operationType <> deltaItr/operation/add [inputStream: skip inputStream deltaItr/operationSize]
      if (not deltaItr/hasNext?) and (not tail? inputStream)
         [throw "Invalid: Unaccounted for bytes remaining in inputStream"]
   ]
]
