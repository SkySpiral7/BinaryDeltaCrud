Red [
   Title: "Functions that make it easy to manually create deltaStreams"
]

#include %deltaConstants.red

deltaBuilder: context [
   build: function [
      {Creates a new operationBinary based on args.
      WARN: unvalidated}
      ;TODO: validate 4-5
      operation[integer!] operationSize[integer!]
   ] [
      result: copy #{}
      ;clear out bits that aren't the op
      result: append result (operation and deltaConstants/mask/operation)
      ;size 0 already has correct bits
      if operationSize <> 0 [
         ;TODO: inefficent packing. the other delta function should also compact
         ;a massage function makes sense to have: it should also shrink op sizes to fit

         ;set op size flag and op size size to 4
         result/1: result/1 or deltaConstants/mask/operationSizeFlag
         result/1: result/1 or 4
         result: append result to binary! operationSize
      ]
      return result
   ]
   ;TODO: more func for new/old data
   ;TODO: have all other tests use the builder
]
