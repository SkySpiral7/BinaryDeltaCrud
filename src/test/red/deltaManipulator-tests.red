Red [
   Title: "tests for deltaManipulator"
]

do %../../main/red/buildDelta.red
do %../../main/red/deltaConstants.red

context [
   setup: function [
      "Initialize/Reload context before each test"
   ] [
      do %../../main/red/deltaManipulator.red
   ]

   test-makeDeltaNonReversible-loops-givenMultipleDeltaOps: function [] [
      deltaStream: copy #{}
      append deltaStream (
         buildDelta [
            operation: deltaConstants/operation/unchanged
            operationSize: 1
         ]
      )
      ;same op twice
      append deltaStream deltaStream
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-keepsData-givenAdd: function [] [
      deltaStream: buildDelta [
         operation: deltaConstants/operation/add
         operationSize: deltaConstants/remainingBytes
         newData: to binary! #"a"
      ]
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-keepsData-givenUnchanged: function [] [
      deltaStream: buildDelta [
         operation: deltaConstants/operation/unchanged
         operationSize: deltaConstants/remainingBytes
      ]
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-keepsData-givenReplace: function [] [
      deltaStream: buildDelta [
         operation: deltaConstants/operation/replace
         operationSize: deltaConstants/remainingBytes
         newData: to binary! "ab"
      ]
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-keepsData-givenRemove: function [] [
      deltaStream: buildDelta [
         operation: deltaConstants/operation/remove
         operationSize: deltaConstants/remainingBytes
      ]
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-makesNonReversible-givenReversibleReplace: function [] [
      deltaStream: buildDelta [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: deltaConstants/remainingBytes
         oldData: to binary! "aa"
         newData: to binary! "bb"
      ]
      expected: buildDelta [
         operation: deltaConstants/operation/replace
         operationSize: deltaConstants/remainingBytes
         newData: to binary! "bb"
      ]

      actual: catch [deltaManipulator/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-makesNonReversible-givenReversibleRemove: function [] [
      deltaStream: buildDelta [
         operation: deltaConstants/operation/reversibleRemove
         operationSize: deltaConstants/remainingBytes
         oldData: to binary! "aa"
      ]
      expected: buildDelta [
         operation: deltaConstants/operation/remove
         operationSize: deltaConstants/remainingBytes
      ]

      actual: catch [deltaManipulator/makeDeltaNonReversible deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-loops-givenMultipleDeltaOps: function [] [
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
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-validatesBeforeStream-givenInvalidBeforeStream: function [] [
      beforeStream: #{}
      deltaStream: buildDelta [
         operation: deltaConstants/operation/remove
         operationSize: 1
      ]
      expected: "Invalid: Not enough bytes remaining in beforeStream"

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenAdd: function [] [
      beforeStream: #{}
      deltaStream: buildDelta [
         operation: deltaConstants/operation/add
         operationSize: deltaConstants/remainingBytes
         newData: to binary! #"a"
      ]
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenUnchanged: function [] [
      beforeStream: to binary! #"a"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/unchanged
         operationSize: deltaConstants/remainingBytes
      ]
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenUnchangedEmptyBefore: function [] [
      beforeStream: #{}
      deltaStream: buildDelta [
         operation: deltaConstants/operation/unchanged
         operationSize: deltaConstants/remainingBytes
      ]
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-makesReversible-givenReplace: function [] [
      beforeStream: to binary! "aa"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/replace
         operationSize: deltaConstants/remainingBytes
         newData: to binary! "bb"
      ]
      expected: buildDelta [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: deltaConstants/remainingBytes
         oldData: copy beforeStream
         newData: to binary! "bb"
      ]

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-makesReversible-givenRemove: function [] [
      beforeStream: to binary! "aa"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/remove
         operationSize: deltaConstants/remainingBytes
      ]
      expected: buildDelta [
         operation: deltaConstants/operation/reversibleRemove
         operationSize: deltaConstants/remainingBytes
         oldData: copy beforeStream
      ]

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenReversibleReplace: function [] [
      beforeStream: to binary! "aa"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: deltaConstants/remainingBytes
         oldData: copy beforeStream
         newData: to binary! "bb"
      ]
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-keepsData-givenReversibleRemove: function [] [
      beforeStream: to binary! "aa"
      deltaStream: buildDelta [
         operation: deltaConstants/operation/reversibleRemove
         operationSize: deltaConstants/remainingBytes
         oldData: copy beforeStream
      ]
      expected: copy deltaStream

      actual: catch [deltaManipulator/makeDeltaReversible beforeStream deltaStream]

      redunit/assert-equals expected actual
   ]
]
