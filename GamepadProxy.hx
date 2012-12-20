enum Button {
    FACE_1; // 0
    FACE_2;
    FACE_3;
    FACE_4;
    LEFT_SHOULDER;
    RIGHT_SHOULDER;
    LEFT_SHOULDER_BOTTOM;
    RIGHT_SHOULDER_BOTTOM;
    SELECT;
    START;
    LEFT_ANALOGUE_STICK;
    RIGHT_ANALOGUE_STICK;
    PAD_TOP;
    PAD_BOTTOM;
    PAD_LEFT;
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

class GamepadProxy {
    public static var cnx : haxe.remoting.Connection = null;

    #if js
    static var gamePads : Array<Gamepad> = [];

    public static function getGamepads(){
        if (untyped js.Browser.navigator.webkitGetGamepads != null){
            var pads : Array<Gamepad> = untyped js.Browser.navigator.webkitGetGamepads();
            for (i in 0...pads.length)
                gamePads[i] = pads[i];
        }
        return gamePads;
    }
    #end

    #if flash
    public static function getGamepads() : Array<Gamepad> {
        return cnx.GamepadProxy.getGamepads.call([]);
    }
    #end

    public static function start(#if js swfID:String #end){
        #if js
        var avail = untyped js.Browser.navigator.webkitGetGamepads != null;
        if (!avail){
            js.Browser.window.addEventListener("MozGamepadConnected", function(e){
                gamePads.push(untyped e.gamepad);
            });
            js.Browser.window.addEventListener("MozGamepadDisconnected", function(e){
                for (i in 0...gamePads.length)
                    if (gamePads[i] != null && gamePads[i].index == untyped e.gamepad.index)
                        gamePads[i] = null;
            });
        }
        #end
        var ctx = new haxe.remoting.Context();
        ctx.addObject("GamepadProxy", GamepadProxy);
        #if js
        cnx = haxe.remoting.ExternalConnection.flashConnect("gamepad", swfID, ctx);
        #elseif flash
        cnx = haxe.remoting.ExternalConnection.jsConnect("gamepad", ctx);
        #end
    }
}