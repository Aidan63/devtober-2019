package processors;

import uk.aidanlee.flurry.api.gpu.geometry.shapes.QuadGeometry;
import uk.aidanlee.flurry.api.gpu.geometry.Color;
import uk.aidanlee.flurry.api.resources.Resource.TextResource;
import uk.aidanlee.flurry.api.importers.bmfont.BitmapFontParser;
import uk.aidanlee.flurry.api.importers.bmfont.BitmapFontData;
import uk.aidanlee.flurry.api.gpu.geometry.shapes.TextGeometry;
import components.PartyMemberAbilityComponent;
import uk.aidanlee.flurry.api.input.Keycodes;
import uk.aidanlee.flurry.api.resources.Resource.ImageResource;
import clay.Entity;
import geometry.NineSlice;
import uk.aidanlee.flurry.api.gpu.geometry.Geometry;
import clay.Family;
import components.PartyMemberActionComponent;
import components.PartyMemberSelectionComponent;
import components.PartyComponent;
import clay.Components;
import uk.aidanlee.flurry.api.gpu.batcher.Batcher;
import uk.aidanlee.flurry.api.maths.Rectangle;
import uk.aidanlee.flurry.api.maths.Vector;
import uk.aidanlee.flurry.api.resources.ResourceSystem;
import uk.aidanlee.flurry.api.input.Input;
import clay.Processor;

using tweenxcore.Tools;

class PartyActionMenuProcessor extends Processor
{
    final input : Input;

    final resources : ResourceSystem;

    final batcher : Batcher;

    final font : BitmapFontData;

    final colour : Color;

    var familyMemberAction : Family;

    var componentsParty : Components<PartyComponent>;

    var componentsMemberSelection : Components<PartyMemberSelectionComponent>;

    var componentsMemberAction : Components<PartyMemberActionComponent>;

    var geomActionMenu : Geometry;

    var geomActionIndicator : Geometry;

    var geomActionText : Array<TextGeometry>;

    public function new(_input : Input, _resources : ResourceSystem, _batcher : Batcher)
    {
        super();

        input     = _input;
        resources = _resources;
        batcher   = _batcher;
        font      = BitmapFontParser.parse(resources.get('small.fnt', TextResource).content);
        colour    = new Color(207 / 255, 198 / 255, 184 / 255);
    }

    override function onadded()
    {
        familyMemberAction = families.get('family-ui-member-action');
        familyMemberAction.onadded.add(function(_entity : Entity) {
            final party   = componentsParty.get(_entity);
            final texture = resources.get('ui', ImageResource);

            geomActionMenu = new NineSlice({
                batchers : [ batcher ],
                textures : [ texture ],
                uv : new Rectangle(16, 0, 48, 48),
                left : 16, right : 16, top : 16, bottom : 16,
                x : 8 + (party.selected * 48), y : 48, w : 48, h : 48
            });

            geomActionIndicator = new QuadGeometry({
                batchers : [ batcher ],
                textures : [ texture ],
                depth    : 1,
                uv       : new Rectangle(64 / texture.width, 32 / texture.height, 72 / texture.width, 40 / texture.height),
                x : 5, y : 8, w : 8, h : 8
            });
            geomActionIndicator.transformation.parent = geomActionMenu.transformation;

            geomActionText = [ for (i in 0...party.members[party.selected].actions.length) {
                var t = new TextGeometry({
                    batchers : [ batcher ],
                    textures : [ resources.get('small.png', ImageResource) ],
                    depth    : 1,
                    color    : colour,
                    font     : font,
                    text     : party.members[party.selected].actions[i],
                    position : new Vector(8, 9 + (i * 12))
                });
                t.transformation.parent = geomActionMenu.transformation;
                t;
            } ];
        });
        familyMemberAction.onremoved.add(function(_entity : Entity) {
            geomActionMenu.drop();
            geomActionIndicator.drop();

            for (g in geomActionText)
            {
                g.drop();
            }

            geomActionText.resize(0);
        });

        componentsParty           = components.get_table(PartyComponent);
        componentsMemberSelection = components.get_table(PartyMemberSelectionComponent);
        componentsMemberAction    = components.get_table(PartyMemberActionComponent);
    }

    override function update(_dt : Float)
    {
        for (entity in familyMemberAction)
        {
            final party  = componentsParty.get(entity);
            final action = componentsMemberAction.get(entity);

            if (input.wasKeyPressed(Keycodes.key_w)) action.index--;
            if (input.wasKeyPressed(Keycodes.key_s)) action.index++;
            if (action.index > party.members[party.selected].actions.length - 1) action.index = 0;
            if (action.index < 0) action.index = party.members[party.selected].actions.length - 1;

            geomActionIndicator.position.y = 0.75.lerp(geomActionIndicator.position.y, 8 + (action.index * 12));

            for (i in 0...geomActionText.length)
            {
                geomActionText[i].position.x = 0.75.lerp(geomActionText[i].position.x, action.index == i ? 8 : 0);
            }

            if (input.wasKeyPressed(Keycodes.enter))
            {
                components.remove(entity, PartyMemberActionComponent);
                components.set(entity, new PartyMemberAbilityComponent());
            }
            if (input.wasKeyPressed(Keycodes.backspace))
            {
                components.remove(entity, PartyMemberActionComponent);
                components.set(entity, new PartyMemberSelectionComponent());
            }
        }
    }
}