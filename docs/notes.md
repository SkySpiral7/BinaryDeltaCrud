# Things to update the spec

To word wrap use col 121: https://www.browserling.com/tools/word-wrap

## compare to other binary deltas
* Shared Dictionary Compression for HTTP deprecated because VCDIFF (RFC 3284) compression sucked compared to normal ones like GZip
   * https://datatracker.ietf.org/doc/html/rfc3284 additionally it's just very different. diff use case at the least
* https://github.com/sisong/HDiffPatch sounds like it's using other formats (ie doesn't have its own)
* patch file? doesn't do binary. you could force it but that only works if your binary happens to not have certain symbols since
   I don't think there's a way to escape them. even then it's very wasteful
* cmp -l format? wasteful and only does index replace
* https://github.com/mendsley/bsdiff didn't tell me what format is used
   * same: https://www.chromium.org/developers/design-documents/software-updates-courgette/
   * same: https://github.com/reproteq/DiffPatchWpf
   * same: https://github.com/vibhorkalley/jojodiff or https://sourceforge.net/projects/jojodiff/
* xxd etc to convert to hex then text diff: wasteful

## use cases
* version control (like git or incremental backups)
* app updates (including mods or synchronizing files between two computers)

## learn red
* red docs: https://github.com/red/docs/blob/master/en/SUMMARY.adoc
   * vid doc: https://github.com/red/docs/blob/master/en/vid.adoc
* red github wiki: https://github.com/red/red/wiki
* rebol words: http://www.rebol.com/r3/docs/functions.html
* rebol book: http://www.rebol.com/docs/core23/rebolcore.html
