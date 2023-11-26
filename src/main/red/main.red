Red [
   Title: "All functionality"
]

main: context [
   /local mask: context [
      ;highest bit of 4 bytes (int size)
      detectUnsignedInt: append 2#{10000000} #{000000}
      reversibleFlag: to integer! 2#{10000000}
      operation: to integer! 2#{11100000}
      operationSizeFlag: to integer! 2#{00010000}
      remaining: to integer! 2#{00001111}
   ]
   /local operation: context [
      add: to integer! 2#{00000000}
      unchanged: to integer! 2#{00100000}
      replace: to integer! 2#{01000000}
      remove: to integer! 2#{01100000}
      reversibleReplace: to integer! 2#{11000000}
      reversibleRemove: to integer! 2#{11100000}
   ]

   applyDelta: func [
      "Modify the inputStream according to the deltaStream and return the outputStream."
      inputStream[binary!] deltaStream[binary!]
   ] [
      outputStream: #{}
      while [not tail? deltaStream] [
         currentDeltaByte: first deltaStream
         deltaStream: next deltaStream

         remainingValue: currentDeltaByte and mask/remaining
         operationSize: remainingValue
         if (currentDeltaByte and mask/operationSizeFlag) == mask/operationSizeFlag [
            if remainingValue > 4 [throw "Limitation: op size size is limited to signed 4 bytes"]
            opSizeBinary: copy/part deltaStream remainingValue
            deltaStream: skip deltaStream remainingValue
            if (remainingValue == 4) and ((opSizeBinary and mask/detectUnsignedInt) == mask/detectUnsignedInt)
               [throw "Limitation: op size size is limited to signed 4 bytes"]
            operationSize: to integer! opSizeBinary
         ]

         switch/default (currentDeltaByte and mask/operation) reduce [
            operation/add [
               either operationSize == 0 [
                  operationSize: length? deltaStream
                  if operationSize == 0 [throw "Invalid: Add operation must add bytes"]
               ]
               [if operationSize > length? deltaStream [throw "Invalid: Not enough bytes remaining in deltaStream"]]
               append outputStream copy/part deltaStream operationSize
               deltaStream: skip deltaStream operationSize
            ]
            operation/unchanged [
               either operationSize == 0 [
                  operationSize: length? inputStream
                  if not tail? deltaStream [throw "Invalid: Unaccounted for bytes remaining in deltaStream"]
                  ;op size 0 but empty input is allowed
               ]
               [if operationSize > length? inputStream [throw "Invalid: Not enough bytes remaining in inputStream"]]
               append outputStream copy/part inputStream operationSize
               inputStream: skip inputStream operationSize
            ]
            operation/replace [
               either operationSize == 0 [
                  operationSize: length? deltaStream
                  if operationSize == 0 [throw "Invalid: Replace operation must replace bytes"]
                  if (length? inputStream) <> operationSize
                     [throw "Invalid: inputStream and deltaStream have different number of remaining bytes"]
               ] [
                  if operationSize > length? deltaStream [throw "Invalid: Not enough bytes remaining in deltaStream"]
                  if operationSize > length? inputStream [throw "Invalid: Not enough bytes remaining in inputStream"]
               ]
               append outputStream copy/part deltaStream operationSize
               deltaStream: skip deltaStream operationSize
               inputStream: skip inputStream operationSize
            ]
            operation/remove [
               either operationSize == 0 [
                  operationSize: length? inputStream
                  if not tail? deltaStream [throw "Invalid: Unaccounted for bytes remaining in deltaStream"]
                  if operationSize == 0 [throw "Invalid: Remove operation must remove bytes"]
               ]
               [if operationSize > length? inputStream [throw "Invalid: Not enough bytes remaining in inputStream"]]
               inputStream: skip inputStream operationSize
            ]
            operation/reversibleReplace [
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
               removedDeltaBytes: copy/part deltaStream operationSize
               deltaStream: skip deltaStream operationSize
               removedInputBytes: copy/part inputStream operationSize
               inputStream: skip inputStream operationSize
               if removedDeltaBytes <> removedInputBytes
                  [throw "Invalid: bytes removed from inputStream didn't match deltaStream"]
               append outputStream copy/part deltaStream operationSize
               deltaStream: skip deltaStream operationSize
            ]
            operation/reversibleRemove [
               either operationSize == 0 [
                  operationSize: length? deltaStream
                  if operationSize == 0 [throw "Invalid: Remove operation must remove bytes"]
                  if (length? inputStream) <> operationSize
                     [throw "Invalid: inputStream and deltaStream have different number of remaining bytes"]
               ] [
                  if operationSize > length? deltaStream [throw "Invalid: Not enough bytes remaining in deltaStream"]
                  if operationSize > length? inputStream [throw "Invalid: Not enough bytes remaining in inputStream"]
               ]
               removedDeltaBytes: copy/part deltaStream operationSize
               deltaStream: skip deltaStream operationSize
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
      ;TODO: figure out how to DRY: object that handles finite state for delta and object to hold the 3
      outputStream: #{}
      while [not tail? deltaStream] [
         currentDeltaByte: first deltaStream
         deltaStream: next deltaStream

         remainingValue: currentDeltaByte and mask/remaining
         operationSize: remainingValue
         opSizeBinary: #{}
         if (currentDeltaByte and mask/operationSizeFlag) == mask/operationSizeFlag [
            if remainingValue > 4 [throw "Limitation: op size size is limited to signed 4 bytes"]
            opSizeBinary: copy/part deltaStream remainingValue
            deltaStream: skip deltaStream remainingValue
            if (remainingValue == 4) and ((opSizeBinary and mask/detectUnsignedInt) == mask/detectUnsignedInt)
               [throw "Limitation: op size size is limited to signed 4 bytes"]
            operationSize: to integer! opSizeBinary
         ]

         switch/default (currentDeltaByte and mask/operation) reduce [
            operation/add [
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
            operation/unchanged [
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
            operation/replace [
               either operationSize == 0 [
                  operationSize: length? deltaStream
                  if operationSize == 0 [throw "Invalid: Replace operation must replace bytes"]
                  if (length? inputStream) <> operationSize
                     [throw "Invalid: inputStream and deltaStream have different number of remaining bytes"]
               ] [
                  if operationSize > length? deltaStream [throw "Invalid: Not enough bytes remaining in deltaStream"]
                  if operationSize > length? inputStream [throw "Invalid: Not enough bytes remaining in inputStream"]
               ]
               append outputStream (currentDeltaByte or mask/reversibleFlag)
               append outputStream opSizeBinary
               append outputStream copy/part inputStream operationSize
               append outputStream copy/part deltaStream operationSize
               deltaStream: skip deltaStream operationSize
               inputStream: skip inputStream operationSize
            ]
            operation/remove [
               either operationSize == 0 [
                  operationSize: length? inputStream
                  if not tail? deltaStream [throw "Invalid: Unaccounted for bytes remaining in deltaStream"]
                  if operationSize == 0 [throw "Invalid: Remove operation must remove bytes"]
               ]
               [if operationSize > length? inputStream [throw "Invalid: Not enough bytes remaining in inputStream"]]
               append outputStream (currentDeltaByte or mask/reversibleFlag)
               append outputStream opSizeBinary
               append outputStream copy/part inputStream operationSize
               inputStream: skip inputStream operationSize
            ]
            operation/reversibleReplace [
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
            operation/reversibleRemove [
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
