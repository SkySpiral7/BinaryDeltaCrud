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
      ;unchanged, operationSizeFlag, op size size of 15
      ;everything except unchanged will be ignored
      operationParam: to integer! 2#{00111111}
      operationSizeParam: 0
      ;001 0 0000 unchanged remaining
      expected: 2#{00100000}

      actual: catch [buildDelta[operation: operationParam operationSize: operationSizeParam]]

      redunit/assert-equals expected actual
   ]

   test-buildDelta-handlesSize-givenSize5: function [] [
      ;unchanged
      operationParam: to integer! 2#{00100000}
      operationSizeParam: 5
      ;001 0 0101 unchanged op size 5
      expected: 2#{00100101}

      actual: catch [buildDelta[operation: operationParam operationSize: operationSizeParam]]

      redunit/assert-equals expected actual
   ]

   test-buildDelta-handlesSize-givenSize300: function [] [
      ;unchanged
      operationParam: to integer! 2#{00100000}
      operationSizeParam: 300
      ;001 1 0010 unchanged op size size 2
      ;op size 300: 00000001 00101100
      expected: 2#{001100100000000100101100}

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

   ;data is unset is covered by the other tests
   test-buildDelta-handlesNoneData-givenDataIsNone: function [] [
      ;unchanged
      operationParam: to integer! 2#{00100000}
      operationSizeParam: 1
      ;001 0 0001 unchanged op size 1
      expected: 2#{00100001}

      actual: catch [buildDelta[
         operation: operationParam operationSize: operationSizeParam oldData: none newData: none
      ]]

      redunit/assert-equals expected actual
   ]
]
