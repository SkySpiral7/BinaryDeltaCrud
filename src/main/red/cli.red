Red [
    Title: "Entrace for cli"
]

; TODO: if no args then cli
arg1: to integer! system/options/args/1
arg2: to integer! system/options/args/2

#include %main.red

print main/add arg1 arg2

; if system/options/args
; foreach singleArg system/options/args [print ["> " singleArg]]
