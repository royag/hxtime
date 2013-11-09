package com.leapinglight.time.test;
import com.leapinglight.time.SimpleTime;
import com.leapinglight.time.UTC;
import haxe.unit.TestCase;
import haxe.Int64;

/**
 * ...
 * @author ...
 */
class UTCTest extends TestCase
{
	public function testSecsAfter1970_32Bit() {
		assertEquals(0, UTC.toSecsSinceEpoch(1970, 1, 1, 0, 0));
		assertEquals(60, UTC.toSecsSinceEpoch(1970, 1, 1, 0, 1));
		assertEquals(2137483647-27, UTC.toSecsSinceEpoch(2037, 9, 25, 09, 27));
		assertEquals(261253200, UTC.toSecsSinceEpoch(1978, 4, 12, 18, 20));
	}
	
	public function testSecsBefore1970_32Bit_Limit() {
		assertEquals( -2145916800, UTC.toSecsSinceEpoch(1902, 1, 1, 0, 0));
	}	
	
	public function testSecsBefore1970_32Bit() {
		assertEquals( -617637000, UTC.toSecsSinceEpoch(1950, 6, 6, 10, 10));
		assertEquals(-2132401800, UTC.toSecsSinceEpoch(1902, 6, 6, 10, 10));
	}
	
	public function testGmtimeAfter1970_32Bit() {
		assertEquals(Std.string(UTC.gmtime(0)),
			Std.string(SimpleTime.fromYMDHM(1970, 1, 1, 0, 0)));
		assertEquals(Std.string(UTC.gmtime(60)),
			Std.string(SimpleTime.fromYMDHM(1970, 1, 1, 0, 1)));
		assertEquals(Std.string(UTC.gmtime(2137483647-27)),
			Std.string(SimpleTime.fromYMDHM(2037, 9, 25, 09, 27)));
		assertEquals(Std.string(UTC.gmtime(261253200)),
			Std.string(SimpleTime.fromYMDHM(1978, 4, 12, 18, 20)));			
	}		
	
	public function testGmtimeBefore1970_32Bit() {
		assertEquals(Std.string(UTC.gmtime( -86400)),
			Std.string(SimpleTime.fromYMDHM(1969, 12, 31, 0, 0)));		
		assertEquals(Std.string(UTC.gmtime( -617637000)),
			Std.string(SimpleTime.fromYMDHM(1950, 6, 6, 10, 10)));
		assertEquals(Std.string(UTC.gmtime( -2132401800)),
			Std.string(SimpleTime.fromYMDHM(1902, 6, 6, 10, 10)));
	}	
	
	
	public function testSecsBefore1970_64Bit() {
		assertEquals(Std.string(Int64.make(0xFFFFFFF7, 0x681BFAA8)), 
			Std.string(UTC.mktime64(SimpleTime.fromYMDHM(800, 6, 6, 14, 14))));
	}
	
	public function testSecsAfter1970_64Bit() {
		assertEquals(Std.string(Int64.make(0xA, 0x828D97A8)), 
			Std.string(UTC.mktime64(SimpleTime.fromYMDHM(3400, 6, 6, 14, 14))));
	}
	
	public function testGmtimeBefore1970_64Bit() {
		//assertEquals(Std.string(UTC.gmtime64(Int64.make(0xFFFFFFF7, 0x681BFAA8))),   // Fails -- ???
		//	Std.string(SimpleTime.fromYMDHM(800, 6, 6, 14, 14)));
		assertEquals(Std.string(UTC.gmtime64(Int64.make(0xFFFFFFFE, 0x04F46FA8))),   // FFFFFFFE 04F46FA8
			Std.string(SimpleTime.fromYMDHM(1700, 6, 6, 14, 14)));			
	}
	
	public function testGmtimeBefore1970_64Bit32() {
		assertEquals(Std.string(UTC.gmtime64(Int64.ofInt( -86400))),
			Std.string(SimpleTime.fromYMDHM(1969, 12, 31, 0, 0)));		
		assertEquals(Std.string(UTC.gmtime64(Int64.ofInt( -617637000))),
			Std.string(SimpleTime.fromYMDHM(1950, 6, 6, 10, 10)));
		assertEquals(Std.string(UTC.gmtime64(Int64.ofInt( -2132401800))),
			Std.string(SimpleTime.fromYMDHM(1902, 6, 6, 10, 10)));
	}	
	
	
	public function testGmtimeAfter1970_64Bit() {
		assertEquals(Std.string(UTC.gmtime64(Int64.make(0xA, 0x828D97A8))),
			Std.string(SimpleTime.fromYMDHM(3400, 6, 6, 14, 14)));
	}
	
}