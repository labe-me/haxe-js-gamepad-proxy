enum Button {
    FACE_1; // 0
    FACE_2; // 1
    FACE_3; // 2
    FACE_4; // 3
    LEFT_SHOULDER; // 4
    RIGHT_SHOULDER; // 5
    LEFT_SHOULDER_BOTTOM; // 6
    RIGHT_SHOULDER_BOTTOM; // 7
    SELECT; // 8
    START; // 9
    LEFT_ANALOGUE_STICK; // 10
    RIGHT_ANALOGUE_STICK; // 11
    PAD_TOP; // 12
    PAD_BOTTOM; // 13
    PAD_LEFT; // 14
    PAD_RIGHT; // 15
}
enum Axe {
    LEFT_ANALOGUE_HORIZONTAL;
    LEFT_ANALOGUE_VERTICAL;
    RIGHT_ANALOGUE_HORIZONTAL;
    RIGHT_ANALOGUE_VERTICAL;
}

typedef Gamepad = {
    var id : String;
    var index : Int;
    var axes : Array<Float>;
    var buttons : Array<Float>;
    var timestamp : Float;
};

@:expose
class GamepadProxy {
    public static var REMOTE_CX_NAME = "gamepad";
    public static var cnx : haxe.remoting.Connection = null;

    #if js
    static var gamePads : Array<Gamepad> = [];

    inline static function getGamepadsFunc() : Void->Array<Gamepad> {
        return untyped js.Browser.navigator.webkitGetGamepads;
    }

    public static function getGamepads(){
        if (getGamepadsFunc() != null){
            var pads : Array<Gamepad> = getGamepadsFunc()();
            for (i in 0...pads.length)
                gamePads[i] = pads[i];
        }
        return gamePads;
    }

    public static function setup(){
        if (getGamepadsFunc() == null){
            js.Browser.window.addEventListener("MozGamepadConnected", function(e){
                var g : Gamepad = untyped e.gamepad;
                gamePads[g.index] = g;
            });
            js.Browser.window.addEventListener("MozGamepadDisconnected", function(e){
                var g : Gamepad = untyped e.gamepad;
                gamePads[g.index] = null;
            });
        }
    }
    #end

    #if flash
    public static function getGamepads() : Array<Gamepad> {
        return cnx.GamepadProxy.getGamepads.call([]);
    }
    #end

    public static function start(#if js swfID:String #end){
        #if js
        setup();
        #end
        var ctx = new haxe.remoting.Context();
        ctx.addObject("GamepadProxy", GamepadProxy);
        #if js
        cnx = haxe.remoting.ExternalConnection.flashConnect(REMOTE_CX_NAME, swfID, ctx);
        #elseif flash
        cnx = haxe.remoting.ExternalConnection.jsConnect(REMOTE_CX_NAME, ctx);
        #end
    }
}