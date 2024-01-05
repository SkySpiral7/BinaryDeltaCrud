Red [
   Title: "Iterator design pattern for the deltaStream"
]

;TODO: use deltaConstants

deltaIterator: context [
   ;region: constants
   mask: context [
      ;highest bit of 4 bytes (int size). appends 1 byte and 3 bytes
      detectUnsignedInt: append 2#{10000000} #{000000}
      reversibleFlag: to integer! 2#{10000000}
      operation: to integer! 2#{11100000}
      operationSizeFlag: to integer! 2#{00010000}
      remaining: to integer! 2#{00001111}
   ]
   operation: context [
      add: to integer! 2#{00000000}
      unchanged: to integer! 2#{00100000}
      replace: to integer! 2#{01000000}
      remove: to integer! 2#{01100000}
      reversibleReplace: to integer! 2#{11000000}
      reversibleRemove: to integer! 2#{11100000}
   ]
   ;endregion: constants

   ;constructor arg
   deltaStream: none  ;type? binary!

   ;region: derived state
   operationBinary: none  ;type? binary!
   operationType: none  ;type? integer!
   operationSize: none  ;type? integer!
   oldData: none  ;type? binary!
   newData: none  ;type? binary!
   ;endregion: derived state

   hasNext?: function [
      "@returns true if there is another delta opperation to parse"
   ] [
      return not tail? deltaStream
   ]

   parseNext: func [
      {Will parse and interpret the next delta opperation and store the results in fields.
      @param beforeStream only the current position will be looked at}
      beforeStream [none! binary!]
      /local currentDeltaByte remainingValue opSizeBinary
   ] [
      oldData: none
      newData: none
      currentDeltaByte: deltaStream/1
      deltaStream: next deltaStream

      operationType: currentDeltaByte and mask/operation
      remainingValue: currentDeltaByte and mask/remaining
      opSizeBinary: #{}
      operationSize: remainingValue
      if (currentDeltaByte and mask/operationSizeFlag) == mask/operationSizeFlag [
         if remainingValue == 0 [throw "Invalid: op size size can't be 0"]
         if remainingValue > 4 [throw "Limitation: op size size is limited to signed 4 bytes"]
         opSizeBinary: copy/part deltaStream remainingValue
         deltaStream: skip deltaStream remainingValue
         if (remainingValue == 4) and ((opSizeBinary and mask/detectUnsignedInt) == mask/detectUnsignedInt)
            [throw "Limitation: op size size is limited to signed 4 bytes"]
         operationSize: to integer! opSizeBinary
      ]
      operationBinary: append copy #{} currentDeltaByte
      append operationBinary opSizeBinary

      switch/default operationType reduce [
         operation/add [
            either operationSize == 0 [
               operationSize: length? deltaStream
               if operationSize == 0 [throw "Invalid: Add operation must add bytes"]
            ]
            [if operationSize > length? deltaStream [throw "Invalid: Not enough bytes remaining in deltaStream"]]
            newData: copy/part deltaStream operationSize
            deltaStream: skip deltaStream operationSize
         ]
         operation/unchanged [
            if (operationSize == 0) and not tail? deltaStream
               [throw "Invalid: Unaccounted for bytes remaining in deltaStream"]
         ]
         operation/replace [
            either operationSize == 0 [
               operationSize: length? deltaStream
               if operationSize == 0 [throw "Invalid: Replace operation must replace bytes"]
            ] [
               if operationSize > length? deltaStream [throw "Invalid: Not enough bytes remaining in deltaStream"]
            ]
            newData: copy/part deltaStream operationSize
            deltaStream: skip deltaStream operationSize
         ]
         operation/remove [
            if (operationSize == 0) and not tail? deltaStream
               [throw "Invalid: Unaccounted for bytes remaining in deltaStream"]
         ]
         operation/reversibleReplace [
            either operationSize == 0 [
               if odd? length? deltaStream [throw "Invalid: deltaStream must have an even number of bytes"]
               operationSize: (length? deltaStream) / 2
               if operationSize == 0 [throw "Invalid: Replace operation must replace bytes"]
            ] [
               if (operationSize * 2) > length? deltaStream
                  [throw "Invalid: Not enough bytes remaining in deltaStream"]
            ]
            oldData: copy/part deltaStream operationSize
            deltaStream: skip deltaStream operationSize
            newData: copy/part deltaStream operationSize
            deltaStream: skip deltaStream operationSize
         ]
         operation/reversibleRemove [
            either operationSize == 0 [
               operationSize: length? deltaStream
               if operationSize == 0 [throw "Invalid: Remove operation must remove bytes"]
            ] [
               if operationSize > length? deltaStream [throw "Invalid: Not enough bytes remaining in deltaStream"]
            ]
            oldData: copy/part deltaStream operationSize
            deltaStream: skip deltaStream operationSize
         ]
      ] [
         throw "Invalid: operations 4-5 don't exist"
      ]
      if beforeStream <> none [withBeforeStream beforeStream]
      return none
   ]

   withBeforeStream: func [
      {Validate beforeStream according to the current delta position.
      If operationSize = 0 then it will be set to length? beforeStream.}
      beforeStream[binary!]
      /local removedBytes
   ] [
      switch operationType reduce [
         operation/add [
            ;do nothing (always valid)
         ]
         operation/unchanged [
            either operationSize == 0 [
               operationSize: length? beforeStream
               ;op size 0 but empty beforeStream is allowed
            ] [
               if operationSize > length? beforeStream
                  [throw "Invalid: Not enough bytes remaining in beforeStream"]
            ]
            beforeStream: skip beforeStream operationSize
         ]
         operation/replace [
            if operationSize > length? beforeStream
               [throw "Invalid: Not enough bytes remaining in beforeStream"]
            beforeStream: skip beforeStream operationSize
         ]
         operation/remove [
            either operationSize == 0 [
               operationSize: length? beforeStream
               if operationSize == 0 [throw "Invalid: Remove operation must remove bytes"]
            ] [
               if operationSize > length? beforeStream
                  [throw "Invalid: Not enough bytes remaining in beforeStream"]
            ]
            beforeStream: skip beforeStream operationSize
         ]
         operation/reversibleReplace [
            if operationSize > length? beforeStream
               [throw "Invalid: Not enough bytes remaining in beforeStream"]
            removedBytes: copy/part beforeStream operationSize
            beforeStream: skip beforeStream operationSize
            if oldData <> removedBytes
               [throw "Invalid: bytes removed from beforeStream didn't match deltaStream"]
         ]
         operation/reversibleRemove [
            if operationSize > length? beforeStream
               [throw "Invalid: Not enough bytes remaining in beforeStream"]
            removedBytes: copy/part beforeStream operationSize
            beforeStream: skip beforeStream operationSize
            if oldData <> removedBytes
               [throw "Invalid: bytes removed from beforeStream didn't match deltaStream"]
         ]
      ]
      if (not hasNext?) and (not tail? beforeStream)
         [throw "Invalid: Unaccounted for bytes remaining in beforeStream"]
      return none
   ]

   operationAndData: func [
      "@returns the entire binary for delta's current position"
      /local result
   ] [
      result: copy operationBinary
      if oldData <> none [append result oldData]
      if newData <> none [append result newData]
      return result
   ]

   setReversibleFlag: func [
      {makes the current operation's reversible flag be set to true
      WARN: unvalidated and no other variables are updated}
   ] [
      operationBinary/1: operationBinary/1 or mask/reversibleFlag
      ;TODO: update other vars:
      ;binary, type, add oldData
      exit
   ]

   clearReversibleFlag: func [
      {makes the current operation's reversible flag be set to false
      WARN: no other variables are updated}
   ] [
      operationBinary/1: operationBinary/1 and complement mask/reversibleFlag
      exit
   ]

   setOperation: func [
      {Sets the operation
      WARN: unvalidated and no other variables are updated}
      newOperation[integer!]
      /local tempOperation
   ] [
      ;clear out operation bits
      tempOperation: operationBinary/1 and complement mask/operation
      ;set operation bits
      tempOperation: tempOperation or newOperation
      operationBinary/1: tempOperation
      exit
   ]
]
