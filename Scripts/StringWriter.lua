local my_number = 9588488380;
log(string.format("%i", my_number));
local str = string.pack("i8", my_number);
log(string.format("%s, %s", type(str), str));
local str2 = string.unpack("i8", str);
log(string.format("%i", str2));