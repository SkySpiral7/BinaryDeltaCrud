Red [
   Title: "Funcs that edit the deltaStream"
]

do %deltaConstants.red
do %deltaIterator.red

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
   massageDelta: function [
      {Modify a deltaStream to remove redundant info.
      This shrinks redundantly large op sizes and combines duplicate ops.
      This doesn't split large ops since red's binary! has max size anyway.
      @param deltaStreamParam isn't mutated instead see return value
      @returns the new deltaStream}
      ;TODO: check help parsing. put string on the args
      deltaStreamParam[binary!]
      return: [binary!]
   ] [
      comment {
         This shrinks redundantly large op sizes, combines duplicate ops, and removes trailing "done".

         TODO: more massageDelta
         removing trailing "done" requires stepping through beforeStream
      }
      smallerDeltaStream: copy #{}
      ;empty delta is valid and already clean TODO: check this edge case everywhere
      if empty? deltaStreamParam [return smallerDeltaStream]
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]

      deltaItr/parseNext none
      ;seed previous with the first op
      previous: context [
         operation: deltaItr/operationType
         operationSize: deltaItr/operationSize
         oldData: none
         newData: none
      ]
      if deltaItr/oldData <> none [previous/oldData: copy deltaItr/oldData]
      if deltaItr/newData <> none [previous/newData: copy deltaItr/newData]

      while [deltaItr/hasNext?] [
         deltaItr/parseNext none
         ;duplicate op
         either previous/operation == deltaItr/operationType [
            ;TODO: add size validation like the itr has
            previous/operationSize: previous/operationSize + deltaItr/operationSize
            if previous/oldData <> none [previous/oldData: append previous/oldData deltaItr/oldData]
            if previous/newData <> none [previous/newData: append previous/newData deltaItr/newData]
         ] [
            ;previous no longer needs a bigger size so just record it
            append smallerDeltaStream buildDelta [
               operation: previous/operation
               operationSize: previous/operationSize
               oldData: previous/oldData
               newData: previous/newData
            ]
            previous: context [
               operation: deltaItr/operationType
               operationSize: deltaItr/operationSize
               oldData: none
               newData: none
            ]
            if deltaItr/oldData <> none [previous/oldData: copy deltaItr/oldData]
            if deltaItr/newData <> none [previous/newData: copy deltaItr/newData]
         ]
      ]
      append smallerDeltaStream buildDelta [
         operation: previous/operation
         operationSize: previous/operationSize
         oldData: previous/oldData
         newData: previous/newData
      ]
      return smallerDeltaStream
   ]
]
