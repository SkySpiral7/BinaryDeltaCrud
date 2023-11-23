Red [
    Title: "tests"
]

context [
    setup: func [
        "Initialize/Reload context before each test"
    ] [
        do %../../main/red/main.red
    ]

    test-applyDelta-doesNothing-givenDone: func [] [
        inputStream: #{cafe}
        ;001 0 0000 remaining unchanged aka done
        deltaStream: 2#{00100000}
        expected: #{cafe}

        actual: main/applyDelta inputStream deltaStream

        redunit/assert-equals expected actual
    ]

    test-applyDelta-doesNothing-givenTwoUnchanged: func [] [
        inputStream: #{cafe}
        ;001 0 0001 unchanged 1 byte. twice
        deltaStream: 2#{0010000100100001}
        expected: #{cafe}

        actual: main/applyDelta inputStream deltaStream

        redunit/assert-equals expected actual
    ]

    test-applyDelta-doesNothing-givenOpSizeUnchanged: func [] [
        inputStream: #{cafe}
        ;001 1 0001 00000010 unchanged 1 byte op size size which has an op size of 2
        deltaStream: 2#{0011000100000010}
        expected: #{cafe}

        actual: main/applyDelta inputStream deltaStream

        redunit/assert-equals expected actual
    ]

    test-applyDelta-throws-whenInputRunsOut: func [] [
        inputStream: #{ca}
        ;001 0 0001 unchanged 1 byte. twice
        deltaStream: 2#{0010000100100001}
        expected: "Invalid: Not enough bytes remaining in inputStream"

        actual: catch [main/applyDelta inputStream deltaStream]

        redunit/assert-equals expected actual
    ]

    test-applyDelta-throws-whenInputHasExtraBytes: func [] [
        inputStream: #{cafe}
        ;001 0 0001 unchanged 1 byte
        deltaStream: 2#{00100001}
        expected: "Invalid: Unaccounted for bytes remaining in inputStream"

        actual: catch [main/applyDelta inputStream deltaStream]

        redunit/assert-equals expected actual
    ]
]
