Red [
   Title: "tests for deltaBuilder"
]

;do not use deltaConstants: these tests must prove that bit twiddling is correct regardless of constant values

context [
   setup: function [
      "Initialize/Reload context before each test"
   ] [
      do %../../main/red/deltaBuilder.red
   ]

   test-build-handlesSize-givenSize0: function [] [
      ;reversibleRemove, operationSizeFlag, op size size of 15
      ;everything except reversibleRemove will be ignored
      operation: to integer! 2#{11111111}
      operationSize: 0
      ;111 0 0000 reversibleRemove remaining
      expected: 2#{11100000}

      actual: catch [deltaBuilder/build operation operationSize]

      redunit/assert-equals expected actual
   ]

   test-build-handlesSize-givenSize3: function [] [
      ;unchanged, 0s are ignored
      operation: to integer! 2#{00100000}
      operationSize: 3
      ;001 1 0100 unchanged op size size 4
      ;op size 3: 00000000 00000000 00000000 00000011
      expected: 2#{0011010000000000000000000000000000000011}

      actual: catch [deltaBuilder/build operation operationSize]

      redunit/assert-equals expected actual
   ]
]
