package ;

#if openfl
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
#end

import com.leapinglight.time.test.TzTest;
import com.leapinglight.time.test.UTCTest;
import haxe.unit.TestRunner;

/**
 * ...
 * @author Roy
 */

#if openfl
class Main extends Sprite
#else
class Main
#end
{
	static function runTests() {
		var r = new TestRunner();
		
        r.add(new TzTest());
		r.add(new UTCTest());

        r.run();
		trace(r.result.toString());
	}
	
	#if !openfl
	public static function main() 
	{
		runTests();
	}	
	#else
	var inited:Bool;

	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;

		// (your code here)
		
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
		
		runTests();
	}
	#end
	
}
