
data = "53 54 41 52 23 00 DC FF".replace(' ', '')
data = bytearray.fromhex(data)
if data[:4] != b"STAR":
    print("Not a RATS tag")
else:
    size = int.from_bytes(data[4:6], byteorder='little')
    bitxor_size = int.from_bytes(data[6:8], byteorder='little')
    if size ^ bitxor_size != 0xffff:
        print("Invalid size")
    print("Size:", size + 1)


class Sprite:
    number: int
    screen_number: int
    x_position: int
    y_position: int
    extra_bits: int

    def __init__(self, number: int, screen_number: int, x_position: int, y_position: int, extra_bits: int):
        self.number = number
        self.screen_number = screen_number
        self.x_position = x_position
        self.y_position = y_position
        self.extra_bits = extra_bits
    
    def __str__(self):
        return f"Sprite {self.number:02X}: extra bits: {self.extra_bits:02X}, screen number: {self.screen_number:02X}, X Pos: {self.x_position:02X}, Y Pos {self.y_position:02X}"

actual_data = """88 19 D0 4D 00 00 00 00 19 F0 4D 00 00 00 00 51 01 B9 19 11 4D 00 00 00 00 19 31 4D 00 00 00 00 31 A1 78""".replace(' ', '')
actual_data = bytearray.fromhex(actual_data)
header_byte = actual_data[0]
index = 0
i = 1
while i < len(actual_data):
    sprite = actual_data[i:i+3]
    if i + 4 < len(actual_data):
        # for simplicity we assume that if the next byte is a 00 that's extra byte data
        # this only works in this specific case but it's enough to parse the data correctly
        is_next_extra_byte = actual_data[i + 4] == 0
    else:
        is_next_extra_byte = False
    if is_next_extra_byte:
        # for simplicity we assume that we have 4 extra bytes
        i += 7
    else:
        i += 3
    # format: yyyyEESY    XXXXssss    NNNNNNNN
    sprite_number = sprite[2]
    sprite_extra_bits = (sprite[0] & 0b00001100) >> 2
    sprite_screen_number = ((sprite[0] & 0b10) << 3) | (sprite[1] & 0b1111)
    sprite_y_position = ((sprite[0] & 0b1) << 4) | ((sprite[0] & 0b11110000) >> 4)
    sprite_x_position = (sprite[1] & 0b11110000) >> 4
    spr = Sprite(sprite_number, sprite_screen_number, sprite_x_position, sprite_y_position, sprite_extra_bits)
    index += 1
    print(spr)