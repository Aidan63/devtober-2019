package processors;

import components.MapFloorComponent;
import components.DirectionComponent;
import components.PositionComponent;
import components.UVComponent;
import components.CellComponent;
import clay.Components;
import clay.Entity;
import clay.Family;
import clay.Processor;
import uk.aidanlee.flurry.api.gpu.Renderer;
import uk.aidanlee.flurry.api.gpu.camera.Camera3D;
import uk.aidanlee.flurry.api.gpu.batcher.Batcher;
import uk.aidanlee.flurry.api.gpu.geometry.Geometry;
import uk.aidanlee.flurry.api.gpu.geometry.Vertex;
import uk.aidanlee.flurry.api.gpu.geometry.Color;
import uk.aidanlee.flurry.api.maths.Maths;
import uk.aidanlee.flurry.api.maths.Vector;
import uk.aidanlee.flurry.api.maths.Rectangle;
import uk.aidanlee.flurry.api.resources.ResourceSystem;
import uk.aidanlee.flurry.api.resources.Resource.ShaderResource;
import uk.aidanlee.flurry.api.resources.Resource.ImageResource;

class WorldRendererProcessor extends Processor
{
    final up = new Vector(0, 1, 0);

    final sorter = new Vector();

    final renderer : Renderer;

    final resources : ResourceSystem;

    final batcher : Batcher;

    final camera : Camera3D;

    var wallGeometry : Array<Geometry>;

    var billboardGeometry : Array<Null<Geometry>>;

    var floorGeometry : Array<Geometry>;

    var familyWalls : Family;

    var familyBillboards : Family;

    var familyFloor : Family;

    var familyMovement : Family;

    var componentCells : Components<CellComponent>;

    var componentUVs : Components<UVComponent>;

    var componentsPositions : Components<PositionComponent>;

    var componentsDirection : Components<DirectionComponent>;

    var componentsMapFloor : Components<MapFloorComponent>;

    public function new(_renderer : Renderer, _resources : ResourceSystem)
    {
        super();

        renderer  = _renderer;
        resources = _resources;
        camera    = new Camera3D(45, 1.3333, 0.1, 1000);
        batcher   = _renderer.createBatcher({
            camera : camera,
            shader : _resources.get('textured', ShaderResource),
            depthOptions : {
                depthTesting  : true,
                depthMasking  : true,
                depthFunction : LessThan
            }
        });
    }

    override function onadded()
    {
        wallGeometry      = [];
        billboardGeometry = [ for (_ in 0...entities.capacity) null ];
        floorGeometry     = [];

        familyWalls      = families.get('family-walls');
        familyBillboards = families.get('family-billboards');
        familyMovement   = families.get('family-smooth-movement');
        familyFloor      = families.get('family-map-floor');

        componentCells      = components.get_table(CellComponent);
        componentUVs        = components.get_table(UVComponent);
        componentsPositions = components.get_table(PositionComponent);
        componentsDirection = components.get_table(DirectionComponent);
        componentsMapFloor  = components.get_table(MapFloorComponent);

        familyWalls.onadded.add(createWall);
        familyFloor.onadded.add(createFloor);

        familyBillboards.onadded.add(createBillboard);
        familyBillboards.onremoved.add(removeBillboard);
    }

    override function update(_dt : Float)
    {
        for (entity in familyMovement)
        {
            final position  = componentsPositions.get(entity);
            final direction = componentsDirection.get(entity);

            camera.transformation.rotation.setFromAxisAngle(up, Maths.toRadians(clampAngle(direction.angle)));
            camera.transformation.position.x = position.x;
            camera.transformation.position.y = position.y;
            camera.transformation.position.z = position.z;
            camera.update(_dt);
        }
        
        for (i in 0...billboardGeometry.length)
        {
            if (billboardGeometry[i] == null)
            {
                continue;
            }

            final geom = billboardGeometry[i];

            geom.depth = -sorter.copyFrom(camera.transformation.position).subtract(geom.transformation.position).length;
            geom.transformation.rotation.setFromAxisAngle(
                up,
                Maths.atan2(
                    geom.position.x - camera.transformation.position.x,
                    geom.position.z - camera.transformation.position.z));
        }
    }

    function createWall(_entity : Entity)
    {
        final cell = componentCells.get(_entity);
        final uvs  = componentUVs.get(_entity);
        final tex  = resources.get('tiles', ImageResource);

        wallGeometry.push(CubeConstructor.create(
            batcher,
            tex,
            new Rectangle(
                uvs.u1 / tex.width,
                uvs.v1 / tex.height,
                uvs.u2 / tex.width,
                uvs.v2 / tex.height),
            cell.column * 16,
            cell.row * 16,
            16,
            16));
    }
    
    function createBillboard(_entity : Entity)
    {
        final cell   = componentCells.get(_entity);
        final uvs    = componentUVs.get(_entity);
        final tex    = resources.get('tiles', ImageResource);
        final colour = new Color();

        final u1 = uvs.u1 / tex.width;
        final v1 = uvs.v1 / tex.height;
        final u2 = (uvs.u1 + uvs.u2) / tex.width;
        final v2 = (uvs.v1 + uvs.v2) / tex.height;

        final geom = new Geometry({
            batchers : [ batcher ],
            textures : [ tex ],
            vertices : [
                new Vertex( new Vector(-8,  0,  0), colour, new Vector(u1, v1) ),
                new Vertex( new Vector( 8,  0,  0), colour, new Vector(u2, v1) ),
                new Vertex( new Vector( 8, 16,  0), colour, new Vector(u2, v2) ),
                new Vertex( new Vector(-8, 16,  0), colour, new Vector(u1, v2) )
            ],
            indices : [ 0, 1, 2, 2, 3, 0 ]
        });
        geom.position.set_xyz(
            8 + cell.column * 16,
            0,
            8 + cell.row * 16);

        billboardGeometry[_entity.id] = geom;
    }

    function removeBillboard(_entity : Entity)
    {
        billboardGeometry[_entity.id].drop();
        billboardGeometry[_entity.id] = null;
    }

    function createFloor(_entity : Entity)
    {
        final texture = resources.get('tiles', ImageResource);
        final map     = componentsMapFloor.get(_entity);
        final colour  = new Color();

        for (i in 0...map.positions.length)
        {
            final pos = map.positions[i];
            final uvs = map.uvs[i];

            final x1 = pos.x;
            final y1 = pos.y;
            final x2 = x1 + 16;
            final y2 = y1 + 16;

            final u1 = uvs.x / texture.width;
            final v1 = uvs.y / texture.height;
            final u2 = (uvs.x + uvs.w) / texture.width;
            final v2 = (uvs.y + uvs.h) / texture.height;

            floorGeometry.push(new Geometry({
                batchers : [ batcher ],
                textures : [ texture ],
                vertices : [
                    new Vertex( new Vector(x1, 0, y1), colour, new Vector(u1, v1)),
                    new Vertex( new Vector(x2, 0, y1), colour, new Vector(u2, v1)),
                    new Vertex( new Vector(x2, 0, y2), colour, new Vector(u2, v2)),
                    new Vertex( new Vector(x1, 0, y2), colour, new Vector(u1, v2))
                ],
                indices : [ 0, 1, 2, 2, 3, 0 ]
            }));
        }
    }

    function clampAngle(_angle : Float) : Float
    {
        while (_angle >= 360)
        {
            _angle -= 360;
        }

        while (_angle < 0)
        {
            _angle += 360;
        }

        return _angle;
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