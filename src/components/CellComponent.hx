package components;

class CellComponent
{
    /**
     * The row this entity ocupies.
     */
    public var row : Int;

    /**
     * The column this entity ocupies.
     */
    public var column : Int;

    public function new(_row : Int = 0, _column : Int = 0)
    {
        row    = _row;
        column = _column;
    }
}