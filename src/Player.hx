import uk.aidanlee.flurry.api.maths.Maths;
import uk.aidanlee.flurry.api.maths.Vector;
import uk.aidanlee.flurry.api.input.Keycodes;
import uk.aidanlee.flurry.api.input.Input;
import uk.aidanlee.flurry.api.display.Display;
import uk.aidanlee.flurry.api.gpu.camera.Camera3D;

class Player
{
    public var camera (default, null) : Camera3D;

    public var position (get, null) : Vector;

    inline function get_position() : Vector return camera.transformation.position;

    public var direction : Float;

    final input : Input;

    final display : Display;

    public function new(_input : Input, _display : Display)
    {
        input     = _input;
        display   = _display;
        direction = 0;

        camera = new Camera3D(45, display.width / display.height, 0.1, 1600);
        position.y = 8;
    }

    public function update(_dt : Float)
    {
        if (input.isKeyDown(Keycodes.key_w))
        {
            camera.transformation.position.x -= Maths.lengthdir_y(30 * _dt, direction);
            camera.transformation.position.z -= Maths.lengthdir_x(30 * _dt, direction);
        }
        if (input.isKeyDown(Keycodes.key_s))
        {
            camera.transformation.position.x += Maths.lengthdir_y(30 * _dt, direction);
            camera.transformation.position.z += Maths.lengthdir_x(30 * _dt, direction);
        }
        if (input.isKeyDown(Keycodes.key_a))
        {
            camera.transformation.position.x += Maths.lengthdir_y(30 * _dt, direction - 90);
            camera.transformation.position.z += Maths.lengthdir_x(30 * _dt, direction - 90);
        }
        if (input.isKeyDown(Keycodes.key_d))
        {
            camera.transformation.position.x += Maths.lengthdir_y(30 * _dt, direction + 90);
            camera.transformation.position.z += Maths.lengthdir_x(30 * _dt, direction + 90);
        }

        if (input.isKeyDown(Keycodes.left )) direction += 64 * _dt;
        if (input.isKeyDown(Keycodes.right)) direction -= 64 * _dt;
        if (direction > 360) direction = 0;
        if (direction <   0) direction = 360;

        camera.transformation.rotation.setFromAxisAngle(new Vector(0, 1, 0), Maths.toRadians(direction));
        camera.aspect = display.width / display.height;
    }
}
