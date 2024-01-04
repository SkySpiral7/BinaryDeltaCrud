Red [
   Title: "tests for deltaIterator"
]

context [
   setup: function [
      "Initialize/Reload context before each test"
   ] [
      do %../../main/red/deltaIterator.red
   ]

   test-hasNext?: function [] [
      ;001 0 0000 remaining unchanged aka done
      deltaItr: make deltaIterator [deltaStream: 2#{00100000}]

      redunit/assert-equals true deltaItr/hasNext?
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals false deltaItr/hasNext?
   ]

   test-parseNext-throws-givenOpSizeSize0: function [] [
      ;001 1 0000 unchanged 0 bytes op size size
      deltaItr: make deltaIterator [deltaStream: 2#{00110000}]
      expected: "Invalid: op size size can't be 0"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenOpSizeSizeTooLarge: function [] [
      ;001 1 1000 unchanged 8 bytes op size size
      deltaItr: make deltaIterator [deltaStream: 2#{00111000}]
      expected: "Limitation: op size size is limited to signed 4 bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenOpSizeSizeTooLargeSigned: function [] [
      ;001 1 0100 10000000 00000000 00000000 00000000 unchanged 4 bytes op size size which has an op size of 2147483648
      deltaItr: make deltaIterator [deltaStream: 2#{0011010010000000000000000000000000000000}]
      expected: "Limitation: op size size is limited to signed 4 bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parsesOperationSize-whenSimple: function [] [
      ;001 0 0001 unchanged 1 byte
      originalDeltaStream: 2#{00100001}
      deltaItr: make deltaIterator [deltaStream: copy originalDeltaStream]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals originalDeltaStream deltaItr/operationBinary
      redunit/assert-equals deltaItr/operation/unchanged deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-parseNext-parsesOperationSize-whenOpSizeSize2: function [] [
      ;001 1 0010 00000000 00000001 unchanged 2 bytes op size size which has an op size of 1
      originalDeltaStream: 2#{001100100000000000000001}
      deltaItr: make deltaIterator [deltaStream: copy originalDeltaStream]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals originalDeltaStream deltaItr/operationBinary
      redunit/assert-equals deltaItr/operation/unchanged deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-parseNext-parsesOperationSize-whenOpSizeSize4: function [] [
      ;001 1 0100 00000000 00000000 00000000 00000001 unchanged 4 bytes op size size which has an op size of 1
      originalDeltaStream: 2#{0011010000000000000000000000000000000001}
      deltaItr: make deltaIterator [deltaStream: copy originalDeltaStream]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals originalDeltaStream deltaItr/operationBinary
      redunit/assert-equals deltaItr/operation/unchanged deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-parseNext-throws-givenAddOp0Empty: function [] [
      ;000 0 0000 add remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{00000000}]
      expected: "Invalid: Add operation must add bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenAddOp1Empty: function [] [
      ;000 0 0001 add 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{00000001}]
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenAddOp0: function [] [
      ;000 0 0000 add remaining bytes (11111111)
      deltaItr: make deltaIterator [deltaStream: 2#{0000000011111111}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/add deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{11111111} deltaItr/newData
   ]

   test-parseNext-parses-givenAddOp1: function [] [
      ;000 0 0001 add 1 byte (11111111)
      deltaItr: make deltaIterator [deltaStream: 2#{0000000111111111}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/add deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{11111111} deltaItr/newData
   ]

   test-parseNext-throws-givenUnchangeOp0ExtraDelta: function [] [
      ;001 0 0000 remaining unchanged aka done
      deltaItr: make deltaIterator [deltaStream: 2#{0010000000100000}]
      expected: "Invalid: Unaccounted for bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenUnchangeOp0: function [] [
      ;001 0 0000 remaining unchanged aka done
      deltaItr: make deltaIterator [deltaStream: 2#{00100000}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/unchanged deltaItr/operationType
      redunit/assert-equals 0 deltaItr/operationSize
   ]

   test-parseNext-parses-givenUnchangeOp1: function [] [
      ;001 0 0001 unchanged 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{00100001}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/unchanged deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-parseNext-throws-givenReplaceOp0Empty: function [] [
      ;010 0 0000 replace remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{01000000}]
      expected: "Invalid: Replace operation must replace bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenReplaceOp1ShortDelta: function [] [
      ;010 0 0001 replace 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{01000001}]
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenReplaceOp0: function [] [
      ;010 0 0000 replace remaining (11111111)
      deltaItr: make deltaIterator [deltaStream: 2#{0100000011111111}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/replace deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{11111111} deltaItr/newData
   ]

   test-parseNext-parses-givenReplaceOp1: function [] [
      ;010 0 0001 replace 1 byte (11111111)
      deltaItr: make deltaIterator [deltaStream: 2#{0100000111111111}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/replace deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{11111111} deltaItr/newData
   ]

   test-parseNext-throws-givenRemoveOp0Extra: function [] [
      ;011 0 0000 remove remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{0110000001100000}]
      expected: "Invalid: Unaccounted for bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenRemoveOp0: function [] [
      ;011 0 0000 remove remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{01100000}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/remove deltaItr/operationType
      redunit/assert-equals 0 deltaItr/operationSize
   ]

   test-parseNext-parses-givenRemoveOp1: function [] [
      ;011 0 0001 remove 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{01100001}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/remove deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-parseNext-throws-givenReversibleReplaceOp0Odd: function [] [
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000 but no new
      deltaItr: make deltaIterator [deltaStream: 2#{1100000000000000}]
      expected: "Invalid: deltaStream must have an even number of bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenReversibleReplaceOp0Empty: function [] [
      ;110 0 0000 reversible replace remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{11000000}]
      expected: "Invalid: Replace operation must replace bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenReversibleReplaceOp1EmptyDelta: function [] [
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000 but no new
      deltaItr: make deltaIterator [deltaStream: 2#{1100000100000000}]
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenReversibleReplaceOp0: function [] [
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000 new: 11111111
      deltaItr: make deltaIterator [deltaStream: 2#{110000000000000011111111}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/reversibleReplace deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{00000000} deltaItr/oldData
      redunit/assert-equals 2#{11111111} deltaItr/newData
   ]

   test-parseNext-parses-givenReversibleReplaceOp1: function [] [
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000 new: 11111111
      deltaItr: make deltaIterator [deltaStream: 2#{110000010000000011111111}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/reversibleReplace deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{00000000} deltaItr/oldData
      redunit/assert-equals 2#{11111111} deltaItr/newData
   ]

   test-parseNext-throws-givenReversibleRemoveOp0Empty: function [] [
      ;111 0 0000 reversible remove remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{11100000}]
      expected: "Invalid: Remove operation must remove bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenReversibleRemoveOp1EmptyDelta: function [] [
      ;111 0 0001 reversible remove 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{11100001}]
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenReversibleRemoveOp0: function [] [
      ;111 0 0000 reversible remove remaining bytes
      ;old: 00000000
      deltaItr: make deltaIterator [deltaStream: 2#{1110000000000000}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/reversibleRemove deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{00000000} deltaItr/oldData
   ]

   test-parseNext-parses-givenReversibleRemoveOp1: function [] [
      ;111 0 0001 reversible remove 1 byte
      ;old: 00000000
      deltaItr: make deltaIterator [deltaStream: 2#{1110000100000000}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/reversibleRemove deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{00000000} deltaItr/oldData
   ]

   test-parseNext-throws-whenOp4: function [] [
      deltaItr: make deltaIterator [deltaStream: 2#{10000000}]
      expected: "Invalid: operations 4-5 don't exist"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-whenOp5: function [] [
      deltaItr: make deltaIterator [deltaStream: 2#{10100000}]
      expected: "Invalid: operations 4-5 don't exist"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-doesNothing-givenAdd: function [] [
      ;000 0 0000 add remaining bytes (11111111)
      beforeStream: #{}
      deltaItr: make deltaIterator [deltaStream: 2#{0000000011111111}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
   ]

   test-withBeforeStream-doesNothing-givenUnchangedOp0Empty: function [] [
      beforeStream: #{}
      ;001 0 0000 remaining unchanged aka done
      deltaItr: make deltaIterator [deltaStream: 2#{00100000}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
      redunit/assert-equals 0 deltaItr/operationSize
   ]

   test-withBeforeStream-setsSize-givenUnchangedOp0Before: function [] [
      beforeStream: #{1122}
      ;001 0 0000 remaining unchanged aka done
      deltaItr: make deltaIterator [deltaStream: 2#{00100000}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
      redunit/assert-equals 2 deltaItr/operationSize
   ]

   test-withBeforeStream-throws-givenUnchangeOp1Empty: function [] [
      beforeStream: #{}
      ;001 0 0001 unchanged 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{00100001}]
      expected: "Invalid: Not enough bytes remaining in beforeStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-doesNothing-givenValidReplace: function [] [
      beforeStream: #{00}
      ;010 0 0001 replace 1 byte (11111111)
      deltaItr: make deltaIterator [deltaStream: 2#{0100000111111111}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
   ]

   test-withBeforeStream-throws-givenReplaceOp1ShortBefore: function [] [
      beforeStream: #{}
      ;010 0 0001 replace 1 byte (11111111)
      deltaItr: make deltaIterator [deltaStream: 2#{0100000111111111}]
      expected: "Invalid: Not enough bytes remaining in beforeStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-doesNothing-givenRemoveOp1: function [] [
      beforeStream: #{11}
      ;011 0 0001 remove 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{01100001}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
   ]

   test-withBeforeStream-setsSize-givenRemoveOp0: function [] [
      beforeStream: #{00}
      ;011 0 0000 remove remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{01100000}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-withBeforeStream-throws-givenRemoveOp0Empty: function [] [
      beforeStream: #{}
      ;011 0 0000 remove remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{01100000}]
      expected: "Invalid: Remove operation must remove bytes"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-throws-givenRemoveOp1Empty: function [] [
      beforeStream: #{}
      ;011 0 0001 remove 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{01100001}]
      expected: "Invalid: Not enough bytes remaining in beforeStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-doesNothing-givenValidReversibleReplace: function [] [
      beforeStream: 2#{00000000}
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000, new: 11111111
      deltaItr: make deltaIterator [deltaStream: 2#{110000010000000011111111}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
   ]

   test-withBeforeStream-throws-givenReversibleReplaceEmptyBefore: function [] [
      beforeStream: #{}
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000, new: 11111111
      deltaItr: make deltaIterator [deltaStream: 2#{110000010000000011111111}]
      expected: "Invalid: Not enough bytes remaining in beforeStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-throws-givenReversibleReplaceNoMatch: function [] [
      beforeStream: 2#{11000001}
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000, new: 11111111
      deltaItr: make deltaIterator [deltaStream: 2#{110000010000000011111111}]
      expected: "Invalid: bytes removed from beforeStream didn't match deltaStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-doesNothing-givenValidReversibleRemove: function [] [
      beforeStream: 2#{00000000}
      ;111 0 0001 reversible remove 1 byte
      ;old: 00000000
      deltaItr: make deltaIterator [deltaStream: 2#{1110000100000000}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
   ]

   test-withBeforeStream-throws-givenReversibleRemoveEmptyBefore: function [] [
      beforeStream: #{}
      ;111 0 0001 reversible remove 1 byte
      ;old: 00000000
      deltaItr: make deltaIterator [deltaStream: 2#{1110000100000000}]
      expected: "Invalid: Not enough bytes remaining in beforeStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-throws-givenReversibleRemoveNoMatch: function [] [
      beforeStream: 2#{11000001}
      ;111 0 0001 reversible remove 1 byte
      ;old: 00000000
      deltaItr: make deltaIterator [deltaStream: 2#{1110000100000000}]
      expected: "Invalid: bytes removed from beforeStream didn't match deltaStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-withBeforeStream-doesNothing-whenNonTerminalExtraBefore: function [] [
      beforeStream: #{1122}
      ;001 0 0001 unchanged 1 byte. twice but only first is parsed
      deltaItr: make deltaIterator [deltaStream: 2#{0010000100100001}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals none actual
   ]

   test-withBeforeStream-throws-whenBeforeHasExtraBytes: function [] [
      beforeStream: #{1122}
      ;001 0 0001 unchanged 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{00100001}]
      expected: "Invalid: Unaccounted for bytes remaining in beforeStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withBeforeStream beforeStream]

      redunit/assert-equals expected actual
   ]

   test-operationAndData-returns-whenMinimal: function [] [
      ;001 0 0000 remaining unchanged aka done
      originalDeltaStream: 2#{00100000}
      deltaItr: make deltaIterator [deltaStream: copy originalDeltaStream]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals originalDeltaStream catch [deltaItr/operationAndData]
   ]

   test-operationAndData-returns-whenMax: function [] [
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000 new: 11111111
      originalDeltaStream: 2#{110000010000000011111111}
      deltaItr: make deltaIterator [deltaStream: copy originalDeltaStream]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals originalDeltaStream catch [deltaItr/operationAndData]
   ]
]
