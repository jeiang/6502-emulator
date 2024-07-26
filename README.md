# 6502 Emulator in Zig

I roughly followed [this video](https://www.youtube.com/watch?v=qJgsuQoy9bc&t=347s) but did it in zig.

## Future Goals

- Load a ROM and run it, add graphics

## Misc Notes to Self

Maybe using async proper "cycles" could be done (e.g. every time cycles is decremented, suspend). need to wait
for zig to implement async in stage 2 tho (or go back to 10.1 but i probably wont)

## TODO

- [ ] add extra tests for every opcode to cover every possible case
- [ ] Consider whether cpu should have mem as a field and internally access it.
- [X] ~~Consider analyzing the bits of the opcodes to see if it makes sense to separate the instruction from the 
addressing mode and generate the opcode on the fly.~~
  - Ended up just using the enum names & comptime to generate switch statements for both instruction & addressing mode.

## Other Notes

I may or may not finish this. IDK how "clean"/"cool" this code is, so pls don't judge me too hard.
