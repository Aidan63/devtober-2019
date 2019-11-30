package components;

import haxe.ds.ReadOnlyArray;
import uk.aidanlee.flurry.api.maths.Vector3;
import uk.aidanlee.flurry.api.maths.Rectangle;

class MapFloorComponent
{
    public final positions : ReadOnlyArray<Vector3>;

    public final uvs : ReadOnlyArray<Rectangle>;

    public function new(_positions : ReadOnlyArray<Vector3>, _uvs : ReadOnlyArray<Rectangle>)
    {
        positions = _positions;
        uvs       = _uvs;
    }
}