package com.leapinglight.io;
#if openfl
typedef ByteArray = flash.utils.ByteArray;
#else 
import haxe.io.Bytes;


class ByteArray
{
	
	public var endian(default, default) : Endian;
	public var position(default, set) : Int;
	public var bytesAvailable(default, null) : Int;	
	private var bytes:Bytes;
	
	public function new(b:Bytes) {
		bytes = b;
		position = 0;
		endian = Endian.LITTLE_ENDIAN;
		bytesAvailable = b.length;
	}
	
	function set_position(value) {
		if (value >= bytes.length) {
			throw "End of Stream";
		}
		bytesAvailable = bytes.length - value;
		return position = value;
	}
	
	public function readInt() : Int {
		var p = position;
		position += 4;
		if (endian == Endian.LITTLE_ENDIAN) {
			return Pack.littleEndianToInt(bytes, p);
		} else {
			return Pack.bigEndianToInt(bytes, p);
		}
	}
	
	public function readUnsignedShort() : Int {
		var p = position;
		position += 2;
		if (endian == Endian.LITTLE_ENDIAN) {
			return Pack.littleEndianToUnsignedShort(bytes, p);
		} else {
			return Pack.bigEndianToUnsignedShort(bytes, p);
		}
	}
	
	public function readByte() : Int {
		// signed or unsigned ????
		var p = position;
		position++;
		return bytes.get(p);
	}
	
	public function readUTFBytes(len:Int) : String {
		var p = position;
		position += len;
		return bytes.readString(p, len);
	}
}
#end