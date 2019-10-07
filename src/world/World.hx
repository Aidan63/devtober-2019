package world;

import format.tmx.Data.TmxMap;
import format.tmx.Data.TmxTileLayer;
import uk.aidanlee.flurry.api.input.Input;
import uk.aidanlee.flurry.api.input.Keycodes;

class World
{
    public final map : TmxMap;

    public final rows : Int;

    public final columns : Int;

    public final grid : Array<Array<Null<Entity>>>;

    public final player : Player;

    public function new(_map : TmxMap)
    {
        map     = _map;
        rows    = _map.height;
        columns = _map.width;
        grid    = [ for (_ in 0...columns) [ for (_ in 0...rows) null ] ];
        player  = new Player(1, 1);

        grid[player.column][player.row] = player;

        for (layer in _map.layers)
        {
            switch layer
            {
                case LTileLayer(layer):
                    switch layer.name
                    {
                        case 'Walls':
                            createWalls(layer);
                        case 'Billboards':
                            createBillboards(layer);
                        case _:
                            //
                    }
                case LObjectGroup(group):
                    //
                case LImageLayer(layer):
                    //
                case LGroup(group):
                    //
            }
        }
    }

    public function update(_input : Input)
    {
        final up          = _input.wasKeyPressed(Keycodes.key_w);
        final down        = _input.wasKeyPressed(Keycodes.key_s);
        final strafeLeft  = _input.wasKeyPressed(Keycodes.key_a);
        final strafeRight = _input.wasKeyPressed(Keycodes.key_d);
        final turnLeft    = _input.wasKeyPressed(Keycodes.left);
        final turnRight   = _input.wasKeyPressed(Keycodes.right);

        if (turnLeft) player.angle++;
        if (turnRight) player.angle--;

        switch player.direction
        {
            case Up:
                if (up) move(player.column, player.row - 1);
                if (down) move(player.column, player.row + 1);
                if (strafeLeft) move(player.column - 1, player.row);
                if (strafeRight) move(player.column + 1, player.row);
                if (turnLeft) player.direction = Left;
                if (turnRight) player.direction = Right;
            case Left:
                if (up) move(player.column - 1, player.row);
                if (down) move(player.column + 1, player.row);
                if (strafeLeft) move(player.column, player.row + 1);
                if (strafeRight) move(player.column, player.row - 1);
                if (turnLeft) player.direction = Down;
                if (turnRight) player.direction = Up;
            case Down:
                if (up) move(player.column, player.row + 1);
                if (down) move(player.column, player.row - 1);
                if (strafeLeft) move(player.column + 1, player.row);
                if (strafeRight) move(player.column - 1, player.row);
                if (turnLeft) player.direction = Right;
                if (turnRight) player.direction = Left;
            case Right:
                if (up) move(player.column + 1, player.row);
                if (down) move(player.column - 1, player.row);
                if (strafeLeft) move(player.column, player.row - 1);
                if (strafeRight) move(player.column, player.row + 1);
                if (turnLeft) player.direction = Up;
                if (turnRight) player.direction = Down;
        }
    }

    function move(_column : Int, _row : Int)
    {
        if (grid[_column][_row] == null)
        {
            grid[player.column][player.row] = null;

            player.column = _column;
            player.row    = _row;

            grid[_column][_row] = player;
        }
    }

    function createWalls(_layer : TmxTileLayer)
    {
        for (x in 0..._layer.height)
        {
            for (y in 0..._layer.width)
            {
                if (_layer.data.tiles[(x * _layer.height) + y].gid != 0)
                {
                    grid[x][y] = new Entity(x, y);
                }
            }
        }
    }

    function createBillboards(_layer : TmxTileLayer)
    {
        for (x in 0..._layer.height)
        {
            for (y in 0..._layer.width)
            {
                if (_layer.data.tiles[(x * _layer.height) + y].gid != 0)
                {
                    grid[x][y] = new Entity(x, y);
                }
            }
        }
    }
}