Red [
   Title: "tests for buildDelta"
]

;do not use deltaConstants: these tests must prove that bit twiddling is correct regardless of constant values

context [
   setup: function [
      "Initialize/Reload context before each test"
   ] [
      do %../../main/red/buildDelta.red
   ]

   test-buildDelta-handlesSize-givenSize0: function [] [
      ;reversibleRemove, operationSizeFlag, op size size of 15
      ;everything except reversibleRemove will be ignored
      operationParam: to integer! 2#{11111111}
      operationSizeParam: 0
      ;111 0 0000 reversibleRemove remaining
      expected: 2#{11100000}

      actual: catch [buildDelta[operation: operationParam operationSize: operationSizeParam]]

      redunit/assert-equals expected actual
   ]

   test-buildDelta-handlesSize-givenSize5: function [] [
      ;add
      operationParam: to integer! 2#{00000000}
      operationSizeParam: 5
      ;000 1 0100 add op size size 4
      ;op size 5: 00000000 00000000 00000000 00000101
      expected: 2#{0001010000000000000000000000000000000101}

      actual: catch [buildDelta[operation: operationParam operationSize: operationSizeParam]]

      redunit/assert-equals expected actual
   ]

   test-buildDelta-handlesData-givenOldData: function [] [
      ;reversibleRemove
      operationParam: to integer! 2#{11100000}
      operationSizeParam: 0
      oldDataParam: 2#{01001010}
      ;111 0 0000 reversibleRemove remaining
      ;oldData: 01001010
      expected: 2#{1110000001001010}

      actual: catch [buildDelta[operation: operationParam operationSize: operationSizeParam oldData: oldDataParam]]

      redunit/assert-equals expected actual
   ]

   test-buildDelta-handlesData-givenNewData: function [] [
      ;add
      operationParam: to integer! 2#{00000000}
      operationSizeParam: 0
      newDataParam: 2#{01001010}
      ;000 0 0000 add remaining
      ;newData: 01001010
      expected: 2#{0000000001001010}

      actual: catch [buildDelta[operation: operationParam operationSize: operationSizeParam newData: newDataParam]]

      redunit/assert-equals expected actual
   ]

   test-buildDelta-handlesData-givenBothData: function [] [
      ;reversibleReplace
      operationParam: to integer! 2#{11000000}
      operationSizeParam: 0
      oldDataParam: 2#{01001010}
      newDataParam: 2#{00000000}
      ;110 0 0000 reversibleReplace remaining
      ;oldData: 01001010
      ;newData: 00000000
      expected: 2#{110000000100101000000000}

      actual: catch [buildDelta[
         operation: operationParam operationSize: operationSizeParam oldData: oldDataParam newData: newDataParam
      ]]

      redunit/assert-equals expected actual
   ]
]
