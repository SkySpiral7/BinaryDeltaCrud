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
]
