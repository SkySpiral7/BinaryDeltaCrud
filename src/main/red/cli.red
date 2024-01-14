Red [
   Title: "Entrance for cli"
]

do %deltaApplier.red
do %deltaGenerator.red
do %deltaManipulator.red
do %gui.red
;print ""  ;to separate from the junk that view prints

;https://codeberg.org/hiiamboris/red-cli might be handy

;context prevents variable bleed since I can't use /local outside of func
context [
   either (empty? system/options/args) or (system/options/args/1 == "gui") [
      gui/launch
   ] [
      switch/default system/options/args/1 [
         "applyDelta" [
            ;beforeStreamFile deltaStreamFile => afterStreamFile
            beforeStream: read/binary (to file! system/options/args/2)
            deltaStream: read/binary (to file! system/options/args/3)
            afterStream: deltaApplier/applyDelta beforeStream deltaStream
            write (to file! system/options/args/4) afterStream
         ]
         "generateDelta" [
            ;beforeStreamFile afterStreamFile => deltaStreamFile
            beforeStream: read/binary (to file! system/options/args/2)
            afterStream: read/binary (to file! system/options/args/3)
            deltaStream: deltaGenerator/generateDelta beforeStream afterStream
            write (to file! system/options/args/4) deltaStream
         ]
         "makeDeltaNonReversible" [
            ;deltaStreamFile => deltaStreamFile
            deltaStream: read/binary (to file! system/options/args/2)
            deltaStream: deltaManipulator/makeDeltaNonReversible deltaStream
            write (to file! system/options/args/2) deltaStream
         ]
         "makeDeltaReversible" [
            ;beforeStreamFile deltaStreamFile => deltaStreamFile
            beforeStream: read/binary (to file! system/options/args/2)
            deltaStream: read/binary (to file! system/options/args/3)
            deltaStream: deltaManipulator/makeDeltaReversible beforeStream deltaStream
            write (to file! system/options/args/3) deltaStream
         ]
         ; "massageDelta" [
         ;    ;deltaStreamFile => deltaStreamFile
         ;    deltaStream: read/binary (to file! system/options/args/2)
         ;    deltaStream: deltaManipulator/massageDelta deltaStream
         ;    write (to file! system/options/args/2) deltaStream
         ; ]
         "undoDelta" [
            ;afterStreamFile deltaStreamFile => beforeStreamFile
            afterStream: read/binary (to file! system/options/args/2)
            deltaStream: read/binary (to file! system/options/args/3)
            beforeStream: deltaApplier/undoDelta afterStream deltaStream
            write (to file! system/options/args/4) beforeStream
         ]
      ] [
         print to string! reduce [
            "gui" newline
            "applyDelta beforeStreamFile deltaStreamFile => afterStreamFile" newline
            "generateDelta beforeStreamFile afterStreamFile => deltaStreamFile" newline
            "makeDeltaNonReversible deltaStreamFile => deltaStreamFile" newline
            "makeDeltaReversible beforeStreamFile deltaStreamFile => deltaStreamFile" newline
            ;"massageDelta deltaStreamFile => deltaStreamFile" newline
            "undoDelta afterStreamFile deltaStreamFile => beforeStreamFile" newline
            "help"
         ]
      ]
   ]
]
