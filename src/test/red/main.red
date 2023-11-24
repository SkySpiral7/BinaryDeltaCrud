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
      expected: "Invalid: Not enough bytes remaining in deltaStream"

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

   test-applyDelta-doesNothing-givenDone: func [] [
      inputStream: #{cafe}
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{00100000}
      expected: #{cafe}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throws-givenUnchangeOp0ExtraBytes: func [] [
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
      expected: "Invalid: Not enough bytes remaining in inputStream"

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
      inputStream: #{cafe}
      ;011 0 0001 remove 1
      ;001 0 0000 remaining unchanged aka done
      deltaStream: 2#{0110000100100000}
      expected: #{fe}

      actual: main/applyDelta inputStream deltaStream

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throws-whenInputOp6: func [] [
      inputStream: #{cafe}
      deltaStream: 2#{11000000}
      expected: "Invalid: operations 6-7 don't exist"

      actual: catch [main/applyDelta inputStream deltaStream]

      redunit/assert-equals expected actual
   ]

   test-applyDelta-throws-whenInputOp7: func [] [
      inputStream: #{cafe}
      deltaStream: 2#{11100000}
      expected: "Invalid: operations 6-7 don't exist"

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
]
