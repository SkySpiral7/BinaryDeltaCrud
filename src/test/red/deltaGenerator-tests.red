Red [
   Title: "tests for deltaGenerator"
]

do %../../main/red/buildDelta.red
do %../../main/red/deltaConstants.red

context [
   setup: function [
      "Initialize/Reload context before each test"
   ] [
      do %../../main/red/deltaGenerator.red
   ]

   test-generateDelta-returnsUnchangedAll-givenSameStreams: function [] [
      beforeStream: to binary! "same"
      afterStream: copy beforeStream
      expected: buildDelta [
         operation: deltaConstants/operation/unchanged
         operationSize: deltaConstants/remainingBytes
      ]

      actual: catch [deltaGenerator/generateDelta beforeStream afterStream]

      redunit/assert-equals expected actual
   ]

   test-generateDelta-returnsUnchangedHeaderThenRemove-givenSameStartThenShort: function [] [
      beforeStream: to binary! "hill"
      afterStream: to binary! "hi"
      expected: copy #{}
      append expected (
         buildDelta [
            operation: deltaConstants/operation/unchanged
            operationSize: 2
         ]
      )
      append expected (
         buildDelta [
            operation: deltaConstants/operation/remove
            operationSize: deltaConstants/remainingBytes
         ]
      )

      actual: catch [deltaGenerator/generateDelta beforeStream afterStream]

      redunit/assert-equals expected actual
   ]

   test-generateDelta-returnsAdd-givenShort: function [] [
      beforeStream: #{}
      afterStream: to binary! "hi"
      expected: buildDelta [
         operation: deltaConstants/operation/add
         operationSize: deltaConstants/remainingBytes
         newData: copy afterStream
      ]

      actual: catch [deltaGenerator/generateDelta beforeStream afterStream]

      redunit/assert-equals expected actual
   ]

   test-generateDelta-returnsReplaceThenDone-givenOnlyDiff: function [] [
      beforeStream: to binary! "aa"
      afterStream: to binary! "bb"
      expected: copy #{}
      append expected (
         buildDelta [
            operation: deltaConstants/operation/replace
            operationSize: 2
            newData: to binary! "bb"
         ]
      )
      append expected (
         buildDelta [
            operation: deltaConstants/operation/unchanged
            operationSize: deltaConstants/remainingBytes
         ]
      )

      actual: catch [deltaGenerator/generateDelta beforeStream afterStream]

      redunit/assert-equals expected actual
   ]
]
