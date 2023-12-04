Red [
   Title: "tests for main"
]

context [
   setup: func [
      "Initialize/Reload context before each test"
   ] [
      do %../../main/red/main.red
   ]

   test-applyDelta-loops-givenMultipleDeltaOps: func [] [
      inputStream: #{1122}
      ;001 0 0001 unchanged 1 byte. twice
      deltaStream: 2#{0010000100100001}
      expected: #{1122}

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-validatesInputStream-givenInvalidInputStream: func [] [
      inputStream: #{}
      ;011 0 0001 remove 1 byte
      deltaStream: 2#{01100001}
      expected: "Invalid: Not enough bytes remaining in inputStream"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesAdd-givenAdd: func [] [
      inputStream: #{}
      ;000 0 0001 add 1 byte (11111111)
      deltaStream: 2#{0000000111111111}
      expected: 2#{11111111}

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesUnchanged-givenUnchanged: func [] [
      inputStream: #{cafe}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: #{cafe}

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesUnchanged-givenUnchangedEmptyInput: func [] [
      inputStream: #{}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: #{}

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesReplace-givenReplace: func [] [
      inputStream: #{cafe}
      ;010 0 0000 replace remaining bytes (11111111 00000000)
      deltaStream: 2#{010000001111111100000000}
      expected: 2#{1111111100000000}

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesRemove-givenRemove: func [] [
      inputStream: #{cafe}
      ;011 0 0000 remove remaining bytes
      deltaStream: 2#{01100000}
      expected: #{}

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesReplace-givenReversibleReplace: func [] [
      inputStream: 2#{00000000}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000000000000011111111}
      expected: 2#{11111111}

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesRemove-givenReversibleRemove: func [] [
      inputStream: 2#{00000000}
      ;111 0 0000 reversible remove remaining bytes (00000000)
      deltaStream: 2#{1110000000000000}
      expected: #{}

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-loops-givenMultipleDeltaOps: func [] [
      inputStream: #{1122}
      ;001 0 0001 unchanged 1 byte. twice
      deltaStream: 2#{0010000100100001}
      expected: copy deltaStream

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-validatesInputStream-givenInvalidInputStream: func [] [
      inputStream: #{}
      ;011 0 0001 remove 1 byte
      deltaStream: 2#{01100001}
      expected: "Invalid: Not enough bytes remaining in inputStream"

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenAdd: func [] [
      inputStream: #{}
      ;000 0 0000 add remaining bytes (11111111)
      deltaStream: 2#{0000000011111111}
      expected: copy deltaStream

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenUnchanged: func [] [
      inputStream: #{cafe}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: copy deltaStream

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenUnchangedEmptyInput: func [] [
      inputStream: #{}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: copy deltaStream

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-makesReversible-givenReplace: func [] [
      inputStream: 2#{1100101011111110}
      ;010 0 0000 replace remaining bytes (11111111 00000000)
      deltaStream: 2#{010000001111111100000000}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 11001010 11111110 new: 11111111 00000000
      expected: 2#{1100000011001010111111101111111100000000}

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-makesReversible-givenRemove: func [] [
      inputStream: 2#{11001010}
      ;011 0 0000 remove remaining bytes
      deltaStream: 2#{01100000}
      ;111 0 0000 reversible remove remaining bytes
      ;old: 11001010
      expected: 2#{1110000011001010}

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenReversibleReplace: func [] [
      inputStream: 2#{00000000}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000000000000011111111}
      expected: copy deltaStream

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenReversibleRemove: func [] [
      inputStream: 2#{00000000}
      ;111 0 0000 reversible remove remaining bytes (00000000)
      deltaStream: 2#{1110000000000000}
      expected: copy deltaStream

      actual: catch [main/makeDeltaReversible inputStream deltaStream]

      redunit/assert-equals expected actual
   ]
]
