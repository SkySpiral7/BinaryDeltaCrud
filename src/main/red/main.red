Red [
   Title: "All functionality"
]

#include %deltaIterator.red

main: context [
   applyDelta: func [
      "Modify the inputStream according to the deltaStream and return the outputStream."
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
      beforeStream[binary!] afterStream[binary!]
   ] [
      throw "Not yet implemented: generateDelta"
   ]
   makeDeltaNonReversible: func [
      "Modify a deltaStream so that the deltaStream it is no longer reversible (and thus more compact)."
      "Returns the new deltaStream."
      deltaStream[binary!]
   ] [
      throw "Not yet implemented: makeDeltaNonReversible"
   ]
   makeDeltaReversible: func [
      "Modify a deltaStream according to beforeStream so that the deltaStream could be reversed"
      "(and thus less compact)."
      "Returns the new deltaStream."
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
               append outputStream (deltaItr/operationBinary or deltaItr/mask/reversibleFlag)
               append outputStream copy/part inputStream deltaItr/operationSize
               append outputStream deltaItr/newData
               inputStream: skip inputStream deltaItr/operationSize
            ]
            deltaItr/operation/remove [
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
      inputStream[binary!] deltaStream[binary!]
   ] [
      throw "Not yet implemented: undoDelta"
   ]
]
