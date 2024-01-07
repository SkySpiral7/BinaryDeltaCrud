Red [
   Title: "tests for deltaManipulator"
]

do %../../main/red/buildDelta.red
do %../../main/red/deltaConstants.red
;TODO: use the builder

context [
   setup: function [
      "Initialize/Reload context before each test"
   ] [
      do %../../main/red/deltaManipulator.red
   ]

   test-makeDeltaNonReversible-loops-givenMultipleDeltaOps: function [] [
      ;001 0 0001 unchanged 1 byte. twice
      deltaStream: 2#{0010000100100001}
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-keepsData-givenAdd: function [] [
      ;000 0 0000 add remaining bytes (11111111)
      deltaStream: 2#{0000000011111111}
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-keepsData-givenUnchanged: function [] [
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-keepsData-givenReplace: function [] [
      ;010 0 0000 replace remaining bytes (11111111 00000000)
      deltaStream: 2#{010000001111111100000000}
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-keepsData-givenRemove: function [] [
      ;011 0 0000 remove remaining bytes
      deltaStream: 2#{01100000}
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-makesNonReversible-givenReversibleReplace: function [] [
      ;110 1 0001 00000001 reversible replace 1 byte
      ;old: 00000000, new: 11111111
      deltaStream: 2#{11010001000000010000000011111111}
      ;010 1 0001 00000001 replace 1 byte
      ;new: 11111111
      expected: 2#{010100010000000111111111}

      actual: catch [deltaManipulator/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-makesNonReversible-givenReversibleRemove: function [] [
      ;111 1 0001 00000001 reversible remove 1 byte (00000000)
      deltaStream: 2#{111100010000000100000000}
      ;011 1 0001 00000001 remove 1 byte
      expected: 2#{0111000100000001}

      actual: catch [deltaManipulator/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-loops-givenMultipleDeltaOps: function [] [
      beforeStream: #{1122}
      ;001 0 0001 unchanged 1 byte. twice
      deltaStream: 2#{0010000100100001}
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-validatesBeforeStream-givenInvalidBeforeStream: function [] [
      beforeStream: #{}
      ;011 0 0001 remove 1 byte
      deltaStream: 2#{01100001}
      expected: "Invalid: Not enough bytes remaining in beforeStream"

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenAdd: function [] [
      beforeStream: #{}
      ;000 0 0000 add remaining bytes (11111111)
      deltaStream: 2#{0000000011111111}
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenUnchanged: function [] [
      beforeStream: #{cafe}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenUnchangedEmptyBefore: function [] [
      beforeStream: #{}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-makesReversible-givenReplace: function [] [
      beforeStream: 2#{1100101011111110}
      ;010 1 0001 00000010 replace 2 bytes (11111111 00000000)
      deltaStream: 2#{01010001000000101111111100000000}
      ;110 1 0001 00000010 reversible replace 2 bytes
      ;old: 11001010 11111110 new: 11111111 00000000
      expected: 2#{110100010000001011001010111111101111111100000000}

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-makesReversible-givenRemove: function [] [
      beforeStream: 2#{11001010}
      ;011 1 0001 00000001 remove 1 byte
      deltaStream: 2#{0111000100000001}
      ;111 1 0001 00000001 reversible remove 1 byte
      ;old: 11001010
      expected: 2#{111100010000000111001010}

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenReversibleReplace: function [] [
      beforeStream: 2#{00000000}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000000000000011111111}
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenReversibleRemove: function [] [
      beforeStream: 2#{00000000}
      ;111 0 0000 reversible remove remaining bytes (00000000)
      deltaStream: 2#{1110000000000000}
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]
]
