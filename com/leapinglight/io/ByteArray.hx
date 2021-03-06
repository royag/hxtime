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
		if (value > bytes.length) {
			throw "End of Stream";
		}
		bytesAvailable = bytes.length - value;
		return position = value;
	}
	
	public function readInto(dst:Bytes) {
		dst.blit(0, bytes, position, dst.length);
		position += dst.length;
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
	
	public inline function readUnsignedInt() : Int {
		// unsigned will be same, or will be wrong when cast to Int anyways...
		return readInt();
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
	
	public function readShort() : Int {
		// TODO hmmm...
		/*return readUnsignedShort();
		var sign = v[0] & (1 << 7);
		var i = ((v[0] & 0x7F) << 8) | v[1];
		if (sign) {
			i = -i;
		}*/
		var p = position;
		position += 2;
		if (endian == Endian.LITTLE_ENDIAN) {
			return Pack.littleEndianToSignedShort(bytes, p);
		} else {
			throw "not yet supported";
			//return Pack.bigEndianToUnsignedShort(bytes, p);
		}		
	}
	
	public function readByte() : Int {
		// TODO signed or unsigned ????
		var p = position;
		position++;
		return bytes.get(p);
	}
	
	public inline function readUnsignedByte() : Int {
		// TODO hmmm...
		return readByte();
	}
	
	public function readUTFBytes(len:Int) : String {
		var p = position;
		position += len;
		return bytes.getString(p, len); // .readString(p, len);
	}
}
#end