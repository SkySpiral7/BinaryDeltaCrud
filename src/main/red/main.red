Red [
   Title: "All functionality"
]

#include %deltaIterator.red

main: context [
   applyDelta: func [
      "Modify the inputStream according to the deltaStream and return the outputStream."
      inputStream[binary!] deltaStreamParam[binary!]
   ] [
      outputStream: #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext
         switch deltaItr/operationType reduce [
            deltaItr/operation/add [
               append outputStream deltaItr/newData
            ]
            deltaItr/operation/unchanged [
               either deltaItr/operationSize == 0 [
                  deltaItr/operationSize: length? inputStream
                  ;op size 0 but empty input is allowed
               ] [
                  if deltaItr/operationSize > length? inputStream
                     [throw "Invalid: Not enough bytes remaining in inputStream"]
               ]
               append outputStream copy/part inputStream deltaItr/operationSize
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/replace [
               if deltaItr/operationSize > length? inputStream
                  [throw "Invalid: Not enough bytes remaining in inputStream"]
               append outputStream deltaItr/newData
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/remove [
               either deltaItr/operationSize == 0 [
                  deltaItr/operationSize: length? inputStream
                  if deltaItr/operationSize == 0 [throw "Invalid: Remove operation must remove bytes"]
               ] [
                  if deltaItr/operationSize > length? inputStream
                     [throw "Invalid: Not enough bytes remaining in inputStream"]
               ]
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/reversibleReplace [
               if deltaItr/operationSize > length? inputStream
                  [throw "Invalid: Not enough bytes remaining in inputStream"]
               removedInputBytes: copy/part inputStream deltaItr/operationSize
               inputStream: skip inputStream deltaItr/operationSize
               if deltaItr/oldData <> removedInputBytes
                  [throw "Invalid: bytes removed from inputStream didn't match deltaStream"]
               append outputStream deltaItr/newData
            ]
            deltaItr/operation/reversibleRemove [
               if deltaItr/operationSize > length? inputStream
                  [throw "Invalid: Not enough bytes remaining in inputStream"]
               removedInputBytes: copy/part inputStream deltaItr/operationSize
               inputStream: skip inputStream deltaItr/operationSize
               if deltaItr/oldData <> removedInputBytes
                  [throw "Invalid: bytes removed from inputStream didn't match deltaStream"]
            ]
         ]
      ]
      if not tail? inputStream [throw "Invalid: Unaccounted for bytes remaining in inputStream"]
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
      "Modify a deltaStream according to beforeStream so that the deltaStream could be reversed (and thus less compact)."
      "Returns the new deltaStream."
      inputStream[binary!] deltaStream[binary!]
   ] [
      ;TODO: use deltaIterator here too
      outputStream: #{}
      while [not tail? deltaStream] [
         currentDeltaByte: first deltaStream
         deltaStream: next deltaStream

         remainingValue: currentDeltaByte and deltaItr/mask/remaining
         operationSize: remainingValue
         opSizeBinary: #{}
         if (currentDeltaByte and deltaItr/mask/operationSizeFlag) == deltaItr/mask/operationSizeFlag [
            if remainingValue > 4 [throw "Limitation: op size size is limited to signed 4 bytes"]
            opSizeBinary: copy/part deltaStream remainingValue
            deltaStream: skip deltaStream remainingValue
            if (remainingValue == 4) and ((opSizeBinary and deltaItr/mask/detectUnsignedInt) == deltaItr/mask/detectUnsignedInt)
               [throw "Limitation: op size size is limited to signed 4 bytes"]
            operationSize: to integer! opSizeBinary
         ]

         switch/default (currentDeltaByte and deltaItr/mask/operation) reduce [
            deltaItr/operation/add [
               either operationSize == 0 [
                  operationSize: length? deltaStream
                  if operationSize == 0 [throw "Invalid: Add operation must add bytes"]
               ]
               [if operationSize > length? deltaStream [throw "Invalid: Not enough bytes remaining in deltaStream"]]
               append outputStream currentDeltaByte
               append outputStream opSizeBinary
               append outputStream copy/part deltaStream operationSize
               deltaStream: skip deltaStream operationSize
            ]
            deltaItr/operation/unchanged [
               either operationSize == 0 [
                  operationSize: length? inputStream
                  if not tail? deltaStream [throw "Invalid: Unaccounted for bytes remaining in deltaStream"]
                  ;op size 0 but empty input is allowed
               ]
               [if operationSize > length? inputStream [throw "Invalid: Not enough bytes remaining in inputStream"]]
               append outputStream currentDeltaByte
               append outputStream opSizeBinary
               inputStream: skip inputStream operationSize
            ]
            deltaItr/operation/replace [
               either operationSize == 0 [
                  operationSize: length? deltaStream
                  if operationSize == 0 [throw "Invalid: Replace operation must replace bytes"]
                  if (length? inputStream) <> operationSize
                     [throw "Invalid: inputStream and deltaStream have different number of remaining bytes"]
               ] [
                  if operationSize > length? deltaStream [throw "Invalid: Not enough bytes remaining in deltaStream"]
                  if operationSize > length? inputStream [throw "Invalid: Not enough bytes remaining in inputStream"]
               ]
               append outputStream (currentDeltaByte or deltaItr/mask/reversibleFlag)
               append outputStream opSizeBinary
               append outputStream copy/part inputStream operationSize
               append outputStream copy/part deltaStream operationSize
               deltaStream: skip deltaStream operationSize
               inputStream: skip inputStream operationSize
            ]
            deltaItr/operation/remove [
               either operationSize == 0 [
                  operationSize: length? inputStream
                  if not tail? deltaStream [throw "Invalid: Unaccounted for bytes remaining in deltaStream"]
                  if operationSize == 0 [throw "Invalid: Remove operation must remove bytes"]
               ]
               [if operationSize > length? inputStream [throw "Invalid: Not enough bytes remaining in inputStream"]]
               append outputStream (currentDeltaByte or deltaItr/mask/reversibleFlag)
               append outputStream opSizeBinary
               append outputStream copy/part inputStream operationSize
               inputStream: skip inputStream operationSize
            ]
            deltaItr/operation/reversibleReplace [
               either operationSize == 0 [
                  operationSize: length? inputStream
                  if operationSize == 0 [throw "Invalid: Replace operation must replace bytes"]
                  if (length? deltaStream) <> (operationSize * 2)
                     [throw "Invalid: deltaStream must have twice the remaining bytes as inputStream"]
               ] [
                  if (operationSize * 2) > length? deltaStream
                     [throw "Invalid: Not enough bytes remaining in deltaStream"]
                  if operationSize > length? inputStream [throw "Invalid: Not enough bytes remaining in inputStream"]
               ]
               append outputStream currentDeltaByte
               append outputStream opSizeBinary
               removedDeltaBytes: copy/part deltaStream operationSize
               deltaStream: skip deltaStream operationSize
               append outputStream removedDeltaBytes
               removedInputBytes: copy/part inputStream operationSize
               inputStream: skip inputStream operationSize
               if removedDeltaBytes <> removedInputBytes
                  [throw "Invalid: bytes removed from inputStream didn't match deltaStream"]
               append outputStream copy/part deltaStream operationSize
               deltaStream: skip deltaStream operationSize
            ]
            deltaItr/operation/reversibleRemove [
               either operationSize == 0 [
                  operationSize: length? deltaStream
                  if operationSize == 0 [throw "Invalid: Remove operation must remove bytes"]
                  if (length? inputStream) <> operationSize
                     [throw "Invalid: inputStream and deltaStream have different number of remaining bytes"]
               ] [
                  if operationSize > length? deltaStream [throw "Invalid: Not enough bytes remaining in deltaStream"]
                  if operationSize > length? inputStream [throw "Invalid: Not enough bytes remaining in inputStream"]
               ]
               append outputStream currentDeltaByte
               append outputStream opSizeBinary
               removedDeltaBytes: copy/part deltaStream operationSize
               deltaStream: skip deltaStream operationSize
               append outputStream removedDeltaBytes
               removedInputBytes: copy/part inputStream operationSize
               inputStream: skip inputStream operationSize
               if removedDeltaBytes <> removedInputBytes
                  [throw "Invalid: bytes removed from inputStream didn't match deltaStream"]
            ]
         ] [
            throw "Invalid: operations 4-5 don't exist"
         ]
      ]
      if not tail? inputStream [throw "Invalid: Unaccounted for bytes remaining in inputStream"]
      return outputStream
   ]
   undoDelta: func [
      "Modify the inputStream according to the opposite of deltaStream and return the outputStream."
      "Only possible if deltaStream is reversible."
      inputStream[binary!] deltaStream[binary!]
   ] [
      throw "Not yet implemented: undoDelta"
   ]
]
