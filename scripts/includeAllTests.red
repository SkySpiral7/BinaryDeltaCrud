Red [
   Title: "run all the tests"
]

;https://codeberg.org/hiiamboris/red-common/src/branch/master/include-once.red sounds good but broke RedUnit
do %../lib/RedUnit/src/redunit.red
redunit/run %../src/test/red/
