package com.leapinglight.io;

#if openfl
typedef Assets = openfl.Assets;
#else

import sys.io.File;

class Assets
{

	public static function getBytes(path:String) {
		return new ByteArray(File.getBytes(path));
	}
	
}
#end