package com.leapinglight.time;

import com.leapinglight.io.Assets;
import com.leapinglight.io.ByteArray;
import com.leapinglight.io.Endian;
import haxe.Int64;

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
		var zoneTime:Int;
		if (year < UTC.MIN_YEAR_32BIT) {
			// This early it is allways the first anyways...
			zoneTime = UTC.INT_MIN_VAL;
		} else {
			zoneTime = UTC.toSecsSinceEpoch(year, month, day, h, m);
		}
		var t:TZType = getTZ(zoneTime);
		
		var secs = UTC.mktime64(SimpleTime.fromYMDHM(year, month, day, h, m));
		
		return UTC.gmtime64(Int64.sub(secs, Int64.ofInt(t.offset)));
	}	

	
	public function new(zoneName:String) 
	{
		this.tztypes = new Array/*List*/<TZType>();
		this.loadZoneFromAll(zoneName);
	}
	
	#if openfl
	// Cache statically when using OpenFL
	// Android seems to crash otherwise
	static var  data = Assets.getBytes("assets/tz/tzall.dat");
	#end
	
	private static function getStream():ByteArray
	{
		#if !openfl
		var data = Assets.getBytes("assets/tz/tzall.dat");
		#end
		data.endian = Endian.LITTLE_ENDIAN;
		data.position = 0;
		return data;
	}

	public static function readZones(target : List<String>):Int
	{
		var i = 0;
		var reader:ByteArray = getStream();
		reader.position = 0;
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
		return r.readUTFBytes(size);
	}
	
	function loadZoneFromAll(zoneName:String):Void {
		if (zoneName == null) {
			throw "Zone is NULL";
		}
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
				return;
			}
			else
			{
				reader.position += dataLength;
			}
		}
		throw "No such zone: " + zoneName;
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
		var n = 0;
		while (tztypes[n].dst && n < tztypes.length) {
			++n;
		}
		normalTZ = tztypes[n];
		
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
