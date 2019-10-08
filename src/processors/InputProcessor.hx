package processors;

import clay.Components;
import clay.Family;
import clay.Processor;
import uk.aidanlee.flurry.api.input.Input;
import uk.aidanlee.flurry.api.input.Keycodes;
import components.InputComponent;

class InputProcessor extends Processor
{
    final input : Input;

    var family : Family;

    var inputComponents : Components<InputComponent>;

    public function new(_input : Input)
    {
        super();

        input = _input;
    }

    override function onadded()
    {
        family          = families.get('family-input');
        inputComponents = components.get_table(InputComponent);
    }

    override function update(_dt : Float)
    {
        for (entity in family)
        {
            final i = inputComponents.get(entity);
            i.up          = input.wasKeyPressed(Keycodes.key_w);
            i.down        = input.wasKeyPressed(Keycodes.key_s);
            i.strafeLeft  = input.wasKeyPressed(Keycodes.key_a);
            i.strafeRight = input.wasKeyPressed(Keycodes.key_d);
            i.turnLeft    = input.wasKeyPressed(Keycodes.left);
            i.turnRight   = input.wasKeyPressed(Keycodes.right);
        }
    }
}