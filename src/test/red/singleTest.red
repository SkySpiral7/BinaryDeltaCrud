Red [
   Title: "single test"
]

context [
   setup: func [
      "Initialize/Reload context before each test"
   ] [
      do %../../main/red/main.red
      print ["actual" actual]
   ]
]
