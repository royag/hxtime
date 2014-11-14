package com.leapinglight.io;

#if openfl
typedef Assets = openfl.Assets;
#else

#if (php||java)
import haxe.Resource;
#end

import sys.io.File;

class Assets
{

	public static function getBytes(path:String) {
		#if (php || java)
		var path2 = path;
		#if php
		path2 = StringTools.replace(path2, "/", "_") + ".pl";
		#end
		try {
			return new ByteArray(Resource.getBytes(path2));
		} catch (e:Dynamic) {
			return new ByteArray(File.getBytes(path));
		}
		#else
		return new ByteArray(File.getBytes(path));
		#end
	}
	
	public static function getText(path:String) {
		#if (php || java)
		var path2 = path;
		#if php
		path2 = StringTools.replace(path2, "/", "_") + ".pl";
		#end
		try {
			return Resource.getString(path2);
		} catch (e:Dynamic) {
			return File.getContent(path);
		}
		#else
		return File.getContent(path);
		#end
	}
	
}
#end