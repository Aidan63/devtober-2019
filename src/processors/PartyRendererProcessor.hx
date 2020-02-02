package processors;

import uk.aidanlee.flurry.api.gpu.textures.ImageRegion;
import uk.aidanlee.flurry.api.maths.Maths;
import clay.Entity;
import components.PartyComponent;
import clay.Components;
import clay.Family;
import uk.aidanlee.flurry.api.gpu.geometry.Geometry;
import uk.aidanlee.flurry.api.resources.Resource.ImageResource;
import uk.aidanlee.flurry.api.gpu.geometry.shapes.QuadGeometry;
import uk.aidanlee.flurry.api.resources.ResourceSystem;
import uk.aidanlee.flurry.api.gpu.batcher.Batcher;
import uk.aidanlee.flurry.api.maths.Rectangle;
import clay.Processor;

class PartyRendererProcessor extends Processor
{
    final batcher : Batcher;

    final texture : ImageResource;

    final faces : Array<Geometry>;

    final frames : Array<Geometry>;

    final healthBars : Array<QuadGeometry>;

    final specialBars : Array<QuadGeometry>;

    var familyParty : Family;

    var componentsParty : Components<PartyComponent>;

    public function new(_resources : ResourceSystem, _batcher : Batcher)
    {
        super();

        texture = _resources.get('ui', ImageResource);
        batcher = _batcher;

        faces       = [];
        frames      = [];
        healthBars  = [];
        specialBars = [];
    }

    override function onadded()
    {
        familyParty = families.get('family-ui-party');
        familyParty.onadded.add(partyAdded);
        familyParty.onremoved.add(partyRemoved);

        componentsParty = components.get_table(PartyComponent);
    }

    override function update(_dt : Float)
    {
        for (entity in familyParty)
        {
            final party = componentsParty.get(entity);

            for (i in 0...party.members.length)
            {
                final alpha = party.members[i].turnTaken ? 0.75 : 1.0;
                // faces[i].color.a = alpha;
                // frames[i].color.a = alpha;
                // healthBars[i].color.a = alpha;
                // specialBars[i].color.a = alpha;

                final healthBarWidth  = Maths.ceil((party.members[i].health / party.members[i].maxHealth) * 10);
                final specialBarWidth = Maths.ceil((party.members[i].special / party.members[i].maxSpecial) * 10);

                healthBars[i].resize_xy(healthBarWidth, 4);
                specialBars[i].resize_xy(specialBarWidth, 1);
            }
        }
    }

    function partyAdded(_entity : Entity)
    {
        final party = componentsParty.get(_entity);

        for (i in 0...party.members.length)
        {
            faces.push(new QuadGeometry({
                batchers : [ batcher ],
                textures : Textures([ texture ]),
                region : new ImageRegion(texture, (i * 16), 48, 16, 16),
                x : 16 + (i * 48), y : 96, w : 16, h : 16
            }));

            frames.push(new QuadGeometry({
                batchers: [ batcher ],
                textures: Textures([ texture ]),
                region: new ImageRegion(texture, 0, 0, 16, 16),
                x : 32 + (i * 48), y : 96, w : 16, h : 16
            }));

            healthBars.push(new QuadGeometry({
                batchers : [ batcher ],
                textures : Textures([ texture ]),
                region: new ImageRegion(texture, 3, 19, 10, 4),
                x : 35 + (i * 48), y : 99, w : 10, h : 4
            }));

            specialBars.push(new QuadGeometry({
                batchers : [ batcher ],
                textures : Textures([ texture ]),
                region: new ImageRegion(texture, 3, 28, 10, 1),
                x : 35 + (i * 48), y : 108, w : 10, h : 1
            }));
        }
    }

    function partyRemoved(_entity : Entity)
    {
        faces.resize(0);
        frames.resize(0);
        healthBars.resize(0);
        specialBars.resize(0);
    }
}