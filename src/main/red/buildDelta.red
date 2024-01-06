Red [
   Title: "Functions that make it easy to manually create deltaStreams"
]

do %deltaConstants.red

buildDelta: function [
   {Creates a new binary with a single operation based on args.
   @returns deltaStream
   WARN: unvalidated so that tests can create binary to test other validation}
   blockArgs[block!]
   return: [binary!]
] [
   template: context [
      operation: none  ;type? integer!
      operationSize: none  ;type? integer!
      oldData: none  ;type? [none! binary!]
      newData: none  ;type? [none! binary!]
   ]
   objArgs: make template blockArgs

   result: copy #{}
   ;clear out bits that aren't the op
   append result (objArgs/operation and deltaConstants/mask/operation)

   ;remainingBytes is 0 so it fits here
   either objArgs/operationSize <= 15 [
      result/1: result/1 or objArgs/operationSize
   ] [
      ;set op size flag
      result/1: result/1 or deltaConstants/mask/operationSizeFlag
      operationSizeBinary: to binary! objArgs/operationSize
      ;exclude leading 0s
      while [operationSizeBinary/1 == 0] [operationSizeBinary: next operationSizeBinary]
      result/1: result/1 or length? operationSizeBinary
      append result operationSizeBinary
   ]
   if objArgs/oldData <> none [append result objArgs/oldData]
   if objArgs/newData <> none [append result objArgs/newData]
   return result
]
