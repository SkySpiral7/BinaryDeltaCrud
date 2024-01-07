Red [
   Title: "Funcs that use the delta"
]

do %deltaConstants.red
do %deltaIterator.red

deltaApplier: context [
   applyDelta: function [
      {Modify the beforeStream according to the deltaStream and return the afterStream.
      @param beforeStream isn't mutated instead see return value
      @returns afterStream}
      beforeStream[binary!] deltaStreamParam[binary!]
      return: [binary!]
   ] [
      afterStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext beforeStream
         switch deltaItr/operationType reduce [
            deltaConstants/operation/add [
               append afterStream deltaItr/newData
            ]
            deltaConstants/operation/unchanged [
               append afterStream copy/part beforeStream deltaItr/operationSize
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaConstants/operation/replace [
               append afterStream deltaItr/newData
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaConstants/operation/remove [
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaConstants/operation/reversibleReplace [
               append afterStream deltaItr/newData
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
            deltaConstants/operation/reversibleRemove [
               beforeStream: skip beforeStream deltaItr/operationSize
            ]
         ]
      ]
      return afterStream
   ]
   undoDelta: function [
      {Modify the afterStream according to the opposite of deltaStream and return the beforeStream.
      Only possible if deltaStream is reversible.
      @param afterStream isn't mutated instead see return value
      @returns beforeStream}
      afterStream[binary!] deltaStreamParam[binary!]
      return: [binary!]
   ] [
      undoDeltaStream: copy #{}
      deltaItr: make deltaIterator [deltaStream: deltaStreamParam]
      while [deltaItr/hasNext?] [
         deltaItr/parseNext none  ;don't run normal validation yet since we have an afterStream instead of a beforeStream
         switch deltaItr/operationType reduce [
            deltaConstants/operation/add [
               deltaItr/setOperation deltaConstants/operation/reversibleRemove
               append undoDeltaStream deltaItr/operationBinary
               append undoDeltaStream deltaItr/newData
            ]
            deltaConstants/operation/unchanged [
               append undoDeltaStream deltaItr/operationBinary
            ]
            deltaConstants/operation/replace [
               throw "Invalid: deltaStream isn't reversible"
            ]
            deltaConstants/operation/remove [
               throw "Invalid: deltaStream isn't reversible"
            ]
            deltaConstants/operation/reversibleReplace [
               ;don't need to edit operationBinary. just flip the data order
               append undoDeltaStream deltaItr/operationBinary
               append undoDeltaStream deltaItr/newData
               append undoDeltaStream deltaItr/oldData
            ]
            deltaConstants/operation/reversibleRemove [
               deltaItr/setOperation deltaConstants/operation/add
               append undoDeltaStream deltaItr/operationBinary
               append undoDeltaStream deltaItr/oldData
            ]
         ]
      ]
      ;this validates afterStream
      exception: catch [return applyDelta afterStream undoDeltaStream]
      ;in case red throws something
      if string! <> type? exception [throw exception]
      ;edit error message to match this undoDelta
      exception: replace/case copy exception "beforeStream" "afterStream"
      throw exception
   ]
]
