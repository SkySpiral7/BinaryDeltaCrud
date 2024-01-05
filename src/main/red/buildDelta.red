Red [
   Title: "Functions that make it easy to manually create deltaStreams"
]

do %deltaConstants.red

buildDelta: function [
   {Creates a new binary with a single operation based on args.
   WARN: unvalidated}
   ;TODO: validate 4-5, validate new/old data
   blockArgs[block!]
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
   ;size 0 already has correct bits
   if objArgs/operationSize <> 0 [
      ;TODO: inefficent packing. the other delta function should also compact
      ;a massage function makes sense to have: it should also shrink op sizes to fit

      ;set op size flag and op size size to 4
      result/1: result/1 or deltaConstants/mask/operationSizeFlag
      result/1: result/1 or 4
      append result to binary! objArgs/operationSize
   ]
   if objArgs/oldData <> none [append result objArgs/oldData]
   if objArgs/newData <> none [append result objArgs/newData]
   return result
]
