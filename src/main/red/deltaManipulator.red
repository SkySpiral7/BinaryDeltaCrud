Red [
   Title: "Funcs that edit the deltaStream"
]

do %deltaConstants.red
do %deltaIterator.red

;TODO: make massage: shrinks redundantly large op sizes, validate, remove trailing done
;can't split split large ops since red's binary! has max size
deltaManipulator: context [
   makeDeltaNonReversible: function [
      {Modify a deltaStream so that the deltaStream it is no longer reversible (and thus more compact).
      The reversible information is stripped without validation and thus this function doesn't require beforeStream.
      @param deltaStreamParam isn't mutated instead see return value
      @returns the new deltaStream}
      deltaStreamParam[binary!]
      return: [binary!]
   ] [
      nonReversibleDeltaStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext none
         switch deltaItr/operationType reduce [
            deltaConstants/operation/add [
               append nonReversibleDeltaStream deltaItr/operationAndData
            ]
            deltaConstants/operation/unchanged [
               append nonReversibleDeltaStream deltaItr/operationBinary
            ]
            deltaConstants/operation/replace [
               append nonReversibleDeltaStream deltaItr/operationAndData
            ]
            deltaConstants/operation/remove [
               append nonReversibleDeltaStream deltaItr/operationBinary
            ]
            deltaConstants/operation/reversibleReplace [
               deltaItr/clearReversibleFlag
               append nonReversibleDeltaStream deltaItr/operationBinary
               ;ignore deltaItr/oldData
               append nonReversibleDeltaStream deltaItr/newData
            ]
            deltaConstants/operation/reversibleRemove [
               deltaItr/clearReversibleFlag
               append nonReversibleDeltaStream deltaItr/operationBinary
               ;ignore deltaItr/oldData
            ]
         ]
      ]
      return nonReversibleDeltaStream
   ]
   makeDeltaReversible: function [
      {Modify a deltaStream according to beforeStream so that the deltaStream could be reversed
      (and thus less compact).
      @param deltaStreamParam isn't mutated instead see return value
      @returns the new deltaStream}
      beforeStream[binary!] deltaStreamParam[binary!]
      return: [binary!]
   ] [
      reversibleDeltaStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext beforeStream
         switch deltaItr/operationType reduce [
            deltaConstants/operation/add [
               append reversibleDeltaStream deltaItr/operationAndData
            ]
            deltaConstants/operation/unchanged [
               append reversibleDeltaStream deltaItr/operationBinary
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaConstants/operation/replace [
               deltaItr/setReversibleFlag
               append reversibleDeltaStream deltaItr/operationBinary
               ;oldData
               append reversibleDeltaStream copy/part beforeStream deltaItr/operationSize
               append reversibleDeltaStream deltaItr/newData
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaConstants/operation/remove [
               deltaItr/setReversibleFlag
               append reversibleDeltaStream deltaItr/operationBinary
               ;oldData
               append reversibleDeltaStream copy/part beforeStream deltaItr/operationSize
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaConstants/operation/reversibleReplace [
               append reversibleDeltaStream deltaItr/operationAndData
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaConstants/operation/reversibleRemove [
               append reversibleDeltaStream deltaItr/operationAndData
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
         ]
      ]
      return reversibleDeltaStream
   ]
]
