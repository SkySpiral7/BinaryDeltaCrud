Red [
    Title: "tests"
]

context [
    setup: func [
        "Initialize/Reload context before each test"
    ] [
        do %../../main/red/main.red
    ]

    test-add: func [
        "Add it"
    ] [
        actual: main/add 2 7
        redunit/assert-equals 9 actual
    ]
]
