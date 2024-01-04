Red [
   Title: "tests for cli"
]

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
      ;010 0 0000 replace remaining bytes (b: 01100010)
      write deltaStreamPath 2#{0100000001100010}
      expected: "b"

      afterStreamPath: clean-path append copy tempDir %afterStream.bin
      system/options/args: reduce ["applyDelta" beforeStreamPath deltaStreamPath afterStreamPath]
      do cliPath
      actual: read afterStreamPath

      redunit/assert-equals expected actual
   ]
]
