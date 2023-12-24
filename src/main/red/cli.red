Red [
   Title: "Entrance for cli"
]

#include %main.red
#include %gui.red
print ""  ;to separate from the junk that view prints

either (empty? system/options/args) or (system/options/args/1 = "gui") [
   gui/launch
] [
   switch/default system/options/args/1 [
      "applyDelta" [
         beforeStream: to binary! read (to file! system/options/args/2)
         deltaStream: to binary! read (to file! system/options/args/3)
         afterStream: main/applyDelta beforeStream deltaStream
         write (to file! system/options/args/4) afterStream
      ]
   ] [
      ;TODO: untab help
      print {
         gui
         applyDelta beforeStream deltaStream => afterStream
         generateDelta beforeStream afterStream => deltaStream
         makeDeltaNonReversible deltaStream => deltaStream
         makeDeltaReversible beforeStream deltaStream => deltaStream
         undoDelta afterStream deltaStream => beforeStream
         help
      }
   ]
]
