package;

import uk.aidanlee.flurry.api.maths.Maths;
import uk.aidanlee.flurry.api.maths.Vector;
import uk.aidanlee.flurry.api.gpu.geometry.Geometry;
import uk.aidanlee.flurry.api.gpu.geometry.Vertex;
import uk.aidanlee.flurry.api.gpu.geometry.Color;

class Billboard extends Geometry
{
    final sorter : Vector;

    public function new(_options : GeometryOptions)
    {
        _options.uploadType = Static;
        _options.vertices   = [
            new Vertex( new Vector(-8,  0,  0), new Color(), new Vector(0.0, 0.0)),
            new Vertex( new Vector( 8,  0,  0), new Color(), new Vector(1.0, 0.0)),
            new Vertex( new Vector( 8, 16,  0), new Color(), new Vector(1.0, 1.0)),
            new Vertex( new Vector( 8, 16,  0), new Color(), new Vector(1.0, 1.0)),
            new Vertex( new Vector(-8, 16,  0), new Color(), new Vector(0.0, 1.0)),
            new Vertex( new Vector(-8,  0,  0), new Color(), new Vector(0.0, 0.0))
        ];

        super(_options);

        sorter = new Vector();
    }

    public function face(_pos : Vector)
    {
        depth = -sorter.copyFrom(_pos).subtract(transformation.position).length;

        var radians = Maths.atan2(position.x - _pos.x, position.z - _pos.z);
        rotation.setFromAxisAngle(new Vector(0, 1, 0), radians);
    }
}
