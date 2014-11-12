package com.leapinglight.io;

#if openfl
typedef Endian = flash.utils.Endian;
#else 
enum Endian
{
	BIG_ENDIAN;
	LITTLE_ENDIAN;
}
#end