package geometry;

import uk.aidanlee.flurry.api.resources.Resource.ImageResource;
import uk.aidanlee.flurry.api.gpu.batcher.Batcher;
import uk.aidanlee.flurry.api.gpu.geometry.IndexBlob.IndexBlobBuilder;
import uk.aidanlee.flurry.api.gpu.geometry.VertexBlob.VertexBlobBuilder;
import uk.aidanlee.flurry.api.maths.Rectangle;
import uk.aidanlee.flurry.api.gpu.geometry.Geometry;

typedef NineSliceOptions = {
    var batchers : Array<Batcher>;

    var texture : ImageResource;

    var left : Float;

    var right : Float;

    var top : Float;

    var bottom : Float;

    var x : Float;

    var y : Float;

    var width : Float;

    var height : Float;

    var uv : Rectangle;
}

class NineSlice extends Geometry
{
    public function new(_options : NineSliceOptions)
    {
        final texWidth  = _options.texture.width;
        final texHeight = _options.texture.height;

        final x1 = 0;
        final x2 = _options.left;
        final x3 = _options.width - _options.right;
        final x4 = _options.width;

        final y1 = 0;
        final y2 = _options.top;
        final y3 = _options.height - _options.bottom;
        final y4 = _options.height;

        final u1 =  _options.uv.x / texWidth;
        final u2 = (_options.uv.x + _options.left) / texWidth;
        final u3 = (_options.uv.x + (_options.uv.w - _options.right)) / texWidth;
        final u4 = (_options.uv.x + _options.uv.w) / texWidth;

        final v1 =  _options.uv.y / texHeight;
        final v2 = (_options.uv.y + _options.top) / texHeight;
        final v3 = (_options.uv.y + (_options.uv.h - _options.bottom)) / texHeight;
        final v4 = (_options.uv.y + _options.uv.h) / texHeight;

        super({
            data : Indexed(
                new VertexBlobBuilder()
                // Top Left
                .addFloat3(x1, y2, 0).addFloat4(1, 1, 1, 1).addFloat2(u1, v2)
                .addFloat3(x2, y2, 0).addFloat4(1, 1, 1, 1).addFloat2(u2, v2)
                .addFloat3(x1, y1, 0).addFloat4(1, 1, 1, 1).addFloat2(u1, v1)
                .addFloat3(x2, y1, 0).addFloat4(1, 1, 1, 1).addFloat2(u2, v1)

                // Top Middle
                .addFloat3(x2, y2, 0).addFloat4(1, 1, 1, 1).addFloat2(u2, v2)
                .addFloat3(x3, y2, 0).addFloat4(1, 1, 1, 1).addFloat2(u3, v2)
                .addFloat3(x2, y1, 0).addFloat4(1, 1, 1, 1).addFloat2(u2, v1)
                .addFloat3(x3, y1, 0).addFloat4(1, 1, 1, 1).addFloat2(u3, v1)

                // Top Right
                .addFloat3(x3, y2, 0).addFloat4(1, 1, 1, 1).addFloat2(u3, v2)
                .addFloat3(x4, y2, 0).addFloat4(1, 1, 1, 1).addFloat2(u4, v2)
                .addFloat3(x3, y1, 0).addFloat4(1, 1, 1, 1).addFloat2(u3, v1)
                .addFloat3(x4, y1, 0).addFloat4(1, 1, 1, 1).addFloat2(u4, v1)

                // Middle Left
                .addFloat3(x1, y3, 0).addFloat4(1, 1, 1, 1).addFloat2(u1, v3)
                .addFloat3(x2, y3, 0).addFloat4(1, 1, 1, 1).addFloat2(u2, v3)
                .addFloat3(x1, y2, 0).addFloat4(1, 1, 1, 1).addFloat2(u1, v2)
                .addFloat3(x2, y2, 0).addFloat4(1, 1, 1, 1).addFloat2(u2, v2)

                // Middle Middle
                .addFloat3(x2, y3, 0).addFloat4(1, 1, 1, 1).addFloat2(u2, v3)
                .addFloat3(x3, y3, 0).addFloat4(1, 1, 1, 1).addFloat2(u3, v3)
                .addFloat3(x2, y2, 0).addFloat4(1, 1, 1, 1).addFloat2(u2, v2)
                .addFloat3(x3, y2, 0).addFloat4(1, 1, 1, 1).addFloat2(u3, v2)

                // Middle Right
                .addFloat3(x3, y3, 0).addFloat4(1, 1, 1, 1).addFloat2(u3, v3)
                .addFloat3(x4, y3, 0).addFloat4(1, 1, 1, 1).addFloat2(u4, v3)
                .addFloat3(x3, y2, 0).addFloat4(1, 1, 1, 1).addFloat2(u3, v2)
                .addFloat3(x4, y2, 0).addFloat4(1, 1, 1, 1).addFloat2(u4, v2)

                // Bottom Left
                .addFloat3(x1, y4, 0).addFloat4(1, 1, 1, 1).addFloat2(u1, v4)
                .addFloat3(x2, y4, 0).addFloat4(1, 1, 1, 1).addFloat2(u2, v4)
                .addFloat3(x1, y3, 0).addFloat4(1, 1, 1, 1).addFloat2(u1, v3)
                .addFloat3(x2, y3, 0).addFloat4(1, 1, 1, 1).addFloat2(u2, v3)

                // Bottom Middle
                .addFloat3(x2, y4, 0).addFloat4(1, 1, 1, 1).addFloat2(u2, v4)
                .addFloat3(x3, y4, 0).addFloat4(1, 1, 1, 1).addFloat2(u3, v4)
                .addFloat3(x2, y3, 0).addFloat4(1, 1, 1, 1).addFloat2(u2, v3)
                .addFloat3(x3, y3, 0).addFloat4(1, 1, 1, 1).addFloat2(u3, v3)

                // Bottom Right
                .addFloat3(x3, y4, 0).addFloat4(1, 1, 1, 1).addFloat2(u3, v4)
                .addFloat3(x4, y4, 0).addFloat4(1, 1, 1, 1).addFloat2(u4, v4)
                .addFloat3(x3, y3, 0).addFloat4(1, 1, 1, 1).addFloat2(u3, v3)
                .addFloat3(x4, y3, 0).addFloat4(1, 1, 1, 1).addFloat2(u4, v3)

                .vertexBlob(),

                new IndexBlobBuilder()
                .addInts([ 0, 1, 2, 2, 1, 3 ])
                .addInts([ 4 + 0, 4 + 1, 4 + 2, 4 + 2, 4 + 1, 4 + 3 ])
                .addInts([ 8 + 0, 8 + 1, 8 + 2, 8 + 2, 8 + 1, 8 + 3 ])

                .addInts([ 12 + 0, 12 + 1, 12 + 2, 12 + 2, 12 + 1, 12 + 3 ])
                .addInts([ 16 + 0, 16 + 1, 16 + 2, 16 + 2, 16 + 1, 16 + 3 ])
                .addInts([ 20 + 0, 20 + 1, 20 + 2, 20 + 2, 20 + 1, 20 + 3 ])

                .addInts([ 24 + 0, 24 + 1, 24 + 2, 24 + 2, 24 + 1, 24 + 3 ])
                .addInts([ 28 + 0, 28 + 1, 28 + 2, 28 + 2, 28 + 1, 28 + 3 ])
                .addInts([ 32 + 0, 32 + 1, 32 + 2, 32 + 2, 32 + 1, 32 + 3 ])

                .indexBlob()),
            textures: Textures([ _options.texture ]),
            batchers: _options.batchers
        });

        position.set_xy(_options.x, _options.y);
    }
}