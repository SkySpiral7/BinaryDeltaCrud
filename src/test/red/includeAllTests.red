Red [
   Title: "run all the tests"
]

#include %../../../../../red/RedUnit/src/redunit.red
;TODO: have this take in whole tests folder and move stuff to scripts
redunit/run %deltaIterator.red
redunit/run %main.red
