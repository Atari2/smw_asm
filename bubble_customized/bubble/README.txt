If you've come here after the sprite hasn't inserted, I'm disappointed, if not, good job.
This .zip includes both an "almost" pure disassembly of the bubble sprite found in SMW (sprite 9D) and a custom version of it.
The disassembly is "almost" pure because if the extra bit is set to 3 instead of deciding which sprite goes inside of the bubble using the X coordinate where you placed it in the level, it will use the first EXTENSION byte (more details below), if the extra bit isn't set, it will act just like vanilla.
The custom version acts exactly as the previous version if the extra bit is set to 2, but when it has the extra bit set to 3, it will actually use all
4 of the EXTENSION bytes to decide which sprite it has inside (also more details below).
Please make sure to include the [...]_tables.asm files INSIDE of the pixi's sprite folder, otherwise it won't insert.
This .zip also includes a patch, with this patch, the CUSTOM bubbles that have the NOT edible flag set (more details below) will pop from their bubble
when touched by Yoshi's tongue instead of just doing nothing.
Everything in this .zip is SA-1 compatible.
This was disassembled by Atari2.0, all code taken from smw-irq, made by p4plus2 along with the contribution of Thomas (kaizoman) so big thanks to them. 

--------Below refers to bubble_dis.asm--------
IF the EXTRA BIT is set to 2:
Act as vanilla, sprite based on X pos.
IF the EXTRA BIT is set to 3:
Extension byte 1 settings:
00 -> goomba
01 -> bob-omb
02 -> fish
03 -> mushroom
if (extra byte 1 > 03 && extra bit == 3) -> goes back to goomba to prevent from reading from tables that don't exist

--------Below refers to bubble_dis_custom.asm--------
this sprite works differently depending on how you set the extra bit.
IF the EXTRA BIT is set to 2, you only need to set the extension byte 1, with the exact same setting as above:
00 -> goomba
01 -> bob-omb
02 -> fish
03 -> mushroom
if (extra byte 1 > 03 && extra bit == 3) -> goes back to goomba (00) to prevent from reading from tables that don't exist
However IF the EXTRA BIT is set to 3,you will need to set all 4 of the extension bytes and they will need to be as following:
extension byte 1 = sprite number (the one in Lunar Magic) of the sprite to spawn, currently doesn't support custom sprites.
extension byte 2 = YXPPCCCT properties of the 16x16 tile inside of the bubble
extension byte 3 = number of 16x16 tile to use inside of the bubble
extension byte 4 = !!!ONLY THE SECOND BIT!!!, if set the sprite is not edible by yoshi, if not set sprite is edible by yoshi. So basically if you write 00 it will be edible by yoshi, if you write 02, it won't. Keep in mind that sprites that are normally not edible will not set this automatically, for example if you put a Chuck and you don't set this byte to 02, it will be edible by Yoshi AND if eaten, the game will crash. It is YOUR responsibility to remember to set this bit.
FOR THE LOVE OF EVERYTHING PLEASE DON'T SET THE FOURTH EXTENSION BYTE TO AN ODD VALUE, like 01, 03, etc.
Quick note that the tile inside of the bubble will always be 16x16 but the bubble can spawn sprites of any size.
If you've arrived here and have read everything with attention, you can now open the .asm file of the sprite (bubble_dis_custom.asm) and change the !README = 0 to !README = 1, if you don't do this, the sprite will refuse to insert.