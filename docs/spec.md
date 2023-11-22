# Binary Delta CRUD Format Specification
I learned about the format of a (unified) patch file from the Unix command diff -u and was inspired to make a new delta
format that is very compact, supports binary (it is not human readable), and is payload type agnostic. Since I don't
know anything about this subject area I based this format on CRUD (Create, read, update, and delete) and so am calling
this format Binary Delta CRUD. Note that the use of delta here is referring to math where delta is used to show change.

The scope of this doc is only for the delta format and not for describing the algorithm to analyze the data in order to
create the delta. Analyzing the data is very important and the most complex step and would need it's own doc. However I
don't know anything about how you would do this data analysis, there's no perfect solution to this problem, and you can
read existing papers on compression and file comparison therefore I likely won't have a doc for such data analysis.

To describe this format I will use the names inputStream, deltaStream, and outputStream because the payloads might not
be files (although files are the main use case I can think of). Note it is not required to know the number of bytes
involved in a stream ahead of time as long as you know when it ends. The final operation in deltaStream will always have
an operation size of 0 (explained later). Obviously each stream must be finite. It is possible to process the streams
without needing to go backward: a buffer isn't needed if you are performing the operations normally (not reversed) or
know the size of deltaStream. Note that all numbers in this specification are unsigned big endian where a * in binary
means "any bit".

Each operation in the deltaStream starts with a single header byte which indicates which action to take and what to do
with the bytes that follow. The outline of the header byte is: the highest 3 bits is the operation, the next bit (the
lowest bit in the highest nibble) is an operation size flag, and the lowest nibble is a size (which might be the
operation size).

The operations are:
- 0 (binary 000* ****) "add" operation (C in CRUD)
- 1 (binary 001* ****) "unchanged" operation (R in CRUD mnemonic)
- 2 (binary 010* ****) "replace" operation (U in CRUD)
- 3 (binary 011* ****) "remove" operation (D in CRUD)
- 4 (binary 100* ****) "reversible replace" operation
- 5 (binary 101* ****) "reversible remove" operation
- 6-7 [unused operations] 2 spots

If the operation size flag bit is 0 then the lowest nibble is the operation size (1 to 15 bytes). If the operation size
flag bit is 1 then the lowest nibble is the size (1 to 15 bytes) of the operation size and the actual operation size
(1 to 256^15 bytes) will follow the header byte. The operation size is the number of bytes that the operation will use.
An operation size of 0 is infinite which means the operation will be performed on the remaining bytes then the program
will terminate. When the operation size flag bit is 1 the operation size is allowed to have leading 0 bytes (although
this is a waste of bytes in the deltaStream).

For example given a header (in binary) of: 0000 0010 means that 2 bytes will be added. A deltaStream that starts with
0011_0010 0000_0001 0000_0001 means that 257 bytes will be unchanged since the header indicated that the next 2 bytes
should be used for the operation size.


## Operations
"add" operation means that a number of bytes should be added to outputStream. The bytes that will be added will follow
the operation size. It is invalid if deltaStream does not have enough bytes left.

"add remaining" is an "add" operation with an operation size of 0. It means that all of the bytes remaining in
deltaStream should be added to outputStream then terminate. It is invalid for inputStream to contain any remaining
bytes. It is invalid for deltaStream to not have any more bytes (since it failed to add anything).

"unchanged" operation means that a number of bytes should remain unchanged (ie read with no-op) simply copy them from
inputStream into outputStream. No bytes will follow the operation size. It is invalid if inputStream does not have
enough bytes left.

"remaining unchanged" (ie "done" or "no more changes") is an "unchanged" operation with an operation size of 0. It means
that the remaining bytes in inputStream should be unchanged (copied to outputStream) then terminate. It is invalid for
deltaStream to contain more bytes. It is permitted for inputStream to not have any more bytes (this allows an empty file
to remain unchanged for example) since an empty set of bytes being unchanged is logically valid.

"replace" operation means that a number of bytes in deltaStream will replace the same number of bytes in the inputStream
(ie add deltaStream bytes to outputStream and ignore bytes from inputStream). The new byte values will follow the
operation size. Unlike "reversible replace" this operation is more compact but can't be undone since the previous byte
values are unknown. It is invalid if inputStream or deltaStream do not have enough bytes left.

"replace remaining" is a "replace" operation with an operation size of 0. It means that all of the bytes remaining in
deltaStream should replace the same number of bytes in inputStream then terminate (ie add rest of deltaStream to
outputStream and ignore rest of inputStream). It is invalid if inputStream and deltaStream do not have the same number
of remaining bytes. It is invalid if inputStream or deltaStream have no bytes left (since it failed to replace
anything).

"remove" operation means that a number of bytes should be removed ie these bytes in inputStream should not go to the
outputStream. No bytes will follow the operation size. Unlike "reversible remove" this operation is more compact but
can't be undone since the previous byte values are unknown. It is invalid if inputStream does not have enough bytes
left.

"remove remaining" (ie "close outputStream" or "write no more bytes") is a "remove" operation with an operation size
of 0. It means that the remaining bytes in inputStream should be removed (not sent to outputStream) then terminate
effectively making this a "close outputStream" operation since there is no more data to write (only thing left is to
validate). It is invalid for deltaStream to contain more bytes. It is invalid for inputStream to not have any more bytes
(since it failed to remove anything).

"reversible replace" operation is the same as "replace" except reversible and less compact. After the operation size
there will be that number of bytes which are the old values then that number of bytes which are the new values. This
exists so that after running through deltaStream normally you can later decide to undo the change by running the
opposite of deltaStream (assuming deltaStream is a file or something that can be referenced again). Additionally this
has a validity check built in since if the old bytes do not match inputStream then deltaStream is invalid. It is also
invalid for inputStream or deltaStream to not have enough bytes left.

"reversible replace remaining" is a "reversible replace" operation with an operation size of 0. It means that the first
half of the remaining bytes are the old values and the last half are the new values (see "reversible replace" for
details) afterwards terminate. It is invalid for deltaStream to have an odd number of bytes left. It is invalid if
deltaStream does not have exactly twice the number of bytes that remains in inputStream. It is invalid for inputStream
or deltaStream to not have any more bytes (since it failed to replace anything). While is it possible to execute
deltaStream as you get it (counting the bytes but not needing a buffer), trying to do the opposite of deltaStream will
require you to read the rest of deltaStream first. As a quick proof: start counting while validating inputStream until
it runs out (or fails validation) then count down while writing to outputStream until deltaStream runs out (or fails
validation). If doing the opposite of deltaStream you won't know when to stop writing to outputStream unless you already
know the number of bytes in deltaStream (in which case you won't need a buffer).

"reversible remove" operation is the same as "remove" except reversible and less compact. After the operation size there
will be that number of bytes which are the old values. This exists so that after running through deltaStream normally
you can later decide to undo the change by running the opposite of deltaStream (assuming deltaStream is a file or
something that can be referenced again). Additionally this has a validity check built in since if the old bytes do not
match inputStream then deltaStream is invalid. It is also invalid for inputStream or deltaStream to not have enough
bytes left.

"reversible remove remaining" is a "reversible remove" operation with an operation size of 0. It means that all of the
remaining bytes are the old values (see "reversible remove" for details) afterwards terminate. It is invalid if
inputStream and deltaStream do not have the same number of remaining bytes. It is invalid for inputStream or deltaStream
to not have any more bytes (since it failed to remove anything).


## More info
For a concrete example given that deltaStream contains (in binary): 0010_0101 0000_0010 0011_1000 0100_1110 0010_0000
translates to: unchanged with operation size 5, add with operation size 2, the first byte added is hex 38, the second
byte added is hex 4E, done (keep the rest of inputStream). A shorter description (rather than a byte by byte one) is
that the first 5 bytes are unchanged, add the hex bytes 38 and 4E, then the rest of the bytes in inputStream.

For an example of why the reversible operations exist: suppose I have a file named mainFile and a file named deltaFile.
I run a program using mainFile as inputStream, mainFile as outputStream (writing to same file), and deltaFile as
deltaStream. I examine the new state of mainFile and decide that I want it to return to the previous state (perhaps it
failed quality control or checksum). I run a program using mainFile as inputStream, mainFile as outputStream (writing to
same file), and deltaFile as deltaStream along with a flag that indicates that I would like a reverse done. If deltaFile
does not contain any of replace or remove operations (including operation size of 0) then it is possible to restore
mainFile back to the previous state by simply performing the opposite instruction in the deltaStream. This is useful for
version control systems so that it can cause a file to go forward or back a version by only looking at a single delta
(similar to git). This is likewise useful if you send out an update then later decide you need to rollback the change.
For the sake of network compactness: a reversible delta can be created from a non-reversible delta while reading it
(this requires a buffer the size of the largest replace operation).

The exact number of bytes for outputStream will be unknown until the deltaStream has been completely processed. The
maximum sizeOf(outputStream) = sizeOf(inputStream) + sizeOf(deltaStream) - 2 - sizeOf(sizeOf(inputStream)) unless
sizeOf(inputStream) is 15 or less in which case add 1 (counteracting the sizeOf sizeOf). This maximum can be achieved
with a deltaStream of: unchanged, size of inputStream, add remaining, entire deltaStream.

Note that 64 bit computers only need 8 bytes to express the maximum file size (16 EiB exbibytes) which is expressible
(in binary) ***1_1000 1111_1111 1111_1111 1111_1111 1111_1111 1111_1111 1111_1111 1111_1111 1111_1111. Notice that the
maximum number of bytes supported for operation size is 15. 15 bytes for the operation size would mean the total size
that can be handled with 1 header is 256^15 which is 1.3e36 bytes or 1.1e12 yobibytes. For any larger sizes you will
need to perform the same operation multiple times (this will never be needed).

Warning: make sure you trust the deltaStream and have enough memory/disk space to handle the various operation size 0s.
An attacker could send binary 0000 0000 followed by an endless stream of junk bytes in order to fill up the RAM or hard
drive. That said it makes little sense to allow public access to change something using a deltaStream in the first
place.


## Q&A
Does this format do better with a sparse or dense delta? It handles both very well. If an entire 4 GiB payload is being
replaced (every byte changed) the overhead is only 1 byte (replace remaining, entire payload). If only a single byte is
replaced in a 4 GiB payload the overhead is a maximum of only 7 bytes (unchanged size 4, 4 bytes op size, replace op
size 1, new byte, done) with a minimum overhead of 2 bytes (replace op size 1, new byte, done). For an unchanged payload
(of any size) the entire delta is 1 byte (done).

Does this format do better with plain text or binary payloads? The delta is not human readable. It is able to handle
binary and text/plain is just a type of binary therefore it is agnostic to payload media type. Contrast a patch file
which is designed to be human readable, can't handle binary, and includes info for the file name and date (ie it assumes
a file system).

Can this format do everything a patch file can? No: this format doesn't handle file names or last modified timestamp
(which are filesystem dependent). You could use this format 3 times for the name, modified timestamp, and file contents.
Or you could use this format on a tar etc. For multiple files you can make a delta for each file (a delta can be add all
or remove all for adding/removing files) or tar the files together and delta that. Which is to say that this format can
do what you need but since it's payload agnostic (doesn't assume files) you'll need to do bookkeeping yourself in order
to attach meaning.


## Closing
I thought of operations for flipping the bits of the bytes or filling a length with a certain specified byte but the
later is not in the spirit of a delta (that would be compression) and the former is questionable (there is still enough
space for flipping if someone wants it) so I didn't.

I thought of an operation for paste (as in copy/paste) which would require a clipboard index to be setup at the
beginning of the deltaStream. While this operation makes sense from a perspective of "how a human would edit something"
this format isn't intended for human operations and this is another operation that seems like a compression thing.
