Red [
   Title: "tests for deltaIterator"
]

do %../../main/red/buildDelta.red
do %../../main/red/deltaConstants.red

context [
   setup: function [
      "Initialize/Reload context before each test"
   ] [
      do %../../main/red/deltaIterator.red
   ]

   makeSingle: function [
      blockArgs[block!]
   ] [
      return make deltaIterator [
         deltaStream: append copy #{} (
            buildDelta blockArgs
         )
      ]
   ]

   test-hasNext?: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/unchanged
         operationSize: 1
      ]

      redunit/assert-equals true deltaItr/hasNext?
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals false deltaItr/hasNext?
   ]

   test-parseNext-throws-givenOpSizeSize0: function [] [
      ;can't use builder to make this invalid state
      ;001 1 0000 unchanged 0 bytes op size size
      deltaItr: make deltaIterator [deltaStream: 2#{00110000}]
      expected: "Invalid: op size size can't be 0"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenOpSizeSizeTooLarge: function [] [
      ;can't use builder since integer arg is larger than max int
      ;001 1 1000 unchanged 8 bytes op size size
      deltaItr: make deltaIterator [deltaStream: 2#{00111000}]
      expected: "Limitation: op size size is limited to signed 4 bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenOpSizeSizeTooLargeSigned: function [] [
      ;can't use builder since integer arg is larger than max int
      ;001 1 0100 10000000 00000000 00000000 00000000 unchanged 4 bytes op size size which has an op size of 2147483648
      deltaItr: make deltaIterator [deltaStream: 2#{0011010010000000000000000000000000000000}]
      expected: "Limitation: op size size is limited to signed 4 bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parsesOperationSize-whenSimple: function [] [
      ;don't use builder so I can enforce the op size flag
      ;001 0 0001 unchanged 1 byte
      originalDeltaStream: 2#{00100001}
      deltaItr: make deltaIterator [deltaStream: copy originalDeltaStream]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals originalDeltaStream deltaItr/operationBinary
      redunit/assert-equals deltaConstants/operation/unchanged deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-parseNext-parsesOperationSize-whenOpSizeSize2: function [] [
      ;don't use builder so I can enforce the op size flag
      ;001 1 0010 00000000 00000001 unchanged 2 bytes op size size which has an op size of 1
      originalDeltaStream: 2#{001100100000000000000001}
      deltaItr: make deltaIterator [deltaStream: copy originalDeltaStream]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals originalDeltaStream deltaItr/operationBinary
      redunit/assert-equals deltaConstants/operation/unchanged deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-parseNext-parsesOperationSize-whenOpSizeSize4: function [] [
      ;don't use builder so I can enforce the op size flag
      ;001 1 0100 00000000 00000000 00000000 00000001 unchanged 4 bytes op size size which has an op size of 1
      originalDeltaStream: 2#{0011010000000000000000000000000000000001}
      deltaItr: make deltaIterator [deltaStream: copy originalDeltaStream]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals originalDeltaStream deltaItr/operationBinary
      redunit/assert-equals deltaConstants/operation/unchanged deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-parseNext-throws-givenAddOp0Empty: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/add
         operationSize: deltaConstants/remainingBytes
      ]
      expected: "Invalid: Add operation must add bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenAddOp1Empty: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/add
         operationSize: 1
      ]
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenAddOp0: function [] [
      expectedNewData: to binary! "abc"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/add
         operationSize: deltaConstants/remainingBytes
         newData: copy expectedNewData
      ]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaConstants/operation/add deltaItr/operationType
      redunit/assert-equals 3 deltaItr/operationSize
      redunit/assert-equals expectedNewData deltaItr/newData
   ]

   test-parseNext-parses-givenAddOp1: function [] [
      expectedNewData: to binary! #"a"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/add
         operationSize: 1
         newData: copy expectedNewData
      ]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaConstants/operation/add deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals expectedNewData deltaItr/newData
   ]

   test-parseNext-throws-givenUnchangeOp0ExtraDelta: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/unchanged
         operationSize: deltaConstants/remainingBytes
         newData: to binary! "extra"
      ]
      expected: "Invalid: Unaccounted for bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenUnchangeOp0: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/unchanged
         operationSize: deltaConstants/remainingBytes
      ]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaConstants/operation/unchanged deltaItr/operationType
      redunit/assert-equals 0 deltaItr/operationSize
   ]

   test-parseNext-parses-givenUnchangeOp1: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/unchanged
         operationSize: 1
      ]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaConstants/operation/unchanged deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-parseNext-throws-givenReplaceOp0Empty: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/replace
         operationSize: deltaConstants/remainingBytes
      ]
      expected: "Invalid: Replace operation must replace bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenReplaceOp1ShortDelta: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/replace
         operationSize: 1
      ]
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenReplaceOp0: function [] [
      expectedNewData: to binary! #"a"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/replace
         operationSize: deltaConstants/remainingBytes
         newData: copy expectedNewData
      ]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaConstants/operation/replace deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals expectedNewData deltaItr/newData
   ]

   test-parseNext-parses-givenReplaceOp1: function [] [
      expectedNewData: to binary! #"a"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/replace
         operationSize: 1
         newData: copy expectedNewData
      ]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaConstants/operation/replace deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals expectedNewData deltaItr/newData
   ]

   test-parseNext-throws-givenRemoveOp0Extra: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/remove
         operationSize: deltaConstants/remainingBytes
         newData: to binary! "extra"
      ]
      expected: "Invalid: Unaccounted for bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenRemoveOp0: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/remove
         operationSize: deltaConstants/remainingBytes
      ]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaConstants/operation/remove deltaItr/operationType
      redunit/assert-equals 0 deltaItr/operationSize
   ]

   test-parseNext-parses-givenRemoveOp1: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/remove
         operationSize: 1
      ]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaConstants/operation/remove deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-parseNext-throws-givenReversibleReplaceOp0Odd: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: deltaConstants/remainingBytes
         oldData: to binary! "odd"
      ]
      expected: "Invalid: deltaStream must have an even number of bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenReversibleReplaceOp0Empty: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: deltaConstants/remainingBytes
      ]
      expected: "Invalid: Replace operation must replace bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenReversibleReplaceOp1EmptyDelta: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: 1
         oldData: to binary! #"a"
         ;no new
      ]
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenReversibleReplaceOp0: function [] [
      expectedOldData: to binary! "aa"
      expectedNewData: to binary! "bb"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: deltaConstants/remainingBytes
         oldData: copy expectedOldData
         newData: copy expectedNewData
      ]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaConstants/operation/reversibleReplace deltaItr/operationType
      redunit/assert-equals 2 deltaItr/operationSize
      redunit/assert-equals expectedOldData deltaItr/oldData
      redunit/assert-equals expectedNewData deltaItr/newData
   ]

   test-parseNext-parses-givenReversibleReplaceOp1: function [] [
      expectedOldData: to binary! #"a"
      expectedNewData: to binary! #"b"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: 1
         oldData: copy expectedOldData
         newData: copy expectedNewData
      ]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaConstants/operation/reversibleReplace deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals expectedOldData deltaItr/oldData
      redunit/assert-equals expectedNewData deltaItr/newData
   ]

   test-parseNext-throws-givenReversibleRemoveOp0Empty: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/reversibleRemove
         operationSize: deltaConstants/remainingBytes
         oldData: #{}
      ]
      expected: "Invalid: Remove operation must remove bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenReversibleRemoveOp1EmptyDelta: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/reversibleRemove
         operationSize: 1
         oldData: #{}
      ]
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenReversibleRemoveOp0: function [] [
      expectedOldData: to binary! #"a"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/reversibleRemove
         operationSize: deltaConstants/remainingBytes
         oldData: copy expectedOldData
      ]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaConstants/operation/reversibleRemove deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals expectedOldData deltaItr/oldData
   ]

   test-parseNext-parses-givenReversibleRemoveOp1: function [] [
      expectedOldData: to binary! #"a"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/reversibleRemove
         operationSize: 1
         oldData: copy expectedOldData
      ]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaConstants/operation/reversibleRemove deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals expectedOldData deltaItr/oldData
   ]

   test-parseNext-throws-whenOp4: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/invalid4
         operationSize: 1
      ]
      expected: "Invalid: operations 4-5 don't exist"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-whenOp5: function [] [
      deltaItr: makeSingle [
         operation: deltaConstants/operation/invalid5
         operationSize: 1
      ]
      expected: "Invalid: operations 4-5 don't exist"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-doesNothing-givenAdd: function [] [
      beforeStream: #{}
      deltaItr: makeSingle [
         operation: deltaConstants/operation/add
         operationSize: deltaConstants/remainingBytes
         newData: to binary! #"a"
      ]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
   ]

   test-withBeforeStream-doesNothing-givenUnchangedOp0Empty: function [] [
      beforeStream: #{}
      deltaItr: makeSingle [
         operation: deltaConstants/operation/unchanged
         operationSize: deltaConstants/remainingBytes
      ]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
      redunit/assert-equals 0 deltaItr/operationSize
   ]

   test-withBeforeStream-setsSize-givenUnchangedOp0Before: function [] [
      beforeStream: to binary! "aa"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/unchanged
         operationSize: deltaConstants/remainingBytes
      ]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
      redunit/assert-equals 2 deltaItr/operationSize
   ]

   test-withBeforeStream-throws-givenUnchangeOp1Empty: function [] [
      beforeStream: #{}
      deltaItr: makeSingle [
         operation: deltaConstants/operation/unchanged
         operationSize: 1
      ]
      expected: "Invalid: Not enough bytes remaining in beforeStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-doesNothing-givenValidReplace: function [] [
      beforeStream: to binary! #"a"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/replace
         operationSize: 1
         newData: to binary! #"b"
      ]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
   ]

   test-withBeforeStream-throws-givenReplaceOp1ShortBefore: function [] [
      beforeStream: #{}
      deltaItr: makeSingle [
         operation: deltaConstants/operation/replace
         operationSize: 1
         newData: to binary! #"b"
      ]
      expected: "Invalid: Not enough bytes remaining in beforeStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-doesNothing-givenRemoveOp1: function [] [
      beforeStream: to binary! #"a"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/remove
         operationSize: 1
      ]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
   ]

   test-withBeforeStream-setsSize-givenRemoveOp0: function [] [
      beforeStream: to binary! #"a"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/remove
         operationSize: deltaConstants/remainingBytes
      ]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-withBeforeStream-throws-givenRemoveOp0Empty: function [] [
      beforeStream: #{}
      deltaItr: makeSingle [
         operation: deltaConstants/operation/remove
         operationSize: deltaConstants/remainingBytes
      ]
      expected: "Invalid: Remove operation must remove bytes"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-throws-givenRemoveOp1Empty: function [] [
      beforeStream: #{}
      deltaItr: makeSingle [
         operation: deltaConstants/operation/remove
         operationSize: 1
      ]
      expected: "Invalid: Not enough bytes remaining in beforeStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-doesNothing-givenValidReversibleReplace: function [] [
      beforeStream: to binary! #"a"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: 1
         oldData: copy beforeStream
         newData: to binary! #"b"
      ]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
   ]

   test-withBeforeStream-throws-givenReversibleReplaceEmptyBefore: function [] [
      beforeStream: #{}
      deltaItr: makeSingle [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: deltaConstants/remainingBytes
         oldData: to binary! #"a"
         newData: to binary! #"b"
      ]
      expected: "Invalid: Not enough bytes remaining in beforeStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-throws-givenReversibleReplaceNoMatch: function [] [
      beforeStream: to binary! #"a"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: deltaConstants/remainingBytes
         oldData: to binary! #"c"
         newData: to binary! #"b"
      ]
      expected: "Invalid: bytes removed from beforeStream didn't match deltaStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-doesNothing-givenValidReversibleRemove: function [] [
      beforeStream: to binary! #"a"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/reversibleRemove
         operationSize: 1
         oldData: copy beforeStream
      ]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
   ]

   test-withBeforeStream-throws-givenReversibleRemoveEmptyBefore: function [] [
      beforeStream: #{}
      deltaItr: makeSingle [
         operation: deltaConstants/operation/reversibleRemove
         operationSize: 1
         oldData: to binary! #"a"
      ]
      expected: "Invalid: Not enough bytes remaining in beforeStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-throws-givenReversibleRemoveNoMatch: function [] [
      beforeStream: to binary! #"a"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/reversibleRemove
         operationSize: 1
         oldData: to binary! #"c"
      ]
      expected: "Invalid: bytes removed from beforeStream didn't match deltaStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-doesNothing-whenNonTerminalExtraBefore: function [] [
      beforeStream: to binary! "ab"
      deltaStreamParam: copy #{}
      append deltaStreamParam (
         buildDelta [
            operation: deltaConstants/operation/unchanged
            operationSize: 1
         ]
      )
      ;same op twice but only first is parsed
      append deltaStreamParam deltaStreamParam
      deltaItr: make deltaIterator[deltaStream: deltaStreamParam]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
   ]

   test-withBeforeStream-throws-whenBeforeHasExtraBytes: function [] [
      beforeStream: to binary! "ab"
      deltaItr: makeSingle [
         operation: deltaConstants/operation/unchanged
         operationSize: 1
      ]
      expected: "Invalid: Unaccounted for bytes remaining in beforeStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-operationAndData-returns-whenMinimal: function [] [
      originalDeltaStream: buildDelta [
         operation: deltaConstants/operation/unchanged
         operationSize: 1
      ]
      deltaItr: make deltaIterator[deltaStream: copy originalDeltaStream]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals originalDeltaStream catch [deltaItr/operationAndData]
   ]

   test-operationAndData-returns-whenMax: function [] [
      originalDeltaStream: buildDelta [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: 1
         oldData: to binary! #"a"
         newData: to binary! #"b"
      ]
      deltaItr: make deltaIterator[deltaStream: copy originalDeltaStream]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals originalDeltaStream catch [deltaItr/operationAndData]
   ]
]
