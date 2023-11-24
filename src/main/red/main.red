Red [
   Title: "All functionality"
]

main: context [
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
            if remainingValue > 4 [throw "Not yet implemented: op size size is limited to signed 4 bytes"]
            opSizeBinary: copy/part deltaStream remainingValue
            deltaStream: skip deltaStream remainingValue
            ;80000000 is highest bit only of 4 bytes
            if (remainingValue == 4) and ((opSizeBinary and #{80000000}) == #{80000000}) [throw "Not yet implemented: op size size is limited to signed 4 bytes"]
            operationSize: to integer! opSizeBinary
         ]

         switch/default (currentDeltaByte and maskOperation) reduce [
            operationAdd [
               if operationSize == 0 [
                  operationSize: length? deltaStream
               ]
               if (operationSize == 0) or (operationSize > length? deltaStream) [throw "Invalid: Not enough bytes remaining in deltaStream"]
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
            operationReplace [throw "Not yet implemented: op replace"]
            operationRemove [
               if operationSize == 0 [
                  operationSize: length? inputStream
                  if not tail? deltaStream [throw "Invalid: Unaccounted for bytes remaining in deltaStream"]
               ]
               if (operationSize == 0) or (operationSize > length? inputStream) [throw "Invalid: Not enough bytes remaining in inputStream"]
               inputStream: skip inputStream operationSize
            ]
            operationReversibleReplace [throw "Not yet implemented: op reversible replace"]
            operationReversibleRemove [throw "Not yet implemented: op reversible remove"]
         ] [
            throw "Invalid: operations 6-7 don't exist"
         ]
      ]
      if not tail? inputStream [throw "Invalid: Unaccounted for bytes remaining in inputStream"]
      return outputStream
   ]
]
