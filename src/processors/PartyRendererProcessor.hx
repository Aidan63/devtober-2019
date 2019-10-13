package processors;

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

    var familyParty : Family;

    var componentsParty : Components<PartyComponent>;

    public function new(_resources : ResourceSystem, _batcher : Batcher)
    {
        super();

        texture = _resources.get('ui', ImageResource);
        batcher = _batcher;

        faces  = [];
        frames = [];
    }

    override function onadded()
    {
        familyParty = families.get('family-party');
        familyParty.onadded.add(partyAdded);
        familyParty.onremoved.add(partyRemoved);

        componentsParty = components.get_table(PartyComponent);
    }

    function partyAdded(_entity : Entity)
    {
        final party = componentsParty.get(_entity);

        for (i in 0...party.members.length)
        {
            faces.push(new QuadGeometry({
                batchers : [ batcher ],
                textures : [ texture ],
                uv : new Rectangle(
                    (i * 16) / texture.width,
                    48 / texture.height,
                    ((i * 16) + 16) / texture.width,
                    64 / texture.height),
                x : 16 + (i * 48), y : 96, w : 16, h : 16
            }));

            frames.push(new QuadGeometry({
                batchers: [ batcher ],
                textures: [ texture ],
                uv: new Rectangle(0, 0, 16 / texture.width, 16 / texture.height),
                x : 32 + (i * 48), y : 96, w : 16, h : 16
            }));
        }
    }

    function partyRemoved(_entity : Entity)
    {
        for (face in faces)
        {
            face.drop();
        }
        faces.resize(0);

        for (frame in frames)
        {
            frame.drop();
        }
        frames.resize(0);
    }
}