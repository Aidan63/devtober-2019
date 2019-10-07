import format.tmx.Data.TmxTileLayer;
import uk.aidanlee.flurry.api.maths.Maths;
import uk.aidanlee.flurry.api.maths.Vector;
import uk.aidanlee.flurry.api.maths.Rectangle;
import uk.aidanlee.flurry.api.resources.Resource.ImageResource;
import uk.aidanlee.flurry.api.resources.Resource.ShaderResource;
import uk.aidanlee.flurry.api.resources.ResourceSystem;
import uk.aidanlee.flurry.api.gpu.camera.Camera3D;
import uk.aidanlee.flurry.api.gpu.batcher.Batcher;
import uk.aidanlee.flurry.api.gpu.geometry.Color;
import uk.aidanlee.flurry.api.gpu.geometry.Vertex;
import uk.aidanlee.flurry.api.gpu.geometry.Geometry;
import uk.aidanlee.flurry.api.gpu.Renderer;
import world.World;

using tweenxcore.Tools;

class WorldDrawer
{
    /**
     * Constant normalised vector pointing to the worlds up position.
     */
    final up = new Vector(0, 1, 0);

    final renderer : Renderer;

    final resources : ResourceSystem;

    final batcher : Batcher;

    final camera : Camera3D;

    final world : World;

    final walls : Array<Geometry>;

    final tiles : Array<Geometry>;

    final billboards : Array<Billboard>;

    var playerAngle : Float;

    public function new(_renderer : Renderer, _resources : ResourceSystem, _world : World)
    {
        renderer   = _renderer;
        resources  = _resources;
        world      = _world;
        camera     = new Camera3D(45, 1, 0.1, 1000);
        batcher    = renderer.createBatcher({
            camera       : camera,
            shader       : resources.get('textured', ShaderResource),
            depthOptions : {
                depthTesting  : true,
                depthMasking  : true,
                depthFunction : LessThan
            }
        });

        for (layer in world.map.layers)
        {
            switch layer
            {
                case LTileLayer(layer):
                    switch layer.name
                    {
                        case 'Floor':
                            tiles = createTiles(layer);
                        case 'Walls':
                            walls = createWalls(layer);
                        case 'Billboards':
                            billboards = createBillboards(layer);
                        case _:
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

    public function update(_dt : Float, _aspect : Float)
    {
        playerAngle   = 0.5.linear().lerp(playerAngle, world.player.angle * 90);
        camera.aspect = _aspect;
        camera.transformation.rotation.setFromAxisAngle(up, Maths.toRadians(clampAngle(playerAngle)));
        camera.transformation.position.x = 0.5.linear().lerp(camera.transformation.position.x, 8 + world.player.column * 16);
        camera.transformation.position.y = 8;
        camera.transformation.position.z = 0.5.linear().lerp(camera.transformation.position.z, 8 + world.player.row * 16);
        camera.update(_dt);

        for (i in 0...billboards.length)
        {
            billboards[i].face(camera.transformation.position);
        }
    }

    /**
     * Create a new cube geometry for each wall in the provided layer.
     * @param _layer Tiled map layer to draw.
     * @return Array of created geometry.
     */
    function createWalls(_layer : TmxTileLayer) : Array<Geometry>
    {
        final tex = resources.get('tiles', ImageResource);
        final arr = [];
        
        for (y in 0..._layer.width)
        {
            for (x in 0..._layer.height)
            {
                final gid = _layer.data.tiles[(x * _layer.height) + y].gid;

                if (gid != 0)
                {
                    final row = Std.int(gid / world.map.tilesets[0].columns);
                    final col = (gid % world.map.tilesets[0].columns) - 1;
                    final uvs = new Rectangle(
                        (col * world.map.tilesets[0].tileWidth) / tex.width,
                        (row * world.map.tilesets[0].tileHeight) / tex.height,
                        world.map.tilesets[0].tileWidth / tex.width,
                        world.map.tilesets[0].tileHeight / tex.height);

                    arr.push(CubeConstructor.create(
                        batcher,
                        tex,
                        uvs,
                        x * world.map.tileWidth,
                        y * world.map.tileHeight,
                        world.map.tileWidth,
                        world.map.tileHeight));
                }
            }
        }

        return arr;
    }

    /**
     * //
     * @param _layer 
     * @return Array<Geometry>
     */
    function createTiles(_layer : TmxTileLayer) : Array<Geometry>
    {
        final tex = resources.get('tiles', ImageResource);
        final arr = [];

        for (y in 0..._layer.width)
        {
            for (x in 0..._layer.height)
            {
                final gid = _layer.data.tiles[(x * _layer.height) + y].gid;

                if (gid != 0)
                {
                    final colour = new Color();

                    final row = Std.int(gid / world.map.tilesets[0].columns);
                    final col = (gid % world.map.tilesets[0].columns) - 1;

                    final u1 = (col * world.map.tilesets[0].tileWidth) / tex.width;
                    final v1 = (row * world.map.tilesets[0].tileHeight) / tex.height;
                    final u2 = u1 + (world.map.tilesets[0].tileWidth / tex.width);
                    final v2 = v1 + (world.map.tilesets[0].tileHeight / tex.height);

                    final x1 = (x * world.map.tileWidth);
                    final y1 = (y * world.map.tileHeight);
                    final x2 = x1 + world.map.tileWidth;
                    final y2 = y1 + world.map.tileHeight;

                    arr.push(new Geometry({
                        batchers: [ batcher ],
                        textures: [ tex ],
                        vertices: [
                            new Vertex( new Vector(x1, 0, y1), colour, new Vector(u1, v1)),
                            new Vertex( new Vector(x2, 0, y1), colour, new Vector(u2, v1)),
                            new Vertex( new Vector(x2, 0, y2), colour, new Vector(u2, v2)),
                            new Vertex( new Vector(x2, 0, y2), colour, new Vector(u2, v2)),
                            new Vertex( new Vector(x1, 0, y2), colour, new Vector(u1, v2)),
                            new Vertex( new Vector(x1, 0, y1), colour, new Vector(u1, v1))
                        ]
                    }));
                }
            }
        }

        return arr;
    }

    function createBillboards(_layer : TmxTileLayer) : Array<Billboard>
    {
        final tex = resources.get('tiles', ImageResource);
        final arr = [];

        for (y in 0..._layer.width)
        {
            for (x in 0..._layer.height)
            {
                final gid = _layer.data.tiles[(x * _layer.height) + y].gid;

                if (gid != 0)
                {
                    final row = Std.int(gid / world.map.tilesets[0].columns);
                    final col = (gid % world.map.tilesets[0].columns) - 1;
                    final uvs = new Rectangle(
                        (col * world.map.tilesets[0].tileWidth) / tex.width,
                        (row * world.map.tilesets[0].tileHeight) / tex.height,
                        world.map.tilesets[0].tileWidth / tex.width,
                        world.map.tilesets[0].tileHeight / tex.height);

                    final board = new Billboard(batcher, tex, uvs);
                    board.position.set_xyz(8 + x * world.map.tileWidth, 0, 8 + y * world.map.tileHeight);

                    arr.push(board);
                }
            }
        }

        return arr;
    }

    function clampAngle(_v : Float) : Float
    {
        while (_v >= 360)
        {
            _v -= 360;
        }
        while (_v < 0)
        {
            _v += 360;
        }

        return _v;
    }
}

private class CubeConstructor
{
    private static final colour = new Color();

    private static final vertices = [
        new Vector( 0,  0,  0),
        new Vector( 0,  0, 16),
        new Vector( 0, 16, 16),

        new Vector(16, 16,  0),
        new Vector( 0,  0,  0),
        new Vector( 0, 16,  0),

        new Vector(16, 16,  0),
        new Vector(16,  0,  0),
        new Vector( 0,  0,  0),

        new Vector( 0,  0,  0),
        new Vector( 0, 16, 16),
        new Vector( 0, 16,  0),

        new Vector( 0, 16, 16),
        new Vector( 0,  0, 16),
        new Vector(16,  0, 16),

        new Vector(16, 16, 16),
        new Vector(16,  0,  0),
        new Vector(16, 16,  0),

        new Vector(16,  0,  0),
        new Vector(16, 16, 16),
        new Vector(16,  0, 16),

        new Vector(16, 16, 16),
        new Vector( 0, 16, 16),
        new Vector(16,  0, 16)
    ];

    public static final texCoords = [
        new Vector(0, 0),
        new Vector(1, 0),
        new Vector(1, 1),

        new Vector(0, 1),
        new Vector(1, 0),
        new Vector(1, 1),

        new Vector(0, 1),
        new Vector(0, 0),
        new Vector(1, 0),

        new Vector(0, 0),
        new Vector(1, 1),
        new Vector(0, 1),

        new Vector(0, 1),
        new Vector(0, 0),
        new Vector(1, 0),

        new Vector(0, 1),
        new Vector(1, 0),
        new Vector(1, 1),

        new Vector(1, 0),
        new Vector(0, 1),
        new Vector(0, 0),

        new Vector(1, 1),
        new Vector(0, 1),
        new Vector(1, 0)
    ];

    public static function create(_batcher : Batcher, _texture : ImageResource, _uv : Rectangle, _px : Float, _py : Float, _tx : Float, _ty : Float) : Geometry
    {
        final g = new Geometry({
            batchers : [ _batcher ],
            textures : [ _texture ],
            vertices : [
                for (i in 0...vertices.length) new Vertex(
                    vertices[i],
                    colour,
                    uv(texCoords[i].clone(), _uv)
                )
            ]
        });
        g.position.set_xyz(_px, 0, _py);

        return g;
    }

    private static function uv(_vector : Vector, _uv : Rectangle) : Vector
    {
        _vector.x = (_vector.x == 0) ? _uv.x : _uv.x + _uv.w;
        _vector.y = (_vector.y == 0) ? _uv.y : _uv.y + _uv.h;

        return _vector;
    }
}