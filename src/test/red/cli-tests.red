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

   setup: function [] [
      ;delete all 3 files each run to prove each test writes to files
      delete append copy tempDir %beforeStream.bin
      delete append copy tempDir %deltaStream.bin
      delete append copy tempDir %afterStream.bin
   ]

   test-applyDelta-writesChange-givenValidStreams: function [] [
      beforeStreamPath: clean-path append copy tempDir %beforeStream.bin
      write beforeStreamPath "a"
      deltaStreamPath: clean-path append copy tempDir %deltaStream.bin
      write deltaStreamPath buildDelta [
         operation: deltaConstants/operation/replace
         operationSize: deltaConstants/remainingBytes
         newData: to binary! #"b"
      ]
      expected: "b"

      afterStreamPath: clean-path append copy tempDir %afterStream.bin
      system/options/args: reduce ["applyDelta" beforeStreamPath deltaStreamPath afterStreamPath]
      do cliPath
      actual: read afterStreamPath

      redunit/assert-equals expected actual
   ]

   test-generateDelta-writesChange-givenValidStreams: function [] [
      beforeStreamPath: clean-path append copy tempDir %beforeStream.bin
      write beforeStreamPath "a"
      afterStreamPath: clean-path append copy tempDir %afterStream.bin
      write afterStreamPath "a"
      expected: buildDelta [
         operation: deltaConstants/operation/unchanged
         operationSize: deltaConstants/remainingBytes
      ]

      deltaStreamPath: clean-path append copy tempDir %deltaStream.bin
      system/options/args: reduce ["generateDelta" beforeStreamPath afterStreamPath deltaStreamPath]
      do cliPath
      actual: read/binary deltaStreamPath

      redunit/assert-equals expected actual
   ]

   test-makeDeltaNonReversible-writesChange-givenValidStreams: function [] [
      deltaStreamPath: clean-path append copy tempDir %deltaStream.bin
      write deltaStreamPath buildDelta [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: deltaConstants/remainingBytes
         oldData: to binary! "aa"
         newData: to binary! "bb"
      ]
      expected: buildDelta [
         operation: deltaConstants/operation/replace
         operationSize: deltaConstants/remainingBytes
         newData: to binary! "bb"
      ]

      system/options/args: reduce ["makeDeltaNonReversible" deltaStreamPath]
      do cliPath
      actual: read/binary deltaStreamPath

      redunit/assert-equals expected actual
   ]

   test-makeDeltaReversible-writesChange-givenValidStreams: function [] [
      beforeStreamPath: clean-path append copy tempDir %beforeStream.bin
      write beforeStreamPath "aa"
      deltaStreamPath: clean-path append copy tempDir %deltaStream.bin
      write deltaStreamPath buildDelta [
         operation: deltaConstants/operation/replace
         operationSize: deltaConstants/remainingBytes
         newData: to binary! "bb"
      ]
      expected: buildDelta [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: deltaConstants/remainingBytes
         oldData: to binary! "aa"
         newData: to binary! "bb"
      ]

      system/options/args: reduce ["makeDeltaReversible" beforeStreamPath deltaStreamPath]
      do cliPath
      actual: read/binary deltaStreamPath

      redunit/assert-equals expected actual
   ]

   test-massageDelta-writesChange-givenValidStreams: function [] [
      ;don't use builder so I can show the before/after bit changes
      deltaStreamPath: clean-path append copy tempDir %deltaStream.bin
      ;011 1 0010 remove op size size 2
      ;00000000 00000001 op size 1
      ;001 0 0000 unchanged remaining
      write deltaStreamPath 2#{01110010000000000000000100100000}
      ;011 0 0001 remove op size 1
      ;001 0 0000 unchanged remaining
      expected: 2#{0110000100100000}

      system/options/args: reduce ["massageDelta" deltaStreamPath]
      do cliPath
      actual: read/binary deltaStreamPath

      redunit/assert-equals expected actual
   ]

   test-undoDelta-writesChange-givenValidStreams: function [] [
      afterStreamPath: clean-path append copy tempDir %afterStream.bin
      write afterStreamPath "b"
      deltaStreamPath: clean-path append copy tempDir %deltaStream.bin
      write deltaStreamPath buildDelta [
         operation: deltaConstants/operation/reversibleReplace
         operationSize: deltaConstants/remainingBytes
         oldData: to binary! "a"
         newData: to binary! "b"
      ]
      expected: "a"

      beforeStreamPath: clean-path append copy tempDir %beforeStream.bin
      system/options/args: reduce ["undoDelta" afterStreamPath deltaStreamPath beforeStreamPath]
      do cliPath
      actual: read beforeStreamPath

      redunit/assert-equals expected actual
   ]
]
;don't bother deleting the files in the includes. the files are git ignored
