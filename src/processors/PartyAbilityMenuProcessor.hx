package processors;

import components.PartyMemberActionComponent;
import uk.aidanlee.flurry.api.input.Keycodes;
import uk.aidanlee.flurry.api.gpu.geometry.shapes.QuadGeometry;
import uk.aidanlee.flurry.api.gpu.geometry.shapes.TextGeometry;
import uk.aidanlee.flurry.api.resources.Resource.ImageResource;
import geometry.NineSlice;
import uk.aidanlee.flurry.api.gpu.geometry.Geometry;
import clay.Entity;
import clay.Family;
import components.PartyComponent;
import components.PartyMemberSelectionComponent;
import components.PartyMemberAbilityComponent;
import clay.Components;
import uk.aidanlee.flurry.api.gpu.geometry.Color;
import uk.aidanlee.flurry.api.resources.Resource.TextResource;
import uk.aidanlee.flurry.api.importers.bmfont.BitmapFontParser;
import uk.aidanlee.flurry.api.importers.bmfont.BitmapFontData;
import uk.aidanlee.flurry.api.gpu.batcher.Batcher;
import uk.aidanlee.flurry.api.resources.ResourceSystem;
import uk.aidanlee.flurry.api.input.Input;
import uk.aidanlee.flurry.api.maths.Rectangle;
import uk.aidanlee.flurry.api.maths.Vector3;
import clay.Processor;

using tweenxcore.Tools;

class PartyAbilityMenuProcessor extends Processor
{
    final input : Input;

    final resources : ResourceSystem;

    final batcher : Batcher;

    final font : BitmapFontData;

    final colour : Color;

    var familyMemberAbility : Family;

    var componentsParty : Components<PartyComponent>;

    var componentsMemberSelection : Components<PartyMemberSelectionComponent>;

    var componentsMemberAbility : Components<PartyMemberAbilityComponent>;

    var geomAbilityMenu : Geometry;

    var geomAbilityIndicator : Geometry;

    var geomTextAbilityNames : Array<TextGeometry>;

    var geomTextAbilityCosts : Array<TextGeometry>;

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
        familyMemberAbility = families.get('family-ui-member-ability');
        familyMemberAbility.onadded.add(function(_entity : Entity) {
            final party   = componentsParty.get(_entity);
            final texture = resources.get('ui', ImageResource);
            
            geomAbilityMenu = new NineSlice({
                batchers : [ batcher ],
                textures : [ texture ],
                uv : new Rectangle(16, 0, 48, 48),
                left : 16, right : 16, top : 16, bottom : 16,
                x : 8, y : 32, w : 144, h : 64
            });

            geomAbilityIndicator = new QuadGeometry({
                batchers : [ batcher ],
                textures : [ texture ],
                depth    : 1,
                uv       : new Rectangle(64 / texture.width, 32 / texture.height, 72 / texture.width, 40 / texture.height),
                x : 5, y : 8, w : 8, h : 8
            });
            geomAbilityIndicator.transformation.parent = geomAbilityMenu.transformation;

            geomTextAbilityNames = [ for (i in 0...party.members[party.selected].abilities.length) {
                    var t = new TextGeometry({
                        batchers : [ batcher ],
                        textures : [ resources.get('small.png', ImageResource) ],
                        depth    : 1,
                        color    : colour,
                        font     : font,
                        text     : party.members[party.selected].abilities[i].name,
                        position : new Vector3(8, 11 + (i * 12))
                    });
                    t.transformation.parent = geomAbilityMenu.transformation;
                    t;
                }
            ];
            geomTextAbilityCosts = [ for (i in 0...party.members[party.selected].abilities.length) {
                    var t = new TextGeometry({
                        batchers : [ batcher ],
                        textures : [ resources.get('small.png', ImageResource) ],
                        depth    : 1,
                        color    : colour,
                        font     : font,
                        text     : '${party.members[party.selected].abilities[i].cost} mp',
                        position : new Vector3(96, 11 + (i * 12))
                    });
                    t.transformation.parent = geomAbilityMenu.transformation;
                    t;
                }
            ];
        });
        familyMemberAbility.onremoved.add(function(_entity : Entity) {
            geomAbilityMenu.drop();
            geomAbilityIndicator.drop();
            for (g in geomTextAbilityNames) g.drop();
            for (g in geomTextAbilityCosts) g.drop();
            geomTextAbilityNames.resize(0);
            geomTextAbilityCosts.resize(0);
        });

        componentsParty           = components.get_table(PartyComponent);
        componentsMemberSelection = components.get_table(PartyMemberSelectionComponent);
        componentsMemberAbility   = components.get_table(PartyMemberAbilityComponent);
    }

    override function onremoved()
    {
        //
    }

    override function update(_dt : Float)
    {
        for (entity in familyMemberAbility)
        {
            final party   = componentsParty.get(entity);
            final ability = componentsMemberAbility.get(entity);

            if (input.wasKeyPressed(Keycodes.key_w)) ability.index--;
            if (input.wasKeyPressed(Keycodes.key_s)) ability.index++;
            if (ability.index > party.members[party.selected].abilities.length - 1) ability.index = 0;
            if (ability.index < 0) ability.index = party.members[party.selected].abilities.length - 1;

            geomAbilityIndicator.position.y = 0.75.lerp(geomAbilityIndicator.position.y, 10 + (ability.index * 12));

            for (i in 0...party.members[party.selected].abilities.length)
            {
                geomTextAbilityNames[i].position.x = 0.75.lerp(geomTextAbilityNames[i].position.x, ability.index == i ? 8 : 0);
                geomTextAbilityCosts[i].position.x = 0.75.lerp(geomTextAbilityCosts[i].position.x, ability.index == i ? 8 : 0);
            }

            if (input.wasKeyPressed(Keycodes.enter))
            {
                //
            }
            if (input.wasKeyPressed(Keycodes.backspace))
            {
                components.remove(entity, PartyMemberAbilityComponent);
                components.set(entity, new PartyMemberActionComponent());
            }
        }
    }
}