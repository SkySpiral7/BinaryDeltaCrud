Red [
   Title: "Iterator design pattern for the deltaStream"
]

do %deltaConstants.red

deltaIterator: context [
   ;constructor arg
   deltaStream: none  ;type? binary!

   ;region: derived state
   operationBinary: none  ;type? binary!
   operationType: none  ;type? integer!
   operationSize: none  ;type? integer!
   oldData: none  ;type? [none! binary!]
   newData: none  ;type? [none! binary!]
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

      operationType: currentDeltaByte and deltaConstants/mask/operation
      remainingValue: currentDeltaByte and deltaConstants/mask/remaining
      opSizeBinary: #{}
      operationSize: remainingValue
      if (currentDeltaByte and deltaConstants/mask/operationSizeFlag) == deltaConstants/mask/operationSizeFlag [
         if remainingValue == 0 [throw "Invalid: op size size can't be 0"]
         if remainingValue > 4 [throw "Limitation: op size size is limited to signed 4 bytes"]
         opSizeBinary: copy/part deltaStream remainingValue
         deltaStream: skip deltaStream remainingValue
         if (remainingValue == 4) and ((opSizeBinary and deltaConstants/mask/detectUnsignedInt) == deltaConstants/mask/detectUnsignedInt)
            [throw "Limitation: op size size is limited to signed 4 bytes"]
         operationSize: to integer! opSizeBinary
      ]
      operationBinary: append copy #{} currentDeltaByte
      append operationBinary opSizeBinary

      switch/default operationType reduce [
         deltaConstants/operation/add [
            either operationSize == deltaConstants/remainingBytes [
               operationSize: length? deltaStream
               if operationSize == deltaConstants/remainingBytes [throw "Invalid: Add operation must add bytes"]
            ]
            [if operationSize > length? deltaStream [throw "Invalid: Not enough bytes remaining in deltaStream"]]
            newData: copy/part deltaStream operationSize
            deltaStream: skip deltaStream operationSize
         ]
         deltaConstants/operation/unchanged [
            if (operationSize == deltaConstants/remainingBytes) and not tail? deltaStream
               [throw "Invalid: Unaccounted for bytes remaining in deltaStream"]
         ]
         deltaConstants/operation/replace [
            either operationSize == deltaConstants/remainingBytes [
               operationSize: length? deltaStream
               if operationSize == deltaConstants/remainingBytes [throw "Invalid: Replace operation must replace bytes"]
            ] [
               if operationSize > length? deltaStream [throw "Invalid: Not enough bytes remaining in deltaStream"]
            ]
            newData: copy/part deltaStream operationSize
            deltaStream: skip deltaStream operationSize
         ]
         deltaConstants/operation/remove [
            if (operationSize == deltaConstants/remainingBytes) and not tail? deltaStream
               [throw "Invalid: Unaccounted for bytes remaining in deltaStream"]
         ]
         deltaConstants/operation/reversibleReplace [
            either operationSize == deltaConstants/remainingBytes [
               if odd? length? deltaStream [throw "Invalid: deltaStream must have an even number of bytes"]
               operationSize: (length? deltaStream) / 2
               if operationSize == deltaConstants/remainingBytes [throw "Invalid: Replace operation must replace bytes"]
            ] [
               if (operationSize * 2) > length? deltaStream
                  [throw "Invalid: Not enough bytes remaining in deltaStream"]
            ]
            oldData: copy/part deltaStream operationSize
            deltaStream: skip deltaStream operationSize
            newData: copy/part deltaStream operationSize
            deltaStream: skip deltaStream operationSize
         ]
         deltaConstants/operation/reversibleRemove [
            either operationSize == deltaConstants/remainingBytes [
               operationSize: length? deltaStream
               if operationSize == deltaConstants/remainingBytes [throw "Invalid: Remove operation must remove bytes"]
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
         deltaConstants/operation/add [
            ;do nothing (always valid)
         ]
         deltaConstants/operation/unchanged [
            either operationSize == deltaConstants/remainingBytes [
               operationSize: length? beforeStream
               ;op size 0 but empty beforeStream is allowed
            ] [
               if operationSize > length? beforeStream
                  [throw "Invalid: Not enough bytes remaining in beforeStream"]
            ]
            beforeStream: skip beforeStream operationSize
         ]
         deltaConstants/operation/replace [
            if operationSize > length? beforeStream
               [throw "Invalid: Not enough bytes remaining in beforeStream"]
            beforeStream: skip beforeStream operationSize
         ]
         deltaConstants/operation/remove [
            either operationSize == deltaConstants/remainingBytes [
               operationSize: length? beforeStream
               if operationSize == deltaConstants/remainingBytes [throw "Invalid: Remove operation must remove bytes"]
            ] [
               if operationSize > length? beforeStream
                  [throw "Invalid: Not enough bytes remaining in beforeStream"]
            ]
            beforeStream: skip beforeStream operationSize
         ]
         deltaConstants/operation/reversibleReplace [
            if operationSize > length? beforeStream
               [throw "Invalid: Not enough bytes remaining in beforeStream"]
            removedBytes: copy/part beforeStream operationSize
            beforeStream: skip beforeStream operationSize
            if oldData <> removedBytes
               [throw "Invalid: bytes removed from beforeStream didn't match deltaStream"]
         ]
         deltaConstants/operation/reversibleRemove [
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
      operationBinary/1: operationBinary/1 or deltaConstants/mask/reversibleFlag
      ;TODO: update other vars:
      ;binary, type, add oldData
      exit
   ]

   clearReversibleFlag: func [
      {makes the current operation's reversible flag be set to false
      WARN: no other variables are updated}
   ] [
      operationBinary/1: operationBinary/1 and complement deltaConstants/mask/reversibleFlag
      exit
   ]

   setOperation: func [
      {Sets the operation
      WARN: unvalidated and no other variables are updated}
      newOperation[integer!]
      /local tempOperation
   ] [
      ;clear out operation bits
      tempOperation: operationBinary/1 and complement deltaConstants/mask/operation
      ;set operation bits
      tempOperation: tempOperation or newOperation
      operationBinary/1: tempOperation
      exit
   ]
]
