Red [
   Title: "tests for deltaApplier"
]

do %../../main/red/buildDelta.red
do %../../main/red/deltaConstants.red
;TODO: use the builder

context [
   setup: function [
      "Initialize/Reload context before each test"
   ] [
      do %../../main/red/deltaApplier.red
   ]

   test-applyDelta-loops-givenMultipleDeltaOps: function [] [
      beforeStream: to binary! "ab"
      deltaStream: copy #{}
      append deltaStream (
         buildDelta [
            operation: deltaConstants/operation/unchanged
            operationSize: 1
         ]
      )
      ;same op twice
      append deltaStream deltaStream
      expected: to binary! "ab"

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-validatesBeforeStream-givenInvalidBeforeStream: function [] [
      beforeStream: #{}
      deltaStream: buildDelta [
         operation: deltaConstants/operation/remove
         operationSize: 1
      ]
      expected: "Invalid: Not enough bytes remaining in beforeStream"

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesAdd-givenAdd: function [] [
      beforeStream: #{}
      deltaStream: buildDelta [
         operation: deltaConstants/operation/add
         operationSize: 1
         newData: to binary! #"a"
      ]
      expected: to binary! #"a"

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesUnchanged-givenUnchanged: function [] [
      beforeStream: #{cafe}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: #{cafe}

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesUnchanged-givenUnchangedEmptyBefore: function [] [
      beforeStream: #{}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: #{}

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesReplace-givenReplace: function [] [
      beforeStream: #{cafe}
      ;010 0 0000 replace remaining bytes (11111111 00000000)
      deltaStream: 2#{010000001111111100000000}
      expected: 2#{1111111100000000}

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesRemove-givenRemove: function [] [
      beforeStream: #{cafe}
      ;011 0 0000 remove remaining bytes
      deltaStream: 2#{01100000}
      expected: #{}

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesReplace-givenReversibleReplace: function [] [
      beforeStream: 2#{00000000}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000000000000011111111}
      expected: 2#{11111111}

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesRemove-givenReversibleRemove: function [] [
      beforeStream: 2#{00000000}
      ;111 0 0000 reversible remove remaining bytes (00000000)
      deltaStream: 2#{1110000000000000}
      expected: #{}

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-loops-givenMultipleDeltaOps: function [] [
      afterStream: #{1122}
      ;001 0 0001 unchanged 1 byte. twice
      deltaStream: 2#{0010000100100001}
      expected: #{1122}

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-validatesAfterStream-givenInvalidAfterStream: function [] [
      afterStream: #{}
      ;000 0 0001 add 1 byte (11111111)
      deltaStream: 2#{0000000111111111}
      expected: "Invalid: Not enough bytes remaining in afterStream"

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-undoesAdd-givenAdd: function [] [
      afterStream: 2#{11111111}
      ;000 0 0001 add 1 byte (11111111)
      deltaStream: 2#{0000000111111111}
      expected: #{}

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-validatesAdd-givenAdd: function [] [
      afterStream: 2#{11011011}
      ;000 0 0001 add 1 byte (11111111)
      deltaStream: 2#{0000000111111111}
      expected: "Invalid: bytes removed from afterStream didn't match deltaStream"

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-undoesUnchanged-givenUnchanged: function [] [
      afterStream: #{cafe}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: #{cafe}

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-undoesUnchanged-givenUnchangedEmptyAfter: function [] [
      afterStream: #{}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: #{}

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-throws-givenReplace: function [] [
      afterStream: 2#{1111111100000000}
      ;010 0 0000 replace remaining bytes (11111111 00000000)
      deltaStream: 2#{010000001111111100000000}
      expected: "Invalid: deltaStream isn't reversible"

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-throws-givenRemove: function [] [
      afterStream: #{}
      ;011 0 0000 remove remaining bytes
      deltaStream: 2#{01100000}
      expected: "Invalid: deltaStream isn't reversible"

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-undoesReplace-givenReversibleReplace: function [] [
      afterStream: 2#{11111111}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000000000000011111111}
      expected: 2#{00000000}

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-validatesReplace-givenReversibleReplace: function [] [
      afterStream: 2#{11011011}
      ;110 0 0000 reversible replace remaining bytes
      ;old: 00000000, new: 11111111
      deltaStream: 2#{110000000000000011111111}
      expected: "Invalid: bytes removed from afterStream didn't match deltaStream"

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-undoesRemove-givenReversibleRemove: function [] [
      afterStream: #{}
      ;111 0 0000 reversible remove remaining bytes (00000000)
      deltaStream: 2#{1110000000000000}
      expected: 2#{00000000}

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]
]
