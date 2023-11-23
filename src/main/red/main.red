Red [
    Title: "All functionality"
]

main: context [
    /local maskOperation: to integer! 2#{11100000}
    /local maskOperationSizeFlag: to integer! 2#{00010000}
    /local maskRemaining: to integer! 2#{00001111}
    /local operationUnchanged: to integer! 2#{00100000}

    applyDelta: func [
        "Modify the inputStream according to the deltaStream and return the outputStream."
        inputStream[binary!] deltaStream[binary!]
    ] [
        inputStreamIndex: 1
        deltaStreamIndex: 1
        outputStream: #{}
        ; TODO: using next might work instead of a delta index
        while [deltaStreamIndex <= length? deltaStream] [
            currentDeltaByte: pick deltaStream deltaStreamIndex
            if (currentDeltaByte and maskOperation) <> operationUnchanged [throw "Not yet implemented: op must be unchanged"]
            if (currentDeltaByte and maskOperationSizeFlag) == maskOperationSizeFlag [throw "Not yet implemented: op size flag must be 0"]

            remainingValue: currentDeltaByte and maskRemaining
            operationSize: remainingValue
            inputSizeRemaining: (length? inputStream) - inputStreamIndex + 1
            if operationSize == 0 [operationSize: inputSizeRemaining]
            if operationSize > inputSizeRemaining [throw "Invalid: Not enough bytes remaining in inputStream"]
            while [operationSize > 0] [
                currentInputByte: pick inputStream inputStreamIndex
                append outputStream currentInputByte
                inputStreamIndex: inputStreamIndex + 1
                operationSize: operationSize - 1
            ]
            deltaStreamIndex: deltaStreamIndex + 1
        ]
        if inputStreamIndex <= length? inputStream [throw "Invalid: Unaccounted for bytes remaining in inputStream"]
        return outputStream
    ]
]
