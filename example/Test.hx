import flash.geom.Vector3D;
import flash.display.Bitmap;

class Test {
    static var game : Game;
    public static var gamepads : Array<GamepadProxy.Gamepad> = [];

    public static function main(){
        GamepadProxy.start();
        game = new Game();
        flash.Lib.current.addChild(game);
        flash.Lib.current.stage.addEventListener(flash.events.Event.ENTER_FRAME, update);
    }

    public static function update(_){
        gamepads = GamepadProxy.getGamepads();
        haxe.Log.clear();
        var i = 0;
        for (gamepad in gamepads){
            if (gamepad == null){
                trace("No gamepad "+i);
            }
            else {
                trace("id: "+gamepad.id);
                trace("axes: "+gamepad.axes);
                trace("buttons: "+gamepad.buttons);
            }
            ++i;
        }
        try {
            game.update();
        }
        catch (e:Dynamic){
            trace(e);
        }
    }
}

@:bitmap("bullet.png") class BMBullet extends flash.display.BitmapData {}
@:bitmap("ship.png") class BMShip extends flash.display.BitmapData {}

class Entity extends flash.display.Bitmap {
    public var vel : Vector3D;
    public var acc : Vector3D;
    public var maxSpeed : Float;

    public function new(b){
        super(b);
        maxSpeed = 999999;
        vel = new Vector3D(0,0,0);
        acc = new Vector3D(0,0,0);
    }

    public function update(){
        vel.incrementBy(acc);
        if (vel.lengthSquared >= maxSpeed*maxSpeed){
            vel.normalize();
            vel.scaleBy(maxSpeed);
        }
        x += vel.x;
        y += vel.y;
    }
}

class Ship extends Entity {
    public function new(){
        super(new BMShip(0,0));
    }
}

class Bullet extends Entity {
    static var bmp : BMBullet = new BMBullet(0,0);
    public function new(){
        super(bmp);
    }
}

class Game extends flash.display.Sprite {
    var ship : Ship;
    var bullets : Array<Bullet>;
    var lastShot : Float;
    var shotRate : Float;

    public function new(){
        super();
        ship = new Ship();
        ship.maxSpeed = 4;
        ship.x = flash.Lib.current.stage.stageWidth / 2;
        ship.y = flash.Lib.current.stage.stageHeight / 2;
        addChild(ship);
        bullets = [];
        lastShot = 0.0;
        shotRate = 1 / 10;
    }

    public function update(){
        var now = haxe.Timer.stamp();
        var gamepad = if (Test.gamepads != null) Test.gamepads[0] else null;
        if (gamepad != null){
            if (gamepad.buttons[0] > 0.5 && now - lastShot > shotRate){
                lastShot = now;
                var bullet = new Bullet();
                bullet.blendMode = flash.display.BlendMode.SCREEN;
                bullets.push(bullet);
                addChild(bullet);
                bullet.x = ship.x + ship.width/2 - bullet.width/2 - 10;
                bullet.y = ship.y + ship.height/2 - bullet.height/2 - 10;
                bullet.vel.x = 22;
            }
            var gamepadForce = new Vector3D(gamepad.axes[0], gamepad.axes[1]);
            if (gamepadForce.lengthSquared < 0.5){
                gamepadForce.scaleBy(0);
                ship.vel.scaleBy(0);
            }
            if (gamepad.buttons[1] > 0.5)
                ship.maxSpeed = 16;
            else
                ship.maxSpeed = 8;
            ship.acc.x = gamepadForce.x;
            ship.acc.y = gamepadForce.y;
        }
        ship.update();
        if (ship.x < 0)
            ship.x = 0;
        if (ship.x > flash.Lib.current.stage.stageWidth - ship.width)
            ship.x = flash.Lib.current.stage.stageWidth - ship.width;
        if (ship.y < 0)
            ship.y = 0;
        if (ship.y > flash.Lib.current.stage.stageHeight - ship.height)
            ship.y = flash.Lib.current.stage.stageHeight - ship.height;

        var next = [];
        for (bullet in bullets){
            bullet.update();
            if (bullet.x > flash.Lib.current.stageWidth)
                removeChild(bullet);
            else
                next.push(bullet);
        }
        bullets = next;
    }
}