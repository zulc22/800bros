+====================  800 BROS. ========================+
|                                                        |
|  A Super Mario Bros. clone for the Atari 8-bit series  |
|                                                        |
|                     zulc22 2021                        |
+--------------------------------------------------------+

      Written in 6502 assembler, compiled with ASM6.

              Under the WTFPL (see LICENSE).

The game is alpha-quality and is nowhere near playable or
complete yet, so don't expect much. I'll probably abandon
this next week because of neurodivergency. If this gets
anywhere I'll be surprised

Things you can do with my game:

- Play it
- Modify it
- Sell it / publish it
- Fork it
- ... WHAT THE FUCK YOU WANT TO. (see LICENSE)

I accept pull requests if you want to contribute back.

Of course if you do stuff with money, I'd *prefer* you give me
some, but it's not completely nessecary. (see LICENSE)

You can contact me on Twitter at twitter.com/compyfanman486,
or on Discord @zulc22#9801 about anything relating to the game
if you feel reason to.

== COMPILING ==

Graphics are in png format in /gfx/*.png (except the CTIA palette)
To recompile `sprites.inc` to reflect graphics changes,
    - run /gfx/makesprites.bat (Windows)
    - type 'python3 mcspazitron.py > sprites.inc' in the terminal (*nix)
(Requires Python 3.x and Pillow on your system either way)

To compile the game itself,
    - run /make.bat or /make&run.bat (Windows)
    - type 'asm6 -l disk.s 800bros.xex' (*nix)
(Requires asm6 to be installed on *nix. asm6f works as a drop-in replacement as well
 A Windows copy of asm6 comes with the repository)
