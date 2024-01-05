Red [
   Title: "tests for cli"
]

do %../../main/red/buildDelta.red
do %../../main/red/deltaConstants.red

;for ease of testing: all before/after streams will be text/plain UTF-8
context [
   tempDir: %../../../scripts/temp/
   cliPath: %../../main/red/cli.red
   ;doesn't need to be in setup since this only needs to be done once before all tests
   if not exists? tempDir [make-dir tempDir]
   ;it doesn't bother deleting any files (they are git ignored and tests will override them)

   test-applyDelta-writesChange-givenValidStreams: function [] [
      beforeStreamPath: clean-path append copy tempDir %beforeStream.bin
      write beforeStreamPath "a"
      deltaStreamPath: clean-path append copy tempDir %deltaStream.bin
      write deltaStreamPath buildDelta [
         operation: deltaConstants/operation/replace
         operationSize: 0
         newData: to binary! #"b"
      ]
      expected: "b"

      afterStreamPath: clean-path append copy tempDir %afterStream.bin
      system/options/args: reduce ["applyDelta" beforeStreamPath deltaStreamPath afterStreamPath]
      do cliPath
      actual: read afterStreamPath

      redunit/assert-equals expected actual
   ]
]
