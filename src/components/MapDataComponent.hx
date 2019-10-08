package components;

import clay.Entity;

class MapDataComponent
{
    public final data : Array<Array<Int>>;

    public function new(_columns : Int, _rows : Int)
    {
        data = [ for (_ in 0..._columns) [ for (_ in 0..._rows) Entity.ID_NULL ] ];
    }
}