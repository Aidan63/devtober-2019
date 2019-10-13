package processors;

import uk.aidanlee.flurry.api.maths.Vector;
import slide.tweens.TweenObject;
import clay.Entity;
import components.PartyMemberAbilityComponent;
import components.PartyMemberActionComponent;
import components.PartyMemberSelectionComponent;
import components.PartyComponent;
import clay.Components;
import clay.Family;
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

    final batcher : Batcher;

    var familyMemberSelection : Family;

    var familyMemberAction : Family;

    var familyMemberAbility : Family;

    var componentsParty : Components<PartyComponent>;

    var componentsMemberSelection : Components<PartyMemberSelectionComponent>;

    var componentsMemberAction : Components<PartyMemberActionComponent>;

    var componentsMemberAbility : Components<PartyMemberAbilityComponent>;

    var geomArrow : Geometry;

    var geomArrowTween : TweenObject<Vector>;

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
            final party = componentsParty.get(_entity);

            // Assuming the selected party member defaults to 0.
            geomArrow = new QuadGeometry({
                batchers: [ batcher ],
                textures: [ resources.get('ui', ImageResource) ],
                uv: new Rectangle(0, 0.5, 0.25, 0.75),
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
            geomArrow.drop();
            geomArrowTween.stop();
        });

        familyMemberAction = families.get('family-ui-member-action');
        familyMemberAction.onadded.add(function(_entity : Entity) {
            trace('entering action menu');
        });
        familyMemberAction.onremoved.add(function(_entity : Entity) {
            trace('exiting action menu');
        });

        familyMemberAbility = families.get('family-ui-member-ability');
        familyMemberAbility.onadded.add(function(_entity : Entity) {
            //
        });
        familyMemberAbility.onremoved.add(function(_entity : Entity) {
            //
        });

        componentsParty           = components.get_table(PartyComponent);
        componentsMemberSelection = components.get_table(PartyMemberSelectionComponent);
        componentsMemberAction    = components.get_table(PartyMemberActionComponent);
        componentsMemberAbility   = components.get_table(PartyMemberAbilityComponent);
    }

    override function update(_dt : Float)
    {
        Slide.step(_dt);

        for (entity in familyMemberSelection)
        {
            final party = componentsParty.get(entity);

            if (input.wasKeyPressed(Keycodes.key_o)) party.selected--;
            if (input.wasKeyPressed(Keycodes.key_p)) party.selected++;
            if (party.selected > party.members.length - 1) party.selected = 0;
            if (party.selected < 0) party.selected = party.members.length - 1;

            if (input.wasKeyPressed(Keycodes.enter))
            {
                components.remove(entity, PartyMemberSelectionComponent);
                components.set(entity, new PartyMemberActionComponent());
            }

            geomArrow.color.a = 1;
            geomArrow.position.x = 0.5.lerp(geomArrow.position.x, 24 + (party.selected * 48));
        }

        for (entity in familyMemberAction)
        {
            final party = componentsParty.get(entity);

            if (input.wasKeyPressed(Keycodes.backspace))
            {
                components.remove(entity, PartyMemberActionComponent);
                components.set(entity, new PartyMemberSelectionComponent());
            }
        }
    }
}