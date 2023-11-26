Red [
   Title: "tests"
]

context [
   setup: func [
      "Initialize/Reload context before each test"
   ] [
      do %../../main/red/main.red
   ]

   test-applyDelta-doesNothing-givenOpSizeUnchanged: func [] [
      inputStream: #{cafe}
      ;001 1 0001 00000010 unchanged 1 byte op size size which has an op size of 2
      deltaStream: 2#{0011000100000010}
      expected: #{cafe}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesAdd-givenAddOp0: func [] [
      inputStream: #{}
      ;000 0 0000 add remaining bytes
      deltaStream: #{00cafe}
      expected: #{cafe}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throw-givenAddOp0Empty: func [] [
      inputStream: #{}
      ;000 0 0000 add remaining bytes
      deltaStream: #{00}
      expected: "Invalid: Add operation must add bytes"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throw-givenAddOp1Empty: func [] [
      inputStream: #{}
      ;000 0 0001 add 1 byte
      deltaStream: 2#{00000001}
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesAdd-givenAdd: func [] [
      inputStream: #{cafe}
      ;000 0 0001 add 1 then the byte (1111 1111)
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{000000011111111100100000}
      expected: #{ffcafe}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesNothing-givenDoneExtraInput: func [] [
      inputStream: #{cafe}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: #{cafe}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesNothing-givenDoneEmptyInput: func [] [
      inputStream: #{}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: #{}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throws-givenUnchangeOp0ExtraDelta: func [] [
      inputStream: #{cafe}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{0010000000100000}
      expected: "Invalid: Unaccounted for bytes remaining in deltaStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throws-givenUnchangeOp2Empty: func [] [
      inputStream: #{ca}
      ;001 0 0010 unchanged 2 bytes
      deltaStream: 2#{00100010}
      expected: "Invalid: Not enough bytes remaining in inputStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesNothing-given2Unchanged: func [] [
      inputStream: #{cafe}
      ;001 0 0001 unchanged 1 byte. twice
      deltaStream: 2#{0010000100100001}
      expected: #{cafe}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesReplace-givenReplaceOp0: func [] [
      inputStream: #{cafe}
      ;010 0 0000 replace remaining bytes (1111 1111 0000 0000)
      deltaStream: 2#{010000001111111100000000}
      expected: #{ff00}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throws-givenReplaceOp0Empty: func [] [
      inputStream: #{}
      ;010 0 0000 replace remaining bytes
      deltaStream: 2#{01000000}
      expected: "Invalid: Replace operation must replace bytes"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throws-givenReplaceOp0DiffRemaining: func [] [
      inputStream: #{cafe}
      ;010 0 0000 replace remaining bytes (1111 1111)
      deltaStream: 2#{0100000011111111}
      expected: "Invalid: inputStream and deltaStream have different number of remaining bytes"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throws-givenReplaceOp1ShortDelta: func [] [
      inputStream: #{cafe}
      ;010 0 0001 replace 1 byte
      deltaStream: 2#{01000001}
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throws-givenReplaceOp1ShortInput: func [] [
      inputStream: #{}
      ;010 0 0001 replace 1 byte (1111 1111)
      deltaStream: 2#{0100000111111111}
      expected: "Invalid: Not enough bytes remaining in inputStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesReplace-givenReplaceOp1: func [] [
      inputStream: #{ca}
      ;010 0 0001 replace 1 byte (1111 1111)
      deltaStream: 2#{0100000111111111}
      expected: #{ff}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesRemove-givenRemoveOp0: func [] [
      inputStream: #{cafe}
      ;011 0 0000 remove remaining bytes
      deltaStream: 2#{01100000}
      expected: #{}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throw-givenRemoveOp0Extra: func [] [
      inputStream: #{cafe}
      ;011 0 0000 remove remaining bytes
      deltaStream: 2#{0110000001100000}
      expected: "Invalid: Unaccounted for bytes remaining in deltaStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throw-givenRemoveOp0Empty: func [] [
      inputStream: #{}
      ;011 0 0000 remove remaining bytes
      deltaStream: 2#{01100000}
      expected: "Invalid: Remove operation must remove bytes"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throw-givenRemoveOp1Empty: func [] [
      inputStream: #{}
      ;011 0 0001 remove 1 byte
      deltaStream: 2#{01100001}
      expected: "Invalid: Not enough bytes remaining in inputStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesRemove-givenRemove: func [] [
      inputStream: #{ca}
      ;011 0 0001 remove 1 byte
      deltaStream: 2#{01100001}
      expected: #{}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesReplace-givenReversibleReplaceOp0: func [] [
      inputStream: #{00}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000000000000011111111}
      expected: #{ff}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throw-givenReversibleReplaceOp0Empty: func [] [
      inputStream: #{}
      ;110 0 0000 reversible replace remaining bytes
      deltaStream: 2#{11000000}
      expected: "Invalid: Replace operation must replace bytes"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throw-givenReversibleReplaceOp0DiffLength: func [] [
      inputStream: #{0011}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000000000000011111111}
      expected: "Invalid: deltaStream must have twice the remaining bytes as inputStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throw-givenReversibleReplaceOp1EmptyDelta: func [] [
      inputStream: #{}
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000 but no new
      deltaStream: 2#{1100000100000000}
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throw-givenReversibleReplaceOp1EmptyInput: func [] [
      inputStream: #{}
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000010000000011111111}
      expected: "Invalid: Not enough bytes remaining in inputStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throw-givenReversibleReplaceOp1NoMatch: func [] [
      inputStream: #{ca}
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000010000000011111111}
      expected: "Invalid: bytes removed from inputStream didn't match deltaStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesReplace-givenReversibleReplace: func [] [
      inputStream: #{00}
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000010000000011111111}
      expected: #{ff}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesRemove-givenReversibleRemoveOp0: func [] [
      inputStream: #{00}
      ;111 0 0000 reversible remove remaining bytes (00000000)
      deltaStream: 2#{1110000000000000}
      expected: #{}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throw-givenReversibleRemoveOp0Empty: func [] [
      inputStream: #{}
      ;111 0 0000 reversible remove remaining bytes
      deltaStream: 2#{11100000}
      expected: "Invalid: Remove operation must remove bytes"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throw-givenReversibleRemoveOp0DiffLength: func [] [
      inputStream: #{cafebabe}
      ;111 0 0000 reversible remove remaining bytes (01100000)
      deltaStream: 2#{1110000001100000}
      expected: "Invalid: inputStream and deltaStream have different number of remaining bytes"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throw-givenReversibleRemoveOp1EmptyDelta: func [] [
      inputStream: #{}
      ;111 0 0001 reversible remove 1 byte
      deltaStream: 2#{11100001}
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throw-givenReversibleRemoveOp1EmptyInput: func [] [
      inputStream: #{}
      ;111 0 0001 reversible remove 1 byte (00000000)
      deltaStream: 2#{1110000100000000}
      expected: "Invalid: Not enough bytes remaining in inputStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throw-givenReversibleRemoveOp1NoMatch: func [] [
      inputStream: #{ca}
      ;111 0 0001 reversible remove 1 byte (00000000)
      deltaStream: 2#{1110000100000000}
      expected: "Invalid: bytes removed from inputStream didn't match deltaStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesRemove-givenReversibleRemove: func [] [
      inputStream: #{00}
      ;111 0 0001 reversible remove 1 byte (00000000)
      deltaStream: 2#{1110000100000000}
      expected: #{}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throws-whenInputOp4: func [] [
      inputStream: #{cafe}
      deltaStream: 2#{10000000}
      expected: "Invalid: operations 4-5 don't exist"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throws-whenInputOp5: func [] [
      inputStream: #{cafe}
      deltaStream: 2#{10100000}
      expected: "Invalid: operations 4-5 don't exist"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throws-whenInputHasExtraBytes: func [] [
      inputStream: #{cafe}
      ;001 0 0001 unchanged 1 byte
      deltaStream: 2#{00100001}
      expected: "Invalid: Unaccounted for bytes remaining in inputStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]


   test-makeDeltaReversible-doesNothing-givenOpSizeUnchanged: func [] [
      inputStream: #{cafe}
      ;001 1 0001 00000010 unchanged 1 byte op size size which has an op size of 2
      deltaStream: 2#{0011000100000010}
      expected: deltaStream

      actual: main/makeDeltaReversible inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-doesAdd-givenAddOp0: func [] [
      inputStream: #{}
      ;000 0 0000 add remaining bytes
      deltaStream: #{00cafe}
      expected: deltaStream

      actual: main/makeDeltaReversible inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throw-givenAddOp0Empty: func [] [
      inputStream: #{}
      ;000 0 0000 add remaining bytes
      deltaStream: #{00}
      expected: "Invalid: Add operation must add bytes"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throw-givenAddOp1Empty: func [] [
      inputStream: #{}
      ;000 0 0001 add 1 byte
      deltaStream: 2#{00000001}
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-doesAdd-givenAdd: func [] [
      inputStream: #{cafe}
      ;000 0 0001 add 1 then the byte (1111 1111)
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{000000011111111100100000}
      expected: deltaStream

      actual: main/makeDeltaReversible inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-doesNothing-givenDoneExtraInput: func [] [
      inputStream: #{cafe}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: deltaStream

      actual: main/makeDeltaReversible inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-doesNothing-givenDoneEmptyInput: func [] [
      inputStream: #{}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: deltaStream

      actual: main/makeDeltaReversible inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throws-givenUnchangeOp0ExtraDelta: func [] [
      inputStream: #{cafe}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{0010000000100000}
      expected: "Invalid: Unaccounted for bytes remaining in deltaStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throws-givenUnchangeOp2Empty: func [] [
      inputStream: #{ca}
      ;001 0 0010 unchanged 2 bytes
      deltaStream: 2#{00100010}
      expected: "Invalid: Not enough bytes remaining in inputStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-doesNothing-given2Unchanged: func [] [
      inputStream: #{cafe}
      ;001 0 0001 unchanged 1 byte. twice
      deltaStream: 2#{0010000100100001}
      expected: deltaStream

      actual: main/makeDeltaReversible inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-doesReplace-givenReplaceOp0: func [] [
      inputStream: 2#{1100101011111110}
      ;010 0 0000 replace remaining bytes (1111 1111 0000 0000)
      deltaStream: 2#{010000001111111100000000}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 1100101011111110 new: 11111111 00000000
      expected: 2#{1100000011001010111111101111111100000000}

      actual: main/makeDeltaReversible inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throws-givenReplaceOp0Empty: func [] [
      inputStream: #{}
      ;010 0 0000 replace remaining bytes
      deltaStream: 2#{01000000}
      expected: "Invalid: Replace operation must replace bytes"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throws-givenReplaceOp0DiffRemaining: func [] [
      inputStream: #{cafe}
      ;010 0 0000 replace remaining bytes (1111 1111)
      deltaStream: 2#{0100000011111111}
      expected: "Invalid: inputStream and deltaStream have different number of remaining bytes"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throws-givenReplaceOp1ShortDelta: func [] [
      inputStream: #{cafe}
      ;010 0 0001 replace 1 byte
      deltaStream: 2#{01000001}
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throws-givenReplaceOp1ShortInput: func [] [
      inputStream: #{}
      ;010 0 0001 replace 1 byte (1111 1111)
      deltaStream: 2#{0100000111111111}
      expected: "Invalid: Not enough bytes remaining in inputStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-doesReplace-givenReplaceOp1: func [] [
      inputStream: 2#{11001010}
      ;010 0 0001 replace 1 byte (1111 1111)
      deltaStream: 2#{0100000111111111}
      ;110 0 0001 reversible replace 1 byte
      ;old: 11001010 new: 11111111
      expected: 2#{110000011100101011111111}

      actual: main/makeDeltaReversible inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-doesRemove-givenRemoveOp0: func [] [
      inputStream: 2#{11001010}
      ;011 0 0000 remove remaining bytes
      deltaStream: 2#{01100000}
      ;111 0 0000 reversible remove remaining bytes
      ;old: 11001010
      expected: 2#{1110000011001010}

      actual: main/makeDeltaReversible inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throw-givenRemoveOp0Extra: func [] [
      inputStream: #{cafe}
      ;011 0 0000 remove remaining bytes
      deltaStream: 2#{0110000001100000}
      expected: "Invalid: Unaccounted for bytes remaining in deltaStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throw-givenRemoveOp0Empty: func [] [
      inputStream: #{}
      ;011 0 0000 remove remaining bytes
      deltaStream: 2#{01100000}
      expected: "Invalid: Remove operation must remove bytes"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throw-givenRemoveOp1Empty: func [] [
      inputStream: #{}
      ;011 0 0001 remove 1 byte
      deltaStream: 2#{01100001}
      expected: "Invalid: Not enough bytes remaining in inputStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-doesRemove-givenRemove: func [] [
      inputStream: 2#{11001010}
      ;011 0 0001 remove 1 byte
      deltaStream: 2#{01100001}
      ;111 0 0001 reversible remove 1 byte
      ;old: 11001010
      expected: 2#{1110000111001010}

      actual: main/makeDeltaReversible inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-doesReplace-givenReversibleReplaceOp0: func [] [
      inputStream: #{00}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000000000000011111111}
      expected: deltaStream

      actual: main/makeDeltaReversible inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throw-givenReversibleReplaceOp0Empty: func [] [
      inputStream: #{}
      ;110 0 0000 reversible replace remaining bytes
      deltaStream: 2#{11000000}
      expected: "Invalid: Replace operation must replace bytes"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throw-givenReversibleReplaceOp0DiffLength: func [] [
      inputStream: #{0011}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000000000000011111111}
      expected: "Invalid: deltaStream must have twice the remaining bytes as inputStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throw-givenReversibleReplaceOp1EmptyDelta: func [] [
      inputStream: #{}
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000 but no new
      deltaStream: 2#{1100000100000000}
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throw-givenReversibleReplaceOp1EmptyInput: func [] [
      inputStream: #{}
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000010000000011111111}
      expected: "Invalid: Not enough bytes remaining in inputStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throw-givenReversibleReplaceOp1NoMatch: func [] [
      inputStream: #{ca}
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000010000000011111111}
      expected: "Invalid: bytes removed from inputStream didn't match deltaStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-doesReplace-givenReversibleReplace: func [] [
      inputStream: #{00}
      ;110 0 0001 reversible replace 1 byte
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000010000000011111111}
      expected: deltaStream

      actual: main/makeDeltaReversible inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-doesRemove-givenReversibleRemoveOp0: func [] [
      inputStream: #{00}
      ;111 0 0000 reversible remove remaining bytes (00000000)
      deltaStream: 2#{1110000000000000}
      expected: deltaStream

      actual: main/makeDeltaReversible inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throw-givenReversibleRemoveOp0Empty: func [] [
      inputStream: #{}
      ;111 0 0000 reversible remove remaining bytes
      deltaStream: 2#{11100000}
      expected: "Invalid: Remove operation must remove bytes"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throw-givenReversibleRemoveOp0DiffLength: func [] [
      inputStream: #{cafebabe}
      ;111 0 0000 reversible remove remaining bytes (01100000)
      deltaStream: 2#{1110000001100000}
      expected: "Invalid: inputStream and deltaStream have different number of remaining bytes"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throw-givenReversibleRemoveOp1EmptyDelta: func [] [
      inputStream: #{}
      ;111 0 0001 reversible remove 1 byte
      deltaStream: 2#{11100001}
      expected: "Invalid: Not enough bytes remaining in deltaStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throw-givenReversibleRemoveOp1EmptyInput: func [] [
      inputStream: #{}
      ;111 0 0001 reversible remove 1 byte (00000000)
      deltaStream: 2#{1110000100000000}
      expected: "Invalid: Not enough bytes remaining in inputStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throw-givenReversibleRemoveOp1NoMatch: func [] [
      inputStream: #{ca}
      ;111 0 0001 reversible remove 1 byte (00000000)
      deltaStream: 2#{1110000100000000}
      expected: "Invalid: bytes removed from inputStream didn't match deltaStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-doesRemove-givenReversibleRemove: func [] [
      inputStream: #{00}
      ;111 0 0001 reversible remove 1 byte (00000000)
      deltaStream: 2#{1110000100000000}
      expected: deltaStream

      actual: main/makeDeltaReversible inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throws-whenInputOp4: func [] [
      inputStream: #{cafe}
      deltaStream: 2#{10000000}
      expected: "Invalid: operations 4-5 don't exist"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throws-whenInputOp5: func [] [
      inputStream: #{cafe}
      deltaStream: 2#{10100000}
      expected: "Invalid: operations 4-5 don't exist"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-throws-whenInputHasExtraBytes: func [] [
      inputStream: #{cafe}
      ;001 0 0001 unchanged 1 byte
      deltaStream: 2#{00100001}
      expected: "Invalid: Unaccounted for bytes remaining in inputStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]
]
