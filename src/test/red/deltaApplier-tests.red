Red [
   Title: "tests for deltaApplier"
]

do %../../main/red/buildDelta.red
do %../../main/red/deltaConstants.red

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
      expected: copy beforeStream

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
      expected: to binary! #"a"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/add
         operationSize: 1
         newData: copy expected
      ]

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesUnchanged-givenUnchanged: function [] [
      beforeStream: #{cafe}
      deltaStream: buildDelta [
         operation: deltaConstants/operation/unchanged
         operationSize: deltaConstants/remainingBytes
      ]
      expected: copy beforeStream

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesUnchanged-givenUnchangedEmptyBefore: function [] [
      beforeStream: #{}
      deltaStream: buildDelta [
         operation: deltaConstants/operation/unchanged
         operationSize: deltaConstants/remainingBytes
      ]
      expected: copy beforeStream

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesReplace-givenReplace: function [] [
      beforeStream: to binary! "aa"
      expected: to binary! "bb"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/replace
         operationSize: deltaConstants/remainingBytes
         newData: copy expected
      ]

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesRemove-givenRemove: function [] [
      beforeStream: to binary! #"a"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/remove
         operationSize: deltaConstants/remainingBytes
      ]
      expected: #{}

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesReplace-givenReversibleReplace: function [] [
      beforeStream: to binary! "aa"
      expected: to binary! "bb"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: deltaConstants/remainingBytes
         oldData: copy beforeStream
         newData: copy expected
      ]

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-doesRemove-givenReversibleRemove: function [] [
      beforeStream: to binary! "aa"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/reversibleRemove
         operationSize: deltaConstants/remainingBytes
         oldData: copy beforeStream
      ]
      expected: #{}

      actual: catch [deltaApplier/applyDelta beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-loops-givenMultipleDeltaOps: function [] [
      afterStream: to binary! "ab"
      deltaStream: copy #{}
      append deltaStream (
         buildDelta [
            operation: deltaConstants/operation/unchanged
            operationSize: 1
         ]
      )
      ;same op twice
      append deltaStream deltaStream
      expected: copy afterStream

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-validatesAfterStream-givenInvalidAfterStream: function [] [
      afterStream: #{}
      deltaStream: buildDelta [
         operation: deltaConstants/operation/add
         operationSize: 1
         newData: to binary! "a"
      ]
      expected: "Invalid: Not enough bytes remaining in afterStream"

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-undoesAdd-givenAdd: function [] [
      afterStream: to binary! "a"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/add
         operationSize: 1
         newData: copy afterStream
      ]
      expected: #{}

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-validatesAdd-givenAdd: function [] [
      afterStream: to binary! "a"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/add
         operationSize: 1
         newData: to binary! "b"
      ]
      expected: "Invalid: bytes removed from afterStream didn't match deltaStream"

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-undoesUnchanged-givenUnchanged: function [] [
      afterStream: to binary! "ab"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/unchanged
         operationSize: deltaConstants/remainingBytes
      ]
      expected: copy afterStream

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-undoesUnchanged-givenUnchangedEmptyAfter: function [] [
      afterStream: #{}
      deltaStream: buildDelta [
         operation: deltaConstants/operation/unchanged
         operationSize: deltaConstants/remainingBytes
      ]
      expected: copy afterStream

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-throws-givenReplace: function [] [
      afterStream: to binary! "bb"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/replace
         operationSize: deltaConstants/remainingBytes
         newData: copy afterStream
      ]
      expected: "Invalid: deltaStream isn't reversible"

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-throws-givenRemove: function [] [
      afterStream: #{}
      deltaStream: buildDelta [
         operation: deltaConstants/operation/remove
         operationSize: deltaConstants/remainingBytes
      ]
      expected: "Invalid: deltaStream isn't reversible"

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-undoesReplace-givenReversibleReplace: function [] [
      afterStream: to binary! "bb"
      expected: to binary! "aa"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: deltaConstants/remainingBytes
         oldData: copy expected
         newData: copy afterStream
      ]

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-validatesReplace-givenReversibleReplace: function [] [
      afterStream: to binary! "bb"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: deltaConstants/remainingBytes
         oldData: to binary! "aa"
         newData: to binary! "cc"
      ]
      expected: "Invalid: bytes removed from afterStream didn't match deltaStream"

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-undoDelta-undoesRemove-givenReversibleRemove: function [] [
      afterStream: #{}
      expected: to binary! "aa"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/reversibleRemove
         operationSize: deltaConstants/remainingBytes
         oldData: copy expected
      ]

      actual: catch [deltaApplier/undoDelta afterStream deltaStream]

      redunit/assert-equals expected actual
   ]
]
