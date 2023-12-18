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
      beforeStream: #{1122}
      ;001 0 0001 unchanged 1 byte. twice
      deltaStream: 2#{0010000100100001}
      expected: #{1122}

      actual: catch [main/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-validatesBeforeStream-givenInvalidBeforeStream: func [] [
      beforeStream: #{}
      ;011 0 0001 remove 1 byte
      deltaStream: 2#{01100001}
      expected: "Invalid: Not enough bytes remaining in beforeStream"

      actual: catch [main/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesAdd-givenAdd: func [] [
      beforeStream: #{}
      ;000 0 0001 add 1 byte (11111111)
      deltaStream: 2#{0000000111111111}
      expected: 2#{11111111}

      actual: catch [main/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesUnchanged-givenUnchanged: func [] [
      beforeStream: #{cafe}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: #{cafe}

      actual: catch [main/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesUnchanged-givenUnchangedEmptyBefore: func [] [
      beforeStream: #{}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: #{}

      actual: catch [main/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesReplace-givenReplace: func [] [
      beforeStream: #{cafe}
      ;010 0 0000 replace remaining bytes (11111111 00000000)
      deltaStream: 2#{010000001111111100000000}
      expected: 2#{1111111100000000}

      actual: catch [main/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesRemove-givenRemove: func [] [
      beforeStream: #{cafe}
      ;011 0 0000 remove remaining bytes
      deltaStream: 2#{01100000}
      expected: #{}

      actual: catch [main/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesReplace-givenReversibleReplace: func [] [
      beforeStream: 2#{00000000}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000000000000011111111}
      expected: 2#{11111111}

      actual: catch [main/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesRemove-givenReversibleRemove: func [] [
      beforeStream: 2#{00000000}
      ;111 0 0000 reversible remove remaining bytes (00000000)
      deltaStream: 2#{1110000000000000}
      expected: #{}

      actual: catch [main/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-loops-givenMultipleDeltaOps: func [] [
      ;001 0 0001 unchanged 1 byte. twice
      deltaStream: 2#{0010000100100001}
      expected: copy deltaStream

      actual: catch [main/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-keepsData-givenAdd: func [] [
      ;000 0 0000 add remaining bytes (11111111)
      deltaStream: 2#{0000000011111111}
      expected: copy deltaStream

      actual: catch [main/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-keepsData-givenUnchanged: func [] [
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: copy deltaStream

      actual: catch [main/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-keepsData-givenReplace: func [] [
      ;010 0 0000 replace remaining bytes (11111111 00000000)
      deltaStream: 2#{010000001111111100000000}
      expected: copy deltaStream

      actual: catch [main/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-keepsData-givenRemove: func [] [
      ;011 0 0000 remove remaining bytes
      deltaStream: 2#{01100000}
      expected: copy deltaStream

      actual: catch [main/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-makesNonReversible-givenReversibleReplace: func [] [
      ;110 1 0001 00000001 reversible replace 1 byte
      ;old: 00000000, new: 11111111
      deltaStream: 2#{11010001000000010000000011111111}
      ;010 1 0001 00000001 replace 1 byte
      ;new: 11111111
      expected: 2#{010100010000000111111111}

      actual: catch [main/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-makesNonReversible-givenReversibleRemove: func [] [
      ;111 1 0001 00000001 reversible remove 1 byte (00000000)
      deltaStream: 2#{111100010000000100000000}
      ;011 1 0001 00000001 remove 1 byte
      expected: 2#{0111000100000001}

      actual: catch [main/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-loops-givenMultipleDeltaOps: func [] [
      beforeStream: #{1122}
      ;001 0 0001 unchanged 1 byte. twice
      deltaStream: 2#{0010000100100001}
      expected: copy deltaStream

      actual: catch [main/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-validatesBeforeStream-givenInvalidBeforeStream: func [] [
      beforeStream: #{}
      ;011 0 0001 remove 1 byte
      deltaStream: 2#{01100001}
      expected: "Invalid: Not enough bytes remaining in beforeStream"

      actual: catch [main/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenAdd: func [] [
      beforeStream: #{}
      ;000 0 0000 add remaining bytes (11111111)
      deltaStream: 2#{0000000011111111}
      expected: copy deltaStream

      actual: catch [main/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenUnchanged: func [] [
      beforeStream: #{cafe}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: copy deltaStream

      actual: catch [main/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenUnchangedEmptyBefore: func [] [
      beforeStream: #{}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: copy deltaStream

      actual: catch [main/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-makesReversible-givenReplace: func [] [
      beforeStream: 2#{1100101011111110}
      ;010 1 0001 00000010 replace 2 bytes (11111111 00000000)
      deltaStream: 2#{01010001000000101111111100000000}
      ;110 1 0001 00000010 reversible replace 2 bytes
      ;old: 11001010 11111110 new: 11111111 00000000
      expected: 2#{110100010000001011001010111111101111111100000000}

      actual: catch [main/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-makesReversible-givenRemove: func [] [
      beforeStream: 2#{11001010}
      ;011 1 0001 00000001 remove 1 byte
      deltaStream: 2#{0111000100000001}
      ;111 1 0001 00000001 reversible remove 1 byte
      ;old: 11001010
      expected: 2#{111100010000000111001010}

      actual: catch [main/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenReversibleReplace: func [] [
      beforeStream: 2#{00000000}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000000000000011111111}
      expected: copy deltaStream

      actual: catch [main/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenReversibleRemove: func [] [
      beforeStream: 2#{00000000}
      ;111 0 0000 reversible remove remaining bytes (00000000)
      deltaStream: 2#{1110000000000000}
      expected: copy deltaStream

      actual: catch [main/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-loops-givenMultipleDeltaOps: func [] [
      afterStream: #{1122}
      ;001 0 0001 unchanged 1 byte. twice
      deltaStream: 2#{0010000100100001}
      expected: #{1122}

      actual: catch [main/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-validatesAfterStream-givenInvalidAfterStream: func [] [
      afterStream: #{}
      ;000 0 0001 add 1 byte (11111111)
      deltaStream: 2#{0000000111111111}
      expected: "Invalid: Not enough bytes remaining in afterStream"

      actual: catch [main/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-undoesAdd-givenAdd: func [] [
      afterStream: 2#{11111111}
      ;000 0 0001 add 1 byte (11111111)
      deltaStream: 2#{0000000111111111}
      expected: #{}

      actual: catch [main/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-validatesAdd-givenAdd: func [] [
      afterStream: 2#{11011011}
      ;000 0 0001 add 1 byte (11111111)
      deltaStream: 2#{0000000111111111}
      expected: "Invalid: bytes removed from afterStream didn't match deltaStream"

      actual: catch [main/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-undoesUnchanged-givenUnchanged: func [] [
      afterStream: #{cafe}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: #{cafe}

      actual: catch [main/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-undoesUnchanged-givenUnchangedEmptyAfter: func [] [
      afterStream: #{}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: #{}

      actual: catch [main/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-throws-givenReplace: func [] [
      afterStream: 2#{1111111100000000}
      ;010 0 0000 replace remaining bytes (11111111 00000000)
      deltaStream: 2#{010000001111111100000000}
      expected: "Invalid: deltaStream isn't reversible"

      actual: catch [main/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-throws-givenRemove: func [] [
      afterStream: #{}
      ;011 0 0000 remove remaining bytes
      deltaStream: 2#{01100000}
      expected: "Invalid: deltaStream isn't reversible"

      actual: catch [main/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-undoesReplace-givenReversibleReplace: func [] [
      afterStream: 2#{11111111}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000000000000011111111}
      expected: 2#{00000000}

      actual: catch [main/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-validatesReplace-givenReversibleReplace: func [] [
      afterStream: 2#{11011011}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000000000000011111111}
      expected: "Invalid: bytes removed from afterStream didn't match deltaStream"

      actual: catch [main/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-undoesRemove-givenReversibleRemove: func [] [
      afterStream: #{}
      ;111 0 0000 reversible remove remaining bytes (00000000)
      deltaStream: 2#{1110000000000000}
      expected: 2#{00000000}

      actual: catch [main/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]
]
