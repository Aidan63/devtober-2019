package processors;

import uk.aidanlee.flurry.api.gpu.geometry.Geometry;
import uk.aidanlee.flurry.api.resources.Resource.ImageResource;
import uk.aidanlee.flurry.api.gpu.geometry.shapes.QuadGeometry;
import uk.aidanlee.flurry.api.resources.ResourceSystem;
import uk.aidanlee.flurry.api.resources.Resource.ShaderResource;
import uk.aidanlee.flurry.api.gpu.Renderer;
import uk.aidanlee.flurry.api.gpu.camera.Camera2D;
import uk.aidanlee.flurry.api.gpu.batcher.Batcher;
import uk.aidanlee.flurry.api.maths.Rectangle;
import clay.Processor;

class PartyRendererProcessor extends Processor
{
    final batcher : Batcher;

    final camera : Camera2D;

    final texture : ImageResource;

    final faces : Array<Geometry>;

    final frames : Array<Geometry>;

    public function new(_renderer : Renderer, _resources : ResourceSystem)
    {
        super();

        camera = new Camera2D(160, 120);
        camera.viewport.set(0, 0, 320, 240);
        camera.sizeMode = Fit;

        texture = _resources.get('ui', ImageResource);
        batcher = _renderer.createBatcher({
            camera : camera,
            shader : _resources.get('textured', ShaderResource)
        });

        faces = [
            new QuadGeometry({
                batchers : [ batcher ],
                textures : [ texture ],
                uv : new Rectangle(
                    0 / texture.width,
                    48 / texture.height,
                    16 / texture.width,
                    64 / texture.height),
                x : 16, y : 96, w : 16, h : 16
            }),
            new QuadGeometry({
                batchers : [ batcher ],
                textures : [ texture ],
                uv : new Rectangle(
                    16 / texture.width,
                    48 / texture.height,
                    32 / texture.width,
                    64 / texture.height),
                x : 64, y : 96, w : 16, h : 16
            }),
            new QuadGeometry({
                batchers : [ batcher ],
                textures : [ texture ],
                uv : new Rectangle(
                    32 / texture.width,
                    48 / texture.height,
                    48 / texture.width,
                    64 / texture.height),
                x : 112, y : 96, w : 16, h : 16
            })
        ];
        
        frames = [
            new QuadGeometry({
                batchers: [ batcher ],
                textures: [ texture ],
                uv: new Rectangle(0, 0, 16 / texture.width, 16 / texture.height),
                x : 32, y : 96, w : 16, h : 16
            }),
            new QuadGeometry({
                batchers: [ batcher ],
                textures: [ texture ],
                uv: new Rectangle(0, 0, 16 / texture.width, 16 / texture.height),
                x : 80, y : 96, w : 16, h : 16
            }),
            new QuadGeometry({
                batchers: [ batcher ],
                textures: [ texture ],
                uv: new Rectangle(0, 0, 16 / texture.width, 16 / texture.height),
                x : 128, y : 96, w : 16, h : 16
            })
        ];
    }

    override function onadded()
    {
        //
    }

    override function update(_dt : Float)
    {
        camera.update(_dt);
    }
}