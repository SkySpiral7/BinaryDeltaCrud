Red [
   Title: "All functionality"
]

#include %deltaIterator.red

main: context [
   applyDelta: func [
      "Modify the beforeStream according to the deltaStream and return the afterStream."
      "@param beforeStream isn't mutated instead see return value"
      "@returns afterStream"
      beforeStream[binary!] deltaStreamParam[binary!]
   ] [
      afterStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext beforeStream
         switch deltaItr/operationType reduce [
            deltaItr/operation/add [
               append afterStream deltaItr/newData
            ]
            deltaItr/operation/unchanged [
               append afterStream copy/part beforeStream deltaItr/operationSize
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/replace [
               append afterStream deltaItr/newData
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/remove [
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/reversibleReplace [
               append afterStream deltaItr/newData
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/reversibleRemove [
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
         ]
      ]
      return afterStream
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
      "The reversible information is stripped without validation and thus this function doesn't require beforeStream."
      "@param deltaStreamParam isn't mutated instead see return value"
      "@returns the new deltaStream"
      deltaStreamParam[binary!]
   ] [
      nonReversibleDeltaStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext none
         switch deltaItr/operationType reduce [
            deltaItr/operation/add [
               append nonReversibleDeltaStream deltaItr/operationAndData
            ]
            deltaItr/operation/unchanged [
               append nonReversibleDeltaStream deltaItr/operationBinary
            ]
            deltaItr/operation/replace [
               append nonReversibleDeltaStream deltaItr/operationAndData
            ]
            deltaItr/operation/remove [
               append nonReversibleDeltaStream deltaItr/operationBinary
            ]
            deltaItr/operation/reversibleReplace [
               ;only edit the first byte of the operationBinary. it's fine to not copy since I'm done with this delta position
               ;clear reversibleFlag
               deltaItr/operationBinary/1: deltaItr/operationBinary/1 and complement to integer! deltaItr/mask/reversibleFlag
               append nonReversibleDeltaStream deltaItr/operationBinary
               ;ignore deltaItr/oldData
               append nonReversibleDeltaStream deltaItr/newData
            ]
            deltaItr/operation/reversibleRemove [
               ;only edit the first byte of the operationBinary. it's fine to not copy since I'm done with this delta position
               ;clear reversibleFlag
               deltaItr/operationBinary/1: deltaItr/operationBinary/1 and complement to integer! deltaItr/mask/reversibleFlag
               append nonReversibleDeltaStream deltaItr/operationBinary
               ;ignore deltaItr/oldData
            ]
         ]
      ]
      return nonReversibleDeltaStream
   ]
   makeDeltaReversible: func [
      "Modify a deltaStream according to beforeStream so that the deltaStream could be reversed"
      "(and thus less compact)."
      "@param deltaStreamParam isn't mutated instead see return value"
      "@returns the new deltaStream"
      beforeStream[binary!] deltaStreamParam[binary!]
   ] [
      reversibleDeltaStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext beforeStream
         switch deltaItr/operationType reduce [
            deltaItr/operation/add [
               append reversibleDeltaStream deltaItr/operationAndData
            ]
            deltaItr/operation/unchanged [
               append reversibleDeltaStream deltaItr/operationBinary
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/replace [
               ;don't need to grab the first byte since the 0 fill works with "or"
               append reversibleDeltaStream (deltaItr/operationBinary or deltaItr/mask/reversibleFlag)
               append reversibleDeltaStream copy/part beforeStream deltaItr/operationSize
               append reversibleDeltaStream deltaItr/newData
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/remove [
               ;don't need to grab the first byte since the 0 fill works with "or"
               append reversibleDeltaStream (deltaItr/operationBinary or deltaItr/mask/reversibleFlag)
               append reversibleDeltaStream copy/part beforeStream deltaItr/operationSize
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/reversibleReplace [
               append reversibleDeltaStream deltaItr/operationAndData
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaItr/operation/reversibleRemove [
               append reversibleDeltaStream deltaItr/operationAndData
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
         ]
      ]
      return reversibleDeltaStream
   ]
   undoDelta: func [
      "Modify the afterStream according to the opposite of deltaStream and return the beforeStream."
      "Only possible if deltaStream is reversible."
      "@param afterStream isn't mutated instead see return value"
      "@returns beforeStream"
      afterStream[binary!] deltaStreamParam[binary!]
   ] [
      throw "Not yet implemented: undoDelta"
   ]
]
