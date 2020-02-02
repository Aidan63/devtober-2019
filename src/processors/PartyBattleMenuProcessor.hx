package processors;

import uk.aidanlee.flurry.api.gpu.textures.ImageRegion;
import clay.Entity;
import clay.Family;
import clay.Processor;
import clay.Components;
import slide.Slide;
import slide.easing.Quad;
import slide.tweens.TweenObject;
import components.PartyMemberActionComponent;
import components.PartyMemberSelectionComponent;
import components.PartyComponent;
import uk.aidanlee.flurry.api.maths.Vector3;
import uk.aidanlee.flurry.api.maths.Rectangle;
import uk.aidanlee.flurry.api.input.Input;
import uk.aidanlee.flurry.api.input.Keycodes;
import uk.aidanlee.flurry.api.resources.Resource.ImageResource;
import uk.aidanlee.flurry.api.resources.ResourceSystem;
import uk.aidanlee.flurry.api.gpu.batcher.Batcher;
import uk.aidanlee.flurry.api.gpu.geometry.shapes.QuadGeometry;
import uk.aidanlee.flurry.api.gpu.geometry.Geometry;

using tweenxcore.Tools;

class PartyBattleMenuProcessor extends Processor
{
    final input : Input;

    final resources : ResourceSystem;

    final batcher : Batcher;

    var familyMemberSelection : Family;

    var componentsParty : Components<PartyComponent>;

    var componentsMemberSelection : Components<PartyMemberSelectionComponent>;

    var geomArrow : Geometry;

    var geomArrowTween : TweenObject<Vector3>;

    public function new(_input : Input, _resources : ResourceSystem, _batcher : Batcher)
    {
        super();

        input     = _input;
        resources = _resources;
        batcher   = _batcher;
    }

    override function onadded()
    {
        familyMemberSelection = families.get('family-ui-member-selection');
        familyMemberSelection.onadded.add(function(_entity : Entity) {
            final party   = componentsParty.get(_entity);
            final texture = resources.get('ui', ImageResource);

            geomArrow = new QuadGeometry({
                batchers: [ batcher ],
                textures: Textures([ texture ]),
                region: new ImageRegion(texture, 0, 32, 16, 16),
                x : 24 + (party.selected * 48), y : 78, w : 16, h : 16
            });
            geomArrowTween = Slide.tween(geomArrow.position)
                .to({ y : 82 }, 0.25).ease(Quad.easeInOut)
                .to({ y : 78 }, 0.25).ease(Quad.easeInOut)
                .wait(0.5)
                .repeat()
                .start();
        });
        familyMemberSelection.onremoved.add(function(_entity : Entity) {
            geomArrowTween.stop();
            batcher.removeGeometry(geomArrow);
        });

        componentsParty           = components.get_table(PartyComponent);
        componentsMemberSelection = components.get_table(PartyMemberSelectionComponent);
    }

    override function update(_dt : Float)
    {
        for (entity in familyMemberSelection)
        {
            final party = componentsParty.get(entity);

            if (input.wasKeyPressed(Keycodes.key_a)) party.selected--;
            if (input.wasKeyPressed(Keycodes.key_d)) party.selected++;
            if (party.selected > party.members.length - 1) party.selected = 0;
            if (party.selected < 0) party.selected = party.members.length - 1;

            if (input.wasKeyPressed(Keycodes.enter) && !party.members[party.selected].turnTaken)
            {
                components.remove(entity, PartyMemberSelectionComponent);
                components.set(entity, new PartyMemberActionComponent());
            }

            // geomArrow.color.a = 1;
            geomArrow.position.x = 0.5.lerp(geomArrow.position.x, 24 + (party.selected * 48));
        }
    }
}