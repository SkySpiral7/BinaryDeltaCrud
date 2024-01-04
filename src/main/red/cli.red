Red [
   Title: "Entrance for cli"
]

#include %main.red
#include %gui.red
print ""  ;to separate from the junk that view prints

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
