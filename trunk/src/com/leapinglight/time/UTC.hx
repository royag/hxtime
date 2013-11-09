package com.leapinglight.time;

import haxe.Int64;

class UTC
{
	
	public static function currentSecsSinceEpoch() : Int
	{
		var d:Date = Date.now();
		return toSecsSinceEpoch(d.getFullYear(), d.getMonth() + 1, d.getDay(), d.getHours(), d.getMinutes());
	}
	
	public static function toSecsSinceEpoch(year:Int, month:Int, day:Int, hour:Int, min:Int) : Int {
		return mktime(SimpleTime.fromYMDHMS(year, month, day, hour, min, 0));
	}
	
	static var  EPOCH_YR:Int     =   1970;            /* EPOCH = Jan 1 1970 00:00:00 */
	static var  SECS_DAY:Int     =   (24 * 60 * 60);

	public static inline function LEAPYEAR(year:Int) { return (0 == ((year) % 4) && (((year) % 100 != 0) || !((year) % 400 != 0))); }
	public static inline function  YEARSIZE(year:Int) { return (LEAPYEAR(year) ? 366 : 365); }
	static var  _ytab:Array<Array<Int>> = [
               [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ],
               [ 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]
          ];

	public static function mktime(time:SimpleTime) : Int {
		if (time.year < 1902) {
			throw "Time too low. Will underflow when counting back to 1901-01-01";
		}
		var ret:Int = 0;
		var y:Int = EPOCH_YR;
		var m:Int = 1;
		var d:Int = 1;
		if (time.year >= EPOCH_YR) {
			while (y < time.year) {
				ret += YEARSIZE(y) * SECS_DAY;
				y++;
			}
		} else {
			while (y > time.year) {
				y--;
				ret -= YEARSIZE(y) * SECS_DAY;
			}
		}
		while (m < time.month) {
			ret += _ytab[LEAPYEAR(time.year) ? 1 : 0][m - 1] * SECS_DAY;
			m++;
		}
		while (d < time.day) {
			ret += SECS_DAY;
			d++;
		}
		ret += (time.hour * 60 * 60) + (time.minute * 60) + time.seconds;
		return ret;
	}
	
	public static function mktime64(time:SimpleTime) : Int64 {
		var ret:Int64 = Int64.ofInt(0);
		var y:Int = EPOCH_YR;
		var m:Int = 1;
		var d:Int = 1;
		if (time.year >= EPOCH_YR) {
			while (y < time.year) {
				
				ret = Int64.add(ret,Int64.ofInt(YEARSIZE(y) * SECS_DAY));
				y++;
			}
		} else {
			while (y > time.year) {
				y--;
				ret = Int64.sub(ret,Int64.ofInt(YEARSIZE(y) * SECS_DAY));
			}
		}
		while (m < time.month) {
			ret = Int64.add(ret,Int64.ofInt(_ytab[LEAPYEAR(time.year) ? 1 : 0][m - 1] * SECS_DAY));
			m++;
		}
		while (d < time.day) {
			ret = Int64.add(ret,Int64.ofInt(SECS_DAY));
			d++;
		}
		ret = Int64.add(ret,Int64.ofInt((time.hour * 60 * 60) + (time.minute * 60) + time.seconds));
		return ret;
	}		
		  
	public static function gmtime(time:Int):SimpleTime
	{
		var timep:SimpleTime = new SimpleTime();
		var dayclock:Int;
		var dayno:Int;
		var year:Int = EPOCH_YR;
		 
        dayclock = time % SECS_DAY;
        dayno = Std.int(time / SECS_DAY);
		
		var before1970 = (time < 0);
 
        timep.seconds = dayclock % 60;
        timep.minute = Std.int((dayclock % 3600) / 60);
        timep.hour = Std.int(dayclock / 3600);
		
		if (timep.seconds < 0) {
			timep.seconds += 60;
			timep.minute -= 1;
		}
		if (timep.minute < 0) {
			timep.minute += 60;
			timep.hour -= 1;
		}
		if (timep.hour < 0) {
			timep.hour += 24;
			dayno -= 1;
		}		
		
        timep.wday = (dayno + 4) % 7;
		if (!before1970) {
			while (dayno >= YEARSIZE(year)) {
				dayno -= YEARSIZE(year);
				year++;
			}
		} else {
			while (dayno < 0) {
				dayno += YEARSIZE(year-1);
				year--;
			}
			/*if (dayno < 0) {
				dayno = 0;
			}*/
		}
        timep.year = year;
        timep.day = dayno;
        timep.month = 0;
        while (dayno >= _ytab[LEAPYEAR(year) ? 1 : 0][timep.month]) {
            dayno -= _ytab[LEAPYEAR(year) ? 1 : 0][timep.month];
            timep.month++;
			if (timep.month > 12) {
				throw "implementation error: month > 12";
			}
        }
		timep.month ++;
        timep.day = dayno + 1;
        //timep->tm_isdst = 0;
        return timep;
	}
	
	public static function gmtime64(time:Int64):SimpleTime
	{
		var timep:SimpleTime = new SimpleTime();
		var dayclock:Int64;
		var dayno:Int64;
		var SECS_DAY64 = Int64.ofInt(SECS_DAY);
		var SECS_HOUR64 = Int64.ofInt(3600);
		var SECS_MIN64 = Int64.ofInt(60);
		var year:Int = EPOCH_YR;
 
        dayclock = Int64.mod(time, SECS_DAY64);
        dayno = Int64.div(time, SECS_DAY64);
		
		var before1970 = (Int64.compare(time,Int64.ofInt(0)) < 0);
 
        timep.seconds = Int64.toInt(Int64.mod(dayclock, SECS_MIN64));
        timep.minute = Int64.toInt(Int64.div(Int64.mod(dayclock, SECS_HOUR64), SECS_MIN64));
        timep.hour = Int64.toInt(Int64.div(dayclock, SECS_HOUR64));
		
		if (timep.seconds < 0) {
			timep.seconds += 60;
			timep.minute -= 1;
		}
		if (timep.minute < 0) {
			timep.minute += 60;
			timep.hour -= 1;
		}
		if (timep.hour < 0) {
			timep.hour += 24;
			dayno = Int64.sub(dayno, Int64.ofInt(1));
		}			
		
        timep.wday = Int64.toInt(Int64.mod(Int64.add(dayno, Int64.ofInt(4)), Int64.ofInt(7)));       // day 0 was a thursday 

		
		if (!before1970) {
			while (Int64.compare(dayno,Int64.ofInt(YEARSIZE(year))) >= 0) {
				dayno = Int64.sub(dayno, Int64.ofInt(YEARSIZE(year)));
				year++;
			}
		} else {
			while (Int64.compare(dayno,Int64.ofInt(0)) < 0) {
				dayno = Int64.add(dayno, Int64.ofInt(YEARSIZE(year-1)));
				year--;
			}			
		}		
		
        timep.year = year;
        timep.day = Int64.toInt(dayno);
        timep.month = 0;
        while (Int64.compare(dayno,Int64.ofInt(_ytab[LEAPYEAR(year) ? 1 : 0][timep.month])) >= 0) { 
            dayno = Int64.sub(dayno, Int64.ofInt(_ytab[LEAPYEAR(year) ? 1 : 0][timep.month]));
            timep.month++;
			if (timep.month > 12) {
				throw "implementation error: month > 12";
			}			
        }
		timep.month ++;
        timep.day = Int64.toInt(dayno) + 1;
        //timep->tm_isdst = 0;
        return timep;
	}	
	
}