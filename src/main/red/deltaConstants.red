Red [
   Title: "Constant values related to deltaStream"
]

deltaConstants: context [
   mask: context [
      ;highest bit of 4 bytes (int size). appends 1 byte and 3 bytes
      detectUnsignedInt: append 2#{10000000} #{000000}
      reversibleFlag: to integer! 2#{10000000}
      operation: to integer! 2#{11100000}
      operationSizeFlag: to integer! 2#{00010000}
      remaining: to integer! 2#{00001111}
   ]
   operation: context [
      add: to integer! 2#{00000000}
      unchanged: to integer! 2#{00100000}
      replace: to integer! 2#{01000000}
      remove: to integer! 2#{01100000}
      invalid4: to integer! 2#{10000000}
      invalid5: to integer! 2#{10100000}
      reversibleReplace: to integer! 2#{11000000}
      reversibleRemove: to integer! 2#{11100000}
   ]
   ;this operation size is infinite which means all bytes (if any) that remain in the stream
   remainingBytes: 0
]
