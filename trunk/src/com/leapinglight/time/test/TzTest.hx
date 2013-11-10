package com.leapinglight.time.test;
import haxe.Int64;
import haxe.unit.TestCase;
import com.leapinglight.time.TZInfo;

/**
 * ...
 * @author ...
 */
class TzTest extends TestCase
{

	public function testReadZoneNames() {
		var l = new List<String>();
		TZInfo.readZones(l);
		assertEquals(570, l.length);
	}
	
	public function testEuropeOslo() {
		var tz:TZInfo = new TZInfo("Europe/Oslo");
		var actual:SimpleTime = tz.toUTC(1978, 4, 12, 19, 20);
		var expected = SimpleTime.fromYMDHM(1978, 4, 12, 18, 20);
		assertEquals(expected.toString(), actual.toString());
		tz = new TZInfo("Europe/Oslo");
		actual = tz.toUTC(1981, 4, 12, 19, 20);
		expected = SimpleTime.fromYMDHM(1981, 4, 12, 17, 20);
		assertEquals(expected.toString(), actual.toString());
		
		actual = tz.toUTC(1940, 1, 1, 19, 20);
		expected = SimpleTime.fromYMDHM(1940, 1, 1, 18, 20);
		assertEquals(expected.toString(), actual.toString());
		// DST all year during the war:
		actual = tz.toUTC(1941, 1, 1, 19, 20);
		expected = SimpleTime.fromYMDHM(1941, 1, 1, 17, 20);
		assertEquals(expected.toString(), actual.toString());
	}
	
}