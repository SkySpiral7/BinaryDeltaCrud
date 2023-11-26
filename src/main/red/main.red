Red [
   Title: "All functionality"
]

main: context [
   ;80000000 is highest bit only of 4 bytes
   /local maskDetectUnsignedInt: #{80000000}
   /local maskOperation: to integer! 2#{11100000}
   /local maskOperationSizeFlag: to integer! 2#{00010000}
   /local maskRemaining: to integer! 2#{00001111}
   /local operationAdd: to integer! 2#{00000000}
   /local operationUnchanged: to integer! 2#{00100000}
   /local operationReplace: to integer! 2#{01000000}
   /local operationRemove: to integer! 2#{01100000}
   /local operationReversibleReplace: to integer! 2#{10000000}
   /local operationReversibleRemove: to integer! 2#{10100000}

   applyDelta: func [
      "Modify the inputStream according to the deltaStream and return the outputStream."
      inputStream[binary!] deltaStream[binary!]
   ] [
      outputStream: #{}
      while [not tail? deltaStream] [
         currentDeltaByte: first deltaStream
         deltaStream: next deltaStream

         remainingValue: currentDeltaByte and maskRemaining
         operationSize: remainingValue
         if (currentDeltaByte and maskOperationSizeFlag) == maskOperationSizeFlag [
            if remainingValue > 4 [throw "Limitation: op size size is limited to signed 4 bytes"]
            opSizeBinary: copy/part deltaStream remainingValue
            deltaStream: skip deltaStream remainingValue
            if (remainingValue == 4) and ((opSizeBinary and maskDetectUnsignedInt) == maskDetectUnsignedInt)
               [throw "Limitation: op size size is limited to signed 4 bytes"]
            operationSize: to integer! opSizeBinary
         ]

         switch/default (currentDeltaByte and maskOperation) reduce [
            operationAdd [
               if operationSize == 0 [
                  operationSize: length? deltaStream
                  if operationSize == 0 [throw "Invalid: Add operation must add bytes"]
               ]
               if operationSize > length? deltaStream [throw "Invalid: Not enough bytes remaining in deltaStream"]
               append outputStream copy/part deltaStream operationSize
               deltaStream: skip deltaStream operationSize
            ]
            operationUnchanged [
               either operationSize == 0 [
                  operationSize: length? inputStream
                  if not tail? deltaStream [throw "Invalid: Unaccounted for bytes remaining in deltaStream"]
               ]
               ; op size 0 but empty input is allowed
               [if operationSize > length? inputStream [throw "Invalid: Not enough bytes remaining in inputStream"]]
               append outputStream copy/part inputStream operationSize
               inputStream: skip inputStream operationSize
            ]
            operationReplace [
               if operationSize == 0 [
                  operationSize: length? deltaStream
                  if (length? inputStream) <> operationSize
                     [throw "Invalid: inputStream and deltaStream have different number of remaining bytes"]
                  if operationSize == 0 [throw "Invalid: Replace operation must replace bytes"]
               ]
               if operationSize > length? deltaStream [throw "Invalid: Not enough bytes remaining in deltaStream"]
               if operationSize > length? inputStream [throw "Invalid: Not enough bytes remaining in inputStream"]
               append outputStream copy/part deltaStream operationSize
               deltaStream: skip deltaStream operationSize
               inputStream: skip inputStream operationSize
            ]
            operationRemove [
               if operationSize == 0 [
                  operationSize: length? inputStream
                  if not tail? deltaStream [throw "Invalid: Unaccounted for bytes remaining in deltaStream"]
                  if operationSize == 0 [throw "Invalid: Remove operation must remove bytes"]
               ]
               if operationSize > length? inputStream [throw "Invalid: Not enough bytes remaining in inputStream"]
               inputStream: skip inputStream operationSize
            ]
            operationReversibleReplace [throw "Not yet implemented: op reversible replace"]
            operationReversibleRemove [
               if operationSize == 0 [
                  operationSize: length? deltaStream
                  if (length? inputStream) <> operationSize
                     [throw "Invalid: inputStream and deltaStream have different number of remaining bytes"]
                  if operationSize == 0 [throw "Invalid: Remove operation must remove bytes"]
               ]
               if operationSize > length? deltaStream [throw "Invalid: Not enough bytes remaining in deltaStream"]
               if operationSize > length? inputStream [throw "Invalid: Not enough bytes remaining in inputStream"]
               removedDeltaBytes: copy/part deltaStream operationSize
               deltaStream: skip deltaStream operationSize
               removedInputBytes: copy/part inputStream operationSize
               inputStream: skip inputStream operationSize
               if removedDeltaBytes <> removedInputBytes
                  [throw "Invalid: bytes removed from inputStream didn't match deltaStream"]
            ]
         ] [
            throw "Invalid: operations 6-7 don't exist"
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
   makeDeltaReversible: func [
      "Modify a deltaStream according to beforeStream so that the deltaStream could be reversed."
      beforeStream[binary!] deltaStream[binary!]
   ] [
      throw "Not yet implemented: makeDeltaReversible"
   ]
   undoDelta: func [
      "Modify the inputStream according to the opposite of deltaStream and return the outputStream."
      "Only possible if deltaStream is reversible."
      inputStream[binary!] deltaStream[binary!]
   ] [
      throw "Not yet implemented: undoDelta"
   ]
]
