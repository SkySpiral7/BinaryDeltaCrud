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

            remainingValue: currentDeltaByte and maskRemaining
            operationSize: remainingValue
            if (currentDeltaByte and maskOperationSizeFlag) == maskOperationSizeFlag [
                if remainingValue > 4 [throw "Not yet implemented: op size size is limited to signed 4 bytes"]
                opSizeBinary: copy/part (skip deltaStream deltaStreamIndex) remainingValue
                if (remainingValue == 4) and ((opSizeBinary and #{80000000}) == #{80000000}) [throw "Not yet implemented: op size size is limited to signed 4 bytes"]
                operationSize: to integer! opSizeBinary
                deltaStreamIndex: deltaStreamIndex + remainingValue
            ]

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
