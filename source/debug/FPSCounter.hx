package debug;

import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import lime.system.System as LimeSystem;
import flixel.util.FlxStringUtil;

class FPSCounter extends TextField {
    public var currentFPS(default, null):Int;
    public var memoryMegas(get, never):Float;
    public var currentStateName:String;
    public var deltaTime:Float;
    public var maxMemoryMegas:Float;
    public var cpuUsage(get, null):Float;

    private var rgbOffset:Float = 0.0;

    public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000) {
        super();
        defaultTextFormat = new TextFormat("_sans", 13, color, true);
        scaleX = scaleY = 1;
        this.x = FlxG.game.x + x;
        this.y = FlxG.game.y + y;
        selectable = false;
        mouseEnabled = false;
        width = FlxG.width;
        multiline = true;
        currentFPS = 0;
        maxMemoryMegas = 0;
    }

    private override function __enterFrame(deltaTime:Float):Void {
        updateFPS();
        updateCPUUsage();
        updateText();
    }

    private function updateFPS():Void {
        currentFPS = FlxG.elapsed == 0 ? 0 : Std.int(1.0 / FlxG.elapsed);
        rgbOffset += 0.1;
    }

    private function updateCPUUsage():Void {
        cpuUsage = LimeSystem.cpuUsage;
    }

    private function updateText():Void {
        currentStateName = FlxG.state != null ? Type.getClassName(Type.getClass(FlxG.state)) : "Unknown";

        if (memoryMegas > maxMemoryMegas) {
            maxMemoryMegas = memoryMegas;
        }

        var osInfo:String = LimeSystem.platformName;
        if (LimeSystem.platformVersion != null) {
            osInfo += ' - ' + LimeSystem.platformVersion;
        }

        var color:Int = getTextColor();
        textColor = color;

        text = "FPS: $currentFPS\nMemory: ${FlxStringUtil.formatBytes(memoryMegas)}/ ${FlxStringUtil.formatBytes(maxMemoryMegas)}\nCPU Usage: ${Std.int(cpuUsage * 100)}%\nCurrent State: $currentStateName\nDelta Time: ${Std.int(FlxG.elapsed * 1000)} ms\nOS: $osInfo";
    }

    private function getTextColor():Int {
        var red:Int = Math.sin(rgbOffset) * 127 + 128;
        var green:Int = Math.sin(rgbOffset + 2 * Math.PI / 3) * 127 + 128;
        var blue:Int = Math.sin(rgbOffset + 4 * Math.PI / 3) * 127 + 128;
        return (red << 16) | (green << 8) | blue;
    }
}