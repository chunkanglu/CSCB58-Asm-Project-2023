# CSCB58 Assembly Project 2023
Welcome to my submission of the final project for CSCB58 at UofT. It's a simple platformer game built in MIPS assembly where you just want to get to the goalpost
and pass all 3 levels to beat the game. All art is made by yours truly and it is definitely not *ha ha amogus dead meme funny*. For other (possibly future) B58 students that happen to stumble upon here, you can use this
as reference but don't copy code :) (you probably shouldn't as its quite messy anyways).

`img_conv.py` is a small python script that can resize and output the code needed to draw the provided image **for this screen configuration**, other screen sizes
will require some minor adjustments.

## How to run
0. Download/Clone this repo
1. Open the MARS Simulator
2. Assemble game.asm (main file)
3. Go to Tools > Bitmap display, set unit width & height to 8, display width & height to 512, base address to $gp, and press Connect to MIPS
4. Go to Tools > Keyboard and Display MMO Simulator and press Connect to MIPS
5. Run code & type in the keyboard portion to move character

