Red [
   Title: "single test"
]

context [
   setup: function [
      "Initialize/Reload context before each test"
   ] [
      do %../src/main/red/main.red
      do %../src/main/red/deltaIterator.red
      ;print ["actual" actual]
   ]
   ;exists so that it doesn't fail on "Provided object does not have any test method!"
   test-alwaysPass: function [][]
]
