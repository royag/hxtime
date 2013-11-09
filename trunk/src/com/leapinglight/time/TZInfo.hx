package com.leapinglight.time;

import openfl.Assets;
import flash.utils.ByteArray;
import flash.utils.Endian;

	class TZType
        {
            public var name:String;
            public var offset:Int;
            public var dst:Bool;
            public function new(name:String, offset:Int, dst:Bool)
            {
                this.name = name; this.offset = offset; this.dst = dst;
            }
        }

		

class TZInfo
{
	
	private var tztypes:Array<TZType>; // IList<TZType>;
	private var normalTZ:TZType ;

	private var transTimes:Array<Int>;  // Int32[] ;	// transition times
	private var transTypes:Array<Int>; // SByte[];	// timezone description for each transition
	public static var/*long*/ secsPerThreeMonths = 60 * 60 * 24 * 30 * 3;
	private var timecnt:Int;
	private var typecnt:Int;
	
	
	
	public function getTZ(/*long*/ clock:Int):TZType
	{
		if (timecnt > 0 && clock >= transTimes[0])
		{
			var i = 1;
			//for (; i < timecnt; ++i)
			while (i < timecnt)
			{
				if (clock < transTimes[i])
				{
					break;
				}
				++i;
			}
			return tztypes[transTypes[i - 1]];
		}
		return normalTZ;
	}
	
	
	
	public function  toUTC(year:Int, month:Int, day:Int, h:Int, m:Int) : SimpleTime
	{
		//DateTime dt = new DateTime(year, month, day, h, m, 0, DateTimeKind.Utc);
		var s = UTC.toSecsSinceEpoch(year, month, day, h, m);
		var t:TZType = getTZ(s);
		
		return UTC.gmtime(s - t.offset);
		/*
		//dt = dt.AddSeconds(-t.offset);
		var sf:Float = cast(s - t.offset);
		var trf:Float = cast(timeResolution);
		var f:Float = sf*trf;
		var dt:Date = Date.fromTime(f);
		var ret:SimpleTime = new SimpleTime();
		
		ret.year = dt.getFullYear();
		ret.month = dt.getMonth() + 1;
		ret.day = dt.getDay();
		ret.hour = dt.getHours();
		ret.minute = dt.getMinutes();
		return ret;*/
	}	

	
	public function new(zoneName:String) 
	{
		this.tztypes = new Array/*List*/<TZType>();
		this.loadZoneFromAll(zoneName);
	}
	
	private static var TZDATA:ByteArray = null;

	private static function getStream():ByteArray
	{
		//return Assets.getBytes("assets/tz/tzall.dat");
		if (TZDATA == null) {
			TZDATA = Assets.getBytes("assets/tz/tzall.dat");
			TZDATA.endian = Endian.LITTLE_ENDIAN;
		}
		TZDATA.position = 0;
		return TZDATA;
	}

	public static function readZones(target : List<String>):Int
	{
		var i = 0;
		var reader:ByteArray = getStream();
		var/*UInt16*/ nameLength:Int;
		var name:String;
		var/*UInt16*/ dataLength:Int;
		while (reader.bytesAvailable > 0) {
			nameLength = reader.readUnsignedShort();
			name = readStringOfSize(reader, nameLength);
			dataLength = reader.readUnsignedShort();
			reader.position += dataLength;
			target.add(name);
			i++;
		}
		return i;
	}
	
	public static function readStringOfSize(r:ByteArray, size:Int):String
	{
		/*string ret = "";
		for (int i = 0; i < size; i++)
		{
			char c = (char)r.ReadByte();
			ret += c;
		}
		return ret;*/
		return r.readUTFBytes(size);
	}
	
	function loadZoneFromAll(zoneName:String):Void {
		var reader:ByteArray = getStream();
		reader.position = 0;
		reader.endian = Endian.LITTLE_ENDIAN;
		var/*UInt16*/ nameLength:Int;
		var name:String;
		var/*UInt16*/ dataLength:Int;
		while (reader.bytesAvailable > 0)
		{
			nameLength = reader.readUnsignedShort();
			name = readStringOfSize(reader, nameLength);
			dataLength = reader.readUnsignedShort();
			
			if (StringTools.trim(name).toLowerCase() == StringTools.trim(zoneName).toLowerCase())
			{
				loadFile(reader);
				break;
			}
			else
			{
				reader.position += dataLength;
			}
		}
	}
	
	function loadFile(ins:ByteArray) :Void {
		ins.position += 28;
		ins.endian = Endian.BIG_ENDIAN;
		var leapcnt:Int;
		var charcnt:Int;
		leapcnt = ins.readInt();
		timecnt = ins.readInt();
		typecnt = ins.readInt();
		charcnt = ins.readInt();
		
		transTimes = new Array<Int>();
		var i = 0;
		while (i < timecnt) {
			transTimes.push(ins.readInt());
			i++;
		}

		transTypes = new Array<Int>();
		i = 0;
		while (i < timecnt) {
			transTypes.push(ins.readByte());
			i++;
		}
		
		/*Int32[] offset = new Int32[typecnt];
            sbyte[] dst = new sbyte[typecnt];
            sbyte[] idx = new sbyte[typecnt];*/

		var offset:Array<Int> = new Array<Int>();
		var dst:Array<Int> = new Array<Int>();
		var idx:Array<Int> = new Array<Int>();
		
		i = 0;
		while (i < typecnt) {
			offset.push(ins.readInt());
			dst.push(ins.readByte());
			idx.push(ins.readByte());
			i++;
		}
		
		var str:Array<Int> = new Array<Int>();
		i = 0;
		while (i < charcnt) {
			str.push(ins.readByte());
			i++;
		}
		
		i = 0;
		while (i < typecnt) {
			var pos:Int = idx[i];
			var end:Int = pos;
			while (str[end] != 0) ++end;
			var name = "";
			var p = pos;
			while (p < end) {
				name += String.fromCharCode(str[p]);
				p++;
			}
			tztypes.push(new TZType(name, offset[i], dst[i] != 0));
			++i;
		}
		
		var leapSecs:Array<Int> = new Array<Int>();
		i = 0;
		while (leapcnt > 0) {
			leapSecs[i++] = ins.readInt();
			leapSecs[i++] = ins.readInt();
			--leapcnt;
		}
		
		// Set default timezone (normaltz).
		// First, set default to first non-DST rule.
		/*var n:Int = 0;
		while (tztypes[n].dst && n < tztypes.length) {
			++n;
		}*/
		//normalTZ = tztypes.[n];
		for (t in tztypes) {
			if (t.dst) {
				normalTZ = t;
				break;
			}
		}
		
		// When setting "normaltz" (the default timezone) in the constructor,
		// we originally took the first non-DST rule for the current TZ.
		// But this produces nonsensical results for areas where historical
		// non-integer time zones were used, e.g. if GMT-2:33 was used until 1918.

		// This loop, based on a suggestion by Ophir Bleibergh, tries to find a
		// non-DST rule close to the current time. This is somewhat of a hack, but
		// much better than the previous behavior in this case.

		// Tricky: we need to get either the next or previous non-dst TZ
		// We shall take the future non-dst value, by trying to add 3 months at a
		// time to the current date and searching.
		// (QT 4.7 only) qint64 ts = QDateTime::currentMSecsSinceEpoch() / 1000;
		/*long ts = currentSecsSinceEpoch(); //::currentDateTime().toTime_t();
		//final long ts = System.currentTimeMillis() / 1000;
		
		for (int i = 0; i < 9; i++)
		{
			TZType currTz = getTZ(ts + secsPerThreeMonths * i);
			if (!currTz.dst)
			{
				normalTZ = currTz;
				break;
			}
		}*/
		var ts = UTC.currentSecsSinceEpoch();
		i = 0;
		while (i < 9) {
			var currTz = getTZ(ts + secsPerThreeMonths * i);
			if (!currTz.dst)
			{
				normalTZ = currTz;
				break;
			}			
			i++;
		}
		
		
	}
	
}
