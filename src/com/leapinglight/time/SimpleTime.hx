package com.leapinglight.time;

/**
 * ...
 * @author ...
 */
class SimpleTime
        {
			public function new() { }
			public static function fromYMDHM(y, m, d, h, min) {
				var ret = new SimpleTime();
				ret.year = y; ret.month = m; ret.day = d; ret.hour = h; ret.minute = min;
				ret.seconds = 0; ret.wday = -1;
				return ret;
			}
			public static function fromYMDHMS(y, m, d, h, min, sec) {
				var ret = new SimpleTime();
				ret.year = y; ret.month = m; ret.day = d; ret.hour = h; ret.minute = min;
				ret.seconds = sec; ret.wday = -1;
				return ret;
			}			
            public var year:Int;
            public var month:Int;
            public var day:Int;
            public var hour:Int;
            public var minute:Int;
			public var seconds:Int;
			public var wday:Int;
			public function toString() {
				return Std.string(year) + "-" +
				Std.string(month) + "-" +
				Std.string(day) + " " +
				Std.string(hour) + ":" +
				Std.string(minute);
			}
        }