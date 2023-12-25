Red [
   Title: "tests for cli"
]

context [
   tempDir: %../../../scripts/temp/
   cliPath: %../../main/red/cli.red
   setup: does [
      if not exists? tempDir [make-dir tempDir]
   ]

   test-applyDelta-writesChange-givenValidStreams: func [] [
      beforeStreamPath: clean-path append copy tempDir %beforeStream.bin
      write beforeStreamPath "a"
      ;010 0 0000 replace remaining bytes (b: 01100010)
      deltaStreamPath: clean-path append copy tempDir %deltaStream.bin
      write deltaStreamPath 2#{0100000001100010}
      expected: "b"

      afterStreamPath: clean-path append copy tempDir %afterStream.bin
      system/options/args: reduce ["applyDelta" beforeStreamPath deltaStreamPath afterStreamPath]
      do cliPath
      actual: read afterStreamPath

      redunit/assert-equals expected actual
   ]
]
