package components;

import haxe.ds.ReadOnlyArray;
import uk.aidanlee.flurry.api.maths.Vector;
import uk.aidanlee.flurry.api.maths.Rectangle;

class MapFloorComponent
{
    public final positions : ReadOnlyArray<Vector>;

    public final uvs : ReadOnlyArray<Rectangle>;

    public function new(_positions : ReadOnlyArray<Vector>, _uvs : ReadOnlyArray<Rectangle>)
    {
        positions = _positions;
        uvs       = _uvs;
    }
}