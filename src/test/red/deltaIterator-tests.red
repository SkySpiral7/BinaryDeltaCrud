Red [
   Title: "tests for deltaIterator"
]

context [
   setup: func [
      "Initialize/Reload context before each test"
   ] [
      do %../../main/red/deltaIterator.red
   ]

   test-hasNext?: func [] [
      ;001 0 0000 remaining unchanged aka done
      deltaItr: make deltaIterator [deltaStream: 2#{00100000}]

      redunit/assert-equals true deltaItr/hasNext?
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals false deltaItr/hasNext?
   ]

   test-parseNext-throws-givenOpSizeSize0: func [] [
      ;001 1 0000 unchanged 0 bytes op size size
      deltaItr: make deltaIterator [deltaStream: 2#{00110000}]
      expected: "Invalid: op size size can't be 0"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenOpSizeSizeTooLarge: func [] [
      ;001 1 1000 unchanged 8 bytes op size size
      deltaItr: make deltaIterator [deltaStream: 2#{00111000}]
      expected: "Limitation: op size size is limited to signed 4 bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenOpSizeSizeTooLargeSigned: func [] [
      ;001 1 0100 10000000 00000000 00000000 00000000 unchanged 4 bytes op size size which has an op size of 2147483648
      deltaItr: make deltaIterator [deltaStream: 2#{0011010010000000000000000000000000000000}]
      expected: "Limitation: op size size is limited to signed 4 bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parsesOperationSize-whenSimple: func [] [
      ;001 0 0001 unchanged 1 byte
      originalDeltaStream: 2#{00100001}
      deltaItr: make deltaIterator [deltaStream: copy originalDeltaStream]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals originalDeltaStream deltaItr/operationBinary
      redunit/assert-equals deltaItr/operation/unchanged deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-parseNext-parsesOperationSize-whenOpSizeSize2: func [] [
      ;001 1 0010 00000000 00000001 unchanged 2 bytes op size size which has an op size of 1
      originalDeltaStream: 2#{001100100000000000000001}
      deltaItr: make deltaIterator [deltaStream: copy originalDeltaStream]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals originalDeltaStream deltaItr/operationBinary
      redunit/assert-equals deltaItr/operation/unchanged deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-parseNext-parsesOperationSize-whenOpSizeSize4: func [] [
      ;001 1 0100 00000000 00000000 00000000 00000001 unchanged 4 bytes op size size which has an op size of 1
      originalDeltaStream: 2#{0011010000000000000000000000000000000001}
      deltaItr: make deltaIterator [deltaStream: copy originalDeltaStream]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals originalDeltaStream deltaItr/operationBinary
      redunit/assert-equals deltaItr/operation/unchanged deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-parseNext-throws-givenAddOp0Empty: func [] [
      ;000 0 0000 add remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{00000000}]
      expected: "Invalid: Add operation must add bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenAddOp1Empty: func [] [
      ;000 0 0001 add 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{00000001}]
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenAddOp0: func [] [
      ;000 0 0000 add remaining bytes (11111111)
      deltaItr: make deltaIterator [deltaStream: 2#{0000000011111111}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/add deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{11111111} deltaItr/newData
   ]

   test-parseNext-parses-givenAddOp1: func [] [
      ;000 0 0001 add 1 byte (11111111)
      deltaItr: make deltaIterator [deltaStream: 2#{0000000111111111}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/add deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{11111111} deltaItr/newData
   ]

   test-parseNext-throws-givenUnchangeOp0ExtraDelta: func [] [
      ;001 0 0000 remaining unchanged aka done
      deltaItr: make deltaIterator [deltaStream: 2#{0010000000100000}]
      expected: "Invalid: Unaccounted for bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenUnchangeOp0: func [] [
      ;001 0 0000 remaining unchanged aka done
      deltaItr: make deltaIterator [deltaStream: 2#{00100000}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/unchanged deltaItr/operationType
      redunit/assert-equals 0 deltaItr/operationSize
   ]

   test-parseNext-parses-givenUnchangeOp1: func [] [
      ;001 0 0001 unchanged 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{00100001}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/unchanged deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-parseNext-throws-givenReplaceOp0Empty: func [] [
      ;010 0 0000 replace remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{01000000}]
      expected: "Invalid: Replace operation must replace bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenReplaceOp1ShortDelta: func [] [
      ;010 0 0001 replace 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{01000001}]
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenReplaceOp0: func [] [
      ;010 0 0000 replace remaining (11111111)
      deltaItr: make deltaIterator [deltaStream: 2#{0100000011111111}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/replace deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{11111111} deltaItr/newData
   ]

   test-parseNext-parses-givenReplaceOp1: func [] [
      ;010 0 0001 replace 1 byte (11111111)
      deltaItr: make deltaIterator [deltaStream: 2#{0100000111111111}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/replace deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{11111111} deltaItr/newData
   ]

   test-parseNext-throws-givenRemoveOp0Extra: func [] [
      ;011 0 0000 remove remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{0110000001100000}]
      expected: "Invalid: Unaccounted for bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenRemoveOp0: func [] [
      ;011 0 0000 remove remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{01100000}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/remove deltaItr/operationType
      redunit/assert-equals 0 deltaItr/operationSize
   ]

   test-parseNext-parses-givenRemoveOp1: func [] [
      ;011 0 0001 remove 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{01100001}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/remove deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-parseNext-throws-givenReversibleReplaceOp0Odd: func [] [
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000 but no new
      deltaItr: make deltaIterator [deltaStream: 2#{1100000000000000}]
      expected: "Invalid: deltaStream must have an even number of bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenReversibleReplaceOp0Empty: func [] [
      ;110 0 0000 reversible replace remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{11000000}]
      expected: "Invalid: Replace operation must replace bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenReversibleReplaceOp1EmptyDelta: func [] [
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000 but no new
      deltaItr: make deltaIterator [deltaStream: 2#{1100000100000000}]
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenReversibleReplaceOp0: func [] [
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000 new: 11111111
      deltaItr: make deltaIterator [deltaStream: 2#{110000000000000011111111}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/reversibleReplace deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{00000000} deltaItr/oldData
      redunit/assert-equals 2#{11111111} deltaItr/newData
   ]

   test-parseNext-parses-givenReversibleReplaceOp1: func [] [
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000 new: 11111111
      deltaItr: make deltaIterator [deltaStream: 2#{110000010000000011111111}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/reversibleReplace deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{00000000} deltaItr/oldData
      redunit/assert-equals 2#{11111111} deltaItr/newData
   ]

   test-parseNext-throws-givenReversibleRemoveOp0Empty: func [] [
      ;111 0 0000 reversible remove remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{11100000}]
      expected: "Invalid: Remove operation must remove bytes"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-givenReversibleRemoveOp1EmptyDelta: func [] [
      ;111 0 0001 reversible remove 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{11100001}]
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-parses-givenReversibleRemoveOp0: func [] [
      ;111 0 0000 reversible remove remaining bytes
      ;old: 00000000
      deltaItr: make deltaIterator [deltaStream: 2#{1110000000000000}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/reversibleRemove deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{00000000} deltaItr/oldData
   ]

   test-parseNext-parses-givenReversibleRemoveOp1: func [] [
      ;111 0 0001 reversible remove 1 byte
      ;old: 00000000
      deltaItr: make deltaIterator [deltaStream: 2#{1110000100000000}]
      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals deltaItr/operation/reversibleRemove deltaItr/operationType
      redunit/assert-equals 1 deltaItr/operationSize
      redunit/assert-equals 2#{00000000} deltaItr/oldData
   ]

   test-parseNext-throws-whenInputOp4: func [] [
      deltaItr: make deltaIterator [deltaStream: 2#{10000000}]
      expected: "Invalid: operations 4-5 don't exist"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-parseNext-throws-whenInputOp5: func [] [
      deltaItr: make deltaIterator [deltaStream: 2#{10100000}]
      expected: "Invalid: operations 4-5 don't exist"

      actual: catch [deltaItr/parseNext none]

      redunit/assert-equals expected actual
   ]

   test-withInputStream-doesNothing-givenAdd: func [] [
      ;000 0 0000 add remaining bytes (11111111)
      inputStream: #{}
      deltaItr: make deltaIterator [deltaStream: 2#{0000000011111111}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals none actual
   ]

   test-withInputStream-doesNothing-givenUnchangedOp0Empty: func [] [
      inputStream: #{}
      ;001 0 0000 remaining unchanged aka done
      deltaItr: make deltaIterator [deltaStream: 2#{00100000}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals none actual
      redunit/assert-equals 0 deltaItr/operationSize
   ]

   test-withInputStream-setsSize-givenUnchangedOp0Input: func [] [
      inputStream: #{1122}
      ;001 0 0000 remaining unchanged aka done
      deltaItr: make deltaIterator [deltaStream: 2#{00100000}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals none actual
      redunit/assert-equals 2 deltaItr/operationSize
   ]

   test-withInputStream-throws-givenUnchangeOp1Empty: func [] [
      inputStream: #{}
      ;001 0 0001 unchanged 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{00100001}]
      expected: "Invalid: Not enough bytes remaining in inputStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals expected actual
   ]

   test-withInputStream-doesNothing-givenValidReplace: func [] [
      inputStream: #{00}
      ;010 0 0001 replace 1 byte (11111111)
      deltaItr: make deltaIterator [deltaStream: 2#{0100000111111111}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals none actual
   ]

   test-withInputStream-throws-givenReplaceOp1ShortInput: func [] [
      inputStream: #{}
      ;010 0 0001 replace 1 byte (11111111)
      deltaItr: make deltaIterator [deltaStream: 2#{0100000111111111}]
      expected: "Invalid: Not enough bytes remaining in inputStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals expected actual
   ]

   test-withInputStream-doesNothing-givenRemoveOp1: func [] [
      inputStream: #{11}
      ;011 0 0001 remove 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{01100001}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals none actual
   ]

   test-withInputStream-setsSize-givenRemoveOp0: func [] [
      inputStream: #{00}
      ;011 0 0000 remove remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{01100000}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals none actual
      redunit/assert-equals 1 deltaItr/operationSize
   ]

   test-withInputStream-throws-givenRemoveOp0Empty: func [] [
      inputStream: #{}
      ;011 0 0000 remove remaining bytes
      deltaItr: make deltaIterator [deltaStream: 2#{01100000}]
      expected: "Invalid: Remove operation must remove bytes"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals expected actual
   ]

   test-withInputStream-throws-givenRemoveOp1Empty: func [] [
      inputStream: #{}
      ;011 0 0001 remove 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{01100001}]
      expected: "Invalid: Not enough bytes remaining in inputStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals expected actual
   ]

   test-withInputStream-doesNothing-givenValidReversibleReplace: func [] [
      inputStream: 2#{00000000}
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000, new: 11111111
      deltaItr: make deltaIterator [deltaStream: 2#{110000010000000011111111}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals none actual
   ]

   test-withInputStream-throws-givenReversibleReplaceEmptyInput: func [] [
      inputStream: #{}
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000, new: 11111111
      deltaItr: make deltaIterator [deltaStream: 2#{110000010000000011111111}]
      expected: "Invalid: Not enough bytes remaining in inputStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals expected actual
   ]

   test-withInputStream-throws-givenReversibleReplaceNoMatch: func [] [
      inputStream: 2#{11000001}
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000, new: 11111111
      deltaItr: make deltaIterator [deltaStream: 2#{110000010000000011111111}]
      expected: "Invalid: bytes removed from inputStream didn't match deltaStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals expected actual
   ]

   test-withInputStream-doesNothing-givenValidReversibleRemove: func [] [
      inputStream: 2#{00000000}
      ;111 0 0001 reversible remove 1 byte
      ;old: 00000000
      deltaItr: make deltaIterator [deltaStream: 2#{1110000100000000}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals none actual
   ]

   test-withInputStream-throws-givenReversibleRemoveEmptyInput: func [] [
      inputStream: #{}
      ;111 0 0001 reversible remove 1 byte
      ;old: 00000000
      deltaItr: make deltaIterator [deltaStream: 2#{1110000100000000}]
      expected: "Invalid: Not enough bytes remaining in inputStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals expected actual
   ]

   test-withInputStream-throws-givenReversibleRemoveNoMatch: func [] [
      inputStream: 2#{11000001}
      ;111 0 0001 reversible remove 1 byte
      ;old: 00000000
      deltaItr: make deltaIterator [deltaStream: 2#{1110000100000000}]
      expected: "Invalid: bytes removed from inputStream didn't match deltaStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals expected actual
   ]

   test-withInputStream-doesNothing-whenNonTerminalExtraInput: func [] [
      inputStream: #{1122}
      ;001 0 0001 unchanged 1 byte. twice but only first is parsed
      deltaItr: make deltaIterator [deltaStream: 2#{0010000100100001}]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals none actual
   ]

   test-withInputStream-throws-whenInputHasExtraBytes: func [] [
      inputStream: #{1122}
      ;001 0 0001 unchanged 1 byte
      deltaItr: make deltaIterator [deltaStream: 2#{00100001}]
      expected: "Invalid: Unaccounted for bytes remaining in inputStream"

      redunit/assert-equals none catch [deltaItr/parseNext none]
      actual: catch [deltaItr/withInputStream inputStream]

      redunit/assert-equals expected actual
   ]

   test-operationAndData-returns-whenMinimal: func [] [
      ;001 0 0000 remaining unchanged aka done
      originalDeltaStream: 2#{00100000}
      deltaItr: make deltaIterator [deltaStream: copy originalDeltaStream]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals originalDeltaStream catch [deltaItr/operationAndData]
   ]

   test-operationAndData-returns-whenMax: func [] [
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000 new: 11111111
      originalDeltaStream: 2#{110000010000000011111111}
      deltaItr: make deltaIterator [deltaStream: copy originalDeltaStream]

      redunit/assert-equals none catch [deltaItr/parseNext none]
      redunit/assert-equals originalDeltaStream catch [deltaItr/operationAndData]
   ]
]
