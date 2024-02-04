package debug;

import flixel.FlxG;
import flixel.FlxState;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.system.System as OpenFlSystem;
import lime.system.System as LimeSystem;
import haxe.Timer;
import haxe.Timer.stamp;
import flixel.util.FlxStringUtil;

class FPSCounter extends TextField {
    public var currentFPS(default, null):Int;
    public var memoryMegas(get, never):Float;
    public var currentStateName:String;
    public var deltaTime:Float;
    public var maxMemoryMegas:Float;

    @:noCompletion private var times:Array<Float>;

    public var os:String = '';

    public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000) {
        super();
        os = '\nOS: ${LimeSystem.platformName}' #if cpp + ' ${getArch()}' #end + (LimeSystem.platformVersion != null ? ' - ${LimeSystem.platformVersion}' : '');

        positionFPS(x, y);

        currentFPS = 0;
        selectable = false;
        mouseEnabled = false;
        defaultTextFormat = new TextFormat("_sans", 13, color, true);
        
        width = FlxG.width;
        multiline = true;
        text = "FPS: ";

        times = [];
        maxMemoryMegas = 0;
    }

    var deltaTimeout:Float = 0.0;

    private override function __enterFrame(deltaTime:Float):Void
	{
		// prevents the overlay from updating every frame, why would you need to anyways
		if (deltaTimeout > 1000) {
			deltaTimeout = 0.0;
			return;
		}

		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000) times.shift();

		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;		
		updateText(deltaTime);
		deltaTimeout += deltaTime;
	}

    public function updateText(deltaTime:Float):Void {
        var currentState:FlxState = FlxG.state;
        currentStateName = currentState != null ? Type.getClassName(Type.getClass(currentState)) : "Unknown";

        if (memoryMegas > maxMemoryMegas) {
            maxMemoryMegas = memoryMegas;
        }

        text =
            "FPS: " + currentFPS +
            "\nMemory: " + FlxStringUtil.formatBytes(memoryMegas) + "/ " + FlxStringUtil.formatBytes(maxMemoryMegas) +
            "\nCurrent State: " + currentStateName +
            "\nDelta Time: " + Std.int(deltaTime * 1000) + " ms" +
            os;
        }
        
        var red:Int = Math.sin(0.1 * haxe.Timer.stamp()) * 127 + 128;
        var green:Int = Math.sin(0.1 * haxe.Timer.stamp() + 2 * Math.PI / 3) * 127 + 128;
        var blue:Int = Math.sin(0.1 * haxe.Timer.stamp() + 4 * Math.PI / 3) * 127 + 128;

        textColor = (red << 16) | (green << 8) | blue; // Combina los valores de rojo, verde y azul para formar el color RGB 
	if (currentFPS < FlxG.drawFramerate * 0.5)
	    textColor = 0xFFFF0000;
    }

    inline function get_memoryMegas():Float
        return cast(OpenFlSystem.totalMemory, Float);

    public inline function positionFPS(X:Float, Y:Float, ?scale:Float = 1){
        scaleX = scaleY = #if mobile (scale > 1 ? scale : 1) #else (scale < 1 ? scale : 1) #end;
        x = FlxG.game.x + X;
        y = FlxG.game.y + Y;
    }

    #if cpp
	@:functionCode('
		#if defined(__x86_64__) || defined(_M_X64)
		return "x86_64";
                #elif defined(__aarch64__) || defined(_M_ARM64)
		return "aarch64";
                #elif defined(__PPC64__) || defined(__ppc64__) || defined(_ARCH_PPC64) || defined(__powerpc64__)
		return "ppc64";
                #elif defined(__IA64__) || defined(__ia64__) || defined(__itanium__) || defined(_M_IA64)
                return "IA-64"
		#elif defined(i386) || defined(__i386__) || defined(__i386) || defined(_M_IX86) || defined(_M_I86)
		return "x86";
		#elif defined(__ARM_ARCH_7S__)
		return "armv7s";
                #elif defined(__ARM_ARCH_7__) || defined(__ARM_ARCH_7A__) || defined(__ARM_ARCH_7R__) || defined(__ARM_ARCH_7M__) || defined(_M_ARM)
		return "armv7";
                #elif defined(__powerpc) || defined(__powerpc__) || defined(__POWERPC__) || defined(__ppc__) || defined(__PPC__) || defined(_ARCH_PPC) || defined(_M_PPC)
		return "ppc";
                #elif defined(__ARM_ARCH_6T2_) || defined(__ARM_ARCH_6T2_)
		return "armv6t2";
		#elif defined(__ARM_ARCH_6__) || defined(__ARM_ARCH_6J__) || defined(__ARM_ARCH_6K__) || defined(__ARM_ARCH_6Z__) || defined(__ARM_ARCH_6ZK__)
		return "armv6";
		#elif defined(mips) || defined(__mips__) || defined(__mips)
		return "mips";
                #elif defined(__sparc__) || defined(__sparc)
                return "sparc"
                #elif defined(__sh__)
                return "superh"
		#endif
	')
	@:noCompletion
	private function getArch():cpp.ConstCharStar
	{
		return null;
	}
        #end
}
