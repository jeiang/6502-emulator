# 6502 Emulator in Zig

I roughly followed [this video](https://www.youtube.com/watch?v=qJgsuQoy9bc&t=347s) but did it in zig.

## Misc Notes to Self

Maybe using async proper "cycles" could be done (e.g. every time cycles is decremented, async suspend);

Consider whether cpu should have mem as a field and internally access it.
