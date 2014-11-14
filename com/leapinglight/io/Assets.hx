package com.leapinglight.io;

#if openfl
typedef Assets = openfl.Assets;
#else

#if java
import haxe.Resource;
#end

import sys.io.File;

class Assets
{

	public static function getBytes(path:String) {
		#if java
		return new ByteArray(Resource.getBytes(path));
		#else
		return new ByteArray(File.getBytes(path));
		#end
	}
	
	public static function getText(path:String) {
		#if java
		return Resource.getString(path);
		#else
		return File.getContent(path);
		#end
	}
	
}
#end