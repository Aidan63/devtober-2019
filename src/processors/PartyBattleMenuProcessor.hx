package processors;

import slide.easing.Quad;
import uk.aidanlee.flurry.api.input.Keycodes;
import uk.aidanlee.flurry.api.maths.Rectangle;
import uk.aidanlee.flurry.api.resources.Resource.ImageResource;
import uk.aidanlee.flurry.api.resources.ResourceSystem;
import uk.aidanlee.flurry.api.gpu.batcher.Batcher;
import uk.aidanlee.flurry.api.gpu.geometry.shapes.QuadGeometry;
import uk.aidanlee.flurry.api.gpu.geometry.Geometry;
import uk.aidanlee.flurry.api.input.Input;
import clay.Processor;
import slide.Slide;

using tweenxcore.Tools;

class PartyBattleMenuProcessor extends Processor
{
    final input : Input;

    final resources : ResourceSystem;

    var selectedPartyMember : Int;

    var batcher : Batcher;

    var geomArrow : Geometry;

    public function new(_input : Input, _resources : ResourceSystem, _batcher : Batcher)
    {
        super();

        input     = _input;
        resources = _resources;
        batcher   = _batcher;
    }

    override function onadded()
    {
        selectedPartyMember = 0;
        geomArrow = new QuadGeometry({
            batchers: [ batcher ],
            textures: [ resources.get('ui', ImageResource) ],
            uv: new Rectangle(0.25, 0, 0.5, 0.25),
            x : 24 + (selectedPartyMember * 48), y : 78, w : 16, h : 16
        });
        Slide.tween(geomArrow.position)
            .to({ y : 82 }, 0.25).ease(Quad.easeInOut)
            .to({ y : 78 }, 0.25).ease(Quad.easeInOut)
            .wait(0.5)
            .repeat()
            .start();
    }

    override function update(_dt : Float)
    {
        if (input.wasKeyPressed(Keycodes.key_o)) selectedPartyMember--;
        if (input.wasKeyPressed(Keycodes.key_p)) selectedPartyMember++;
        if (selectedPartyMember > 2) selectedPartyMember = 0;
        if (selectedPartyMember < 0) selectedPartyMember = 2;

        geomArrow.position.x = 0.5.lerp(geomArrow.position.x, 24 + (selectedPartyMember * 48));

        Slide.step(_dt);
    }
}