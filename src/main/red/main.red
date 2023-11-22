Red [
    Title: "All functionality"
]

main: context [
    /local operationMask: to integer! 2#{11100000}
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
            if (currentDeltaByte and operationMask) == operationUnchanged [return inputStream]
        ]
        if inputStreamIndex > length? inputStream [return #{01}]; TODO: throw
        return outputStream
    ]
]
