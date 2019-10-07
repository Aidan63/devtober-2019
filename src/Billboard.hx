package;

import uk.aidanlee.flurry.api.gpu.batcher.Batcher;
import uk.aidanlee.flurry.api.maths.Rectangle;
import uk.aidanlee.flurry.api.resources.Resource.ImageResource;
import uk.aidanlee.flurry.api.maths.Maths;
import uk.aidanlee.flurry.api.maths.Vector;
import uk.aidanlee.flurry.api.gpu.geometry.Geometry;
import uk.aidanlee.flurry.api.gpu.geometry.Vertex;
import uk.aidanlee.flurry.api.gpu.geometry.Color;

class Billboard extends Geometry
{
    final sorter : Vector;

    public function new(_batcher : Batcher, _texture : ImageResource, _uv : Rectangle)
    {
        var u1 = _uv.x;
        var v1 = _uv.y;
        var u2 = _uv.x + _uv.w;
        var v2 = _uv.y + _uv.h;

        super({
            batchers: [ _batcher ],
            textures: [ _texture ],
            vertices: [
                new Vertex( new Vector(-8,  0,  0), new Color(), new Vector(u1, v1) ),
                new Vertex( new Vector( 8,  0,  0), new Color(), new Vector(u2, v1) ),
                new Vertex( new Vector( 8, 16,  0), new Color(), new Vector(u2, v2) ),
                new Vertex( new Vector( 8, 16,  0), new Color(), new Vector(u2, v2) ),
                new Vertex( new Vector(-8, 16,  0), new Color(), new Vector(u1, v2) ),
                new Vertex( new Vector(-8,  0,  0), new Color(), new Vector(u1, v1) )
            ]
        });

        sorter = new Vector();
    }

    public function face(_pos : Vector)
    {
        depth = -sorter.copyFrom(_pos).subtract(transformation.position).length;

        var radians = Maths.atan2(position.x - _pos.x, position.z - _pos.z);
        rotation.setFromAxisAngle(new Vector(0, 1, 0), radians);
    }
}
