Red [
   Title: "Entrance for cli"
]

do %main.red
do %gui.red
print ""  ;to separate from the junk that view prints

;https://codeberg.org/hiiamboris/red-cli might be handy
;context prevents variable bleed since I can't use /local outside of func
context [
   either (empty? system/options/args) or (system/options/args/1 == "gui") [
      gui/launch
   ] [
      switch/default system/options/args/1 [
         "applyDelta" [
            beforeStream: read/binary (to file! system/options/args/2)
            deltaStream: read/binary (to file! system/options/args/3)
            afterStream: main/applyDelta beforeStream deltaStream
            write (to file! system/options/args/4) afterStream
         ]
      ] [
         print to string! reduce [
            "gui" newline
            "applyDelta beforeStreamFile deltaStreamFile => afterStreamFile" newline
            "generateDelta beforeStreamFile afterStreamFile => deltaStreamFile" newline
            "makeDeltaNonReversible deltaStreamFile => deltaStreamFile" newline
            "makeDeltaReversible beforeStreamFile deltaStreamFile => deltaStreamFile" newline
            "undoDelta afterStreamFile deltaStreamFile => beforeStreamFile" newline
            "help"
         ]
      ]
   ]
]
