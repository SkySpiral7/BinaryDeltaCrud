Red [
   Title: "All functionality"
]

#include %deltaIterator.red

main: context [
   applyDelta: func [
      "Modify the inputStream according to the deltaStream and return the outputStream."
      "@param inputStream isn't mutated instead see return value"
      "@returns outputStream"
      inputStream[binary!] deltaStreamParam[binary!]
   ] [
      outputStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext inputStream
         switch deltaItr/operationType reduce [
            deltaItr/operation/add [
               append outputStream deltaItr/newData
            ]
            deltaItr/operation/unchanged [
               append outputStream copy/part inputStream deltaItr/operationSize
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/replace [
               append outputStream deltaItr/newData
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/remove [
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/reversibleReplace [
               append outputStream deltaItr/newData
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/reversibleRemove [
               inputStream: skip inputStream deltaItr/operationSize
            ]
         ]
      ]
      return outputStream
   ]
   generateDelta: func [
      "Generate a delta that describes the changes needed for beforeStream to become afterStream."
      "Note that this problem is unsolvable (TSP)."
      "@returns deltaStream"
      beforeStream[binary!] afterStream[binary!]
   ] [
      throw "Not yet implemented: generateDelta"
   ]
   makeDeltaNonReversible: func [
      "Modify a deltaStream so that the deltaStream it is no longer reversible (and thus more compact)."
      "The reversible information is stripped without validation and thus this function doesn't require inputStream."
      "@param deltaStreamParam isn't mutated instead see return value"
      "@returns the new deltaStream"
      deltaStreamParam[binary!]
   ] [
      outputStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext none
         switch deltaItr/operationType reduce [
            deltaItr/operation/add [
               append outputStream deltaItr/operationAndData
            ]
            deltaItr/operation/unchanged [
               append outputStream deltaItr/operationBinary
            ]
            deltaItr/operation/replace [
               append outputStream deltaItr/operationAndData
            ]
            deltaItr/operation/remove [
               append outputStream deltaItr/operationBinary
            ]
            deltaItr/operation/reversibleReplace [
               ;only edit the first byte of the operationBinary. it's fine to not copy since I'm done with this delta position
               ;clear reversibleFlag
               deltaItr/operationBinary/1: deltaItr/operationBinary/1 and complement to integer! deltaItr/mask/reversibleFlag
               append outputStream deltaItr/operationBinary
               ;ignore deltaItr/oldData
               append outputStream deltaItr/newData
            ]
            deltaItr/operation/reversibleRemove [
               ;only edit the first byte of the operationBinary. it's fine to not copy since I'm done with this delta position
               ;clear reversibleFlag
               deltaItr/operationBinary/1: deltaItr/operationBinary/1 and complement to integer! deltaItr/mask/reversibleFlag
               append outputStream deltaItr/operationBinary
               ;ignore deltaItr/oldData
            ]
         ]
      ]
      return outputStream
   ]
   makeDeltaReversible: func [
      "Modify a deltaStream according to beforeStream so that the deltaStream could be reversed"
      "(and thus less compact)."
      "@param deltaStreamParam isn't mutated instead see return value"
      "@returns the new deltaStream"
      inputStream[binary!] deltaStreamParam[binary!]
   ] [
      outputStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext inputStream
         switch deltaItr/operationType reduce [
            deltaItr/operation/add [
               append outputStream deltaItr/operationAndData
            ]
            deltaItr/operation/unchanged [
               append outputStream deltaItr/operationBinary
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/replace [
               ;don't need to grab the first byte since the 0 fill works with "or"
               append outputStream (deltaItr/operationBinary or deltaItr/mask/reversibleFlag)
               append outputStream copy/part inputStream deltaItr/operationSize
               append outputStream deltaItr/newData
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/remove [
               ;don't need to grab the first byte since the 0 fill works with "or"
               append outputStream (deltaItr/operationBinary or deltaItr/mask/reversibleFlag)
               append outputStream copy/part inputStream deltaItr/operationSize
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/reversibleReplace [
               append outputStream deltaItr/operationAndData
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/reversibleRemove [
               append outputStream deltaItr/operationAndData
               inputStream: skip inputStream deltaItr/operationSize
            ]
         ]
      ]
      return outputStream
   ]
   undoDelta: func [
      "Modify the inputStream according to the opposite of deltaStream and return the outputStream."
      "Only possible if deltaStream is reversible."
      "@param inputStream isn't mutated instead see return value"
      "@returns outputStream"
      inputStream[binary!] deltaStreamParam[binary!]
   ] [
      throw "Not yet implemented: undoDelta"
   ]
]
