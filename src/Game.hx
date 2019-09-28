package;

import uk.aidanlee.flurry.api.maths.Maths;
import format.tmx.Data;
import format.tmx.Data.TmxPoint;
import uk.aidanlee.flurry.api.maths.Vector;
import uk.aidanlee.flurry.api.gpu.batcher.Batcher;
import uk.aidanlee.flurry.api.gpu.geometry.Color;
import uk.aidanlee.flurry.api.gpu.geometry.Vertex;
import uk.aidanlee.flurry.api.gpu.geometry.Geometry;
import uk.aidanlee.flurry.api.gpu.textures.SamplerState;
import uk.aidanlee.flurry.api.resources.Resource.TextResource;
import uk.aidanlee.flurry.api.resources.Resource.ShaderResource;
import uk.aidanlee.flurry.api.resources.Resource.ImageResource;
import uk.aidanlee.flurry.FlurryConfig;
import uk.aidanlee.flurry.Flurry;
import format.tmx.Reader;

class Game extends Flurry
{
    var player : Player;

    var batcher : Batcher;

    var map : Array<Geometry>;

    override function onConfig(_config : FlurryConfig) : FlurryConfig
    {
        _config.window.title  = 'Doom';
        _config.window.width  = 768;
        _config.window.height = 512;

        _config.renderer.clearColour.fromRGBA(0.278, 0.176, 0.235, 1.0);

        _config.resources.preload = PrePackaged('preload');

        return _config;
    }

    override function onReady()
    {
        player  = new Player(input, display);
        batcher = renderer.createBatcher({
            shader : resources.get('textured', ShaderResource),
            camera : player.camera,
            depthOptions : {
                depthTesting  : true,
                depthMasking  : true,
                depthFunction : LessThan
            }
        });

        // Create map walls
        var reader = new Reader();
        reader.resolveTSX = _s -> reader.readTSX(Xml.parse(resources.get(_s, TextResource).content));
        var tilemap = reader.read(Xml.parse(resources.get('map', TextResource).content));

        new Geometry({
            batchers : [ batcher ],
            shader   : resources.get('solid', ShaderResource),
            vertices : [
                new Vertex( new Vector(0                 , 0,                   0), new Color(), new Vector(0.0, 0.0)),
                new Vertex( new Vector(tilemap.width * 16, 0,                   0), new Color(), new Vector(1.0, 0.0)),
                new Vertex( new Vector(tilemap.width * 16, 0, tilemap.height * 16), new Color(), new Vector(1.0, 1.0)),
                new Vertex( new Vector(tilemap.width * 16, 0, tilemap.height * 16), new Color(), new Vector(1.0, 1.0)),
                new Vertex( new Vector(0                 , 0, tilemap.height * 16), new Color(), new Vector(0.0, 1.0)),
                new Vertex( new Vector(0                 , 0,                   0), new Color(), new Vector(0.0, 0.0))
            ]
        });

        for (layer in tilemap.layers)
        {
            switch layer
            {
                case LObjectGroup(group):
                    for (object in group.objects)
                    {
                        switch object.objectType
                        {
                            case OTPoint:
                                player.position.x = object.y;
                                player.position.z = object.x;
                            case OTPolyline(points):
                                createWall(object, points, false);
                            case OTPolygon(points):
                                createWall(object, points, true);
                            case _:
                        }
                    }
                case _:
            }
        }
    }

    override function onUpdate(_dt: Float)
    {
        player.update(_dt);

        // for (i in 0...cubes.length)
        // {
        //     cubes[i].face(player.position);
        // }
    }

    function createWall(_object : TmxObject, _points : Array<TmxPoint>, _close : Bool)
    {
        var wall = new Geometry({
            batchers  : [ batcher ],
            textures  : [ resources.get('walls', ImageResource) ],
            samplers  : [ new SamplerState(Wrap, Wrap, Nearest, Nearest) ],
            primitive : TriangleStrip,
            depth     : -1
        });

        for (i in 0..._points.length)
        {
            var u = 0.0;
            if (i > 0)
            {
                u = Maths.sqrt(Maths.pow(_points[i - 1].x - _points[i].x, 2) + Maths.pow(_points[i - 1].y - _points[i].y, 2)) / 16;
            }

            wall.vertices.push(
                new Vertex(
                    new Vector(_points[i].x, 0, _points[i].y),
                    new Color(),
                    new Vector(i % 2 == 0 ? 0 : u, 0)
                )
            );
            wall.vertices.push(
                new Vertex(
                    new Vector(_points[i].x, 16, _points[i].y),
                    new Color(),
                    new Vector(i % 2 == 0 ? 0 : u, 1)
                )
            );
        }

        if (_close)
        {
            var u = Maths.sqrt(Maths.pow(_points[_points.length - 1].x - _points[0].x, 2) + Maths.pow(_points[_points.length - 1].y - _points[0].y, 2)) / 16;

            wall.vertices.push(
                new Vertex(
                    new Vector(_points[0].x, 0, _points[0].y),
                    new Color(),
                    new Vector(_points.length % 2 == 0 ? 0 : u, 0)
                )
            );
            wall.vertices.push(
                new Vertex(
                    new Vector(_points[0].x, 16, _points[0].y),
                    new Color(),
                    new Vector(_points.length % 2 == 0 ? 0 : u, 1)
                )
            );
        }

        wall.position.set_xyz(_object.x, 0, _object.y);
    }
}