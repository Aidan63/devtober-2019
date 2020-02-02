package geometry;

import uk.aidanlee.flurry.api.gpu.geometry.Color;
import uk.aidanlee.flurry.api.gpu.geometry.IndexBlob.IndexBlobBuilder;
import uk.aidanlee.flurry.api.gpu.geometry.VertexBlob.VertexBlobBuilder;
import uk.aidanlee.flurry.api.maths.Rectangle;
import uk.aidanlee.flurry.api.maths.Vector3;
import uk.aidanlee.flurry.api.maths.Vector2;
import uk.aidanlee.flurry.api.gpu.geometry.Geometry;

typedef NineSliceOptions = {
    >GeometryOptions,

    var left : Float;

    var right : Float;

    var top : Float;

    var bottom : Float;

    var x : Float;

    var y : Float;

    var w : Float;

    var h : Float;

    var uv : Rectangle;
}

class NineSlice extends Geometry
{
    public function new(_options : NineSliceOptions)
    {
        var texWidth  = 1;
        var texHeight = 1;
        switch _options.textures
        {
            case Textures(_textures):
                texWidth  = _textures[0].width;
                texHeight = _textures[0].height;
            case _:
        }

        final x1 = 0;
        final x2 = _options.left;
        final x3 = _options.w - _options.right;
        final x4 = _options.w;

        final y1 = 0;
        final y2 = _options.top;
        final y3 = _options.h - _options.bottom;
        final y4 = _options.h;

        final u1 =  _options.uv.x / texWidth;
        final u2 = (_options.uv.x + _options.left) / texWidth;
        final u3 = (_options.uv.x + (_options.uv.w - _options.right)) / texWidth;
        final u4 = (_options.uv.x + _options.uv.w) / texWidth;

        final v1 =  _options.uv.y / texHeight;
        final v2 = (_options.uv.y + _options.top) / texHeight;
        final v3 = (_options.uv.y + (_options.uv.h - _options.bottom)) / texHeight;
        final v4 = (_options.uv.y + _options.uv.h) / texHeight;

        final customColor = new Color();

        _options.data = Indexed(
            new VertexBlobBuilder()
                // Top Left
                .addVertex(new Vector3(x1, y2), customColor, new Vector2(u1, v2))
                .addVertex(new Vector3(x2, y2), customColor, new Vector2(u2, v2))
                .addVertex(new Vector3(x1, y1), customColor, new Vector2(u1, v1))
                .addVertex(new Vector3(x2, y1), customColor, new Vector2(u2, v1))

                // Top Middle
                .addVertex(new Vector3(x2, y2), customColor, new Vector2(u2, v2))
                .addVertex(new Vector3(x3, y2), customColor, new Vector2(u3, v2))
                .addVertex(new Vector3(x2, y1), customColor, new Vector2(u2, v1))
                .addVertex(new Vector3(x3, y1), customColor, new Vector2(u3, v1))

                // Top Right
                .addVertex(new Vector3(x3, y2), customColor, new Vector2(u3, v2))
                .addVertex(new Vector3(x4, y2), customColor, new Vector2(u4, v2))
                .addVertex(new Vector3(x3, y1), customColor, new Vector2(u3, v1))
                .addVertex(new Vector3(x4, y1), customColor, new Vector2(u4, v1))

                // Middle Left
                .addVertex(new Vector3(x1, y3), customColor, new Vector2(u1, v3))
                .addVertex(new Vector3(x2, y3), customColor, new Vector2(u2, v3))
                .addVertex(new Vector3(x1, y2), customColor, new Vector2(u1, v2))
                .addVertex(new Vector3(x2, y2), customColor, new Vector2(u2, v2))

                // Middle Middle
                .addVertex(new Vector3(x2, y3), customColor, new Vector2(u2, v3))
                .addVertex(new Vector3(x3, y3), customColor, new Vector2(u3, v3))
                .addVertex(new Vector3(x2, y2), customColor, new Vector2(u2, v2))
                .addVertex(new Vector3(x3, y2), customColor, new Vector2(u3, v2))

                // Middle Right
                .addVertex(new Vector3(x3, y3), customColor, new Vector2(u3, v3))
                .addVertex(new Vector3(x4, y3), customColor, new Vector2(u4, v3))
                .addVertex(new Vector3(x3, y2), customColor, new Vector2(u3, v2))
                .addVertex(new Vector3(x4, y2), customColor, new Vector2(u4, v2))

                // Bottom Left
                .addVertex(new Vector3(x1, y4), customColor, new Vector2(u1, v4))
                .addVertex(new Vector3(x2, y4), customColor, new Vector2(u2, v4))
                .addVertex(new Vector3(x1, y3), customColor, new Vector2(u1, v3))
                .addVertex(new Vector3(x2, y3), customColor, new Vector2(u2, v3))

                // Bottom Middle
                .addVertex(new Vector3(x2, y4), customColor, new Vector2(u2, v4))
                .addVertex(new Vector3(x3, y4), customColor, new Vector2(u3, v4))
                .addVertex(new Vector3(x2, y3), customColor, new Vector2(u2, v3))
                .addVertex(new Vector3(x3, y3), customColor, new Vector2(u3, v3))

                // Bottom Right
                .addVertex(new Vector3(x3, y4), customColor, new Vector2(u3, v4))
                .addVertex(new Vector3(x4, y4), customColor, new Vector2(u4, v4))
                .addVertex(new Vector3(x3, y3), customColor, new Vector2(u3, v3))
                .addVertex(new Vector3(x4, y3), customColor, new Vector2(u4, v3))

                .vertexBlob(),
            new IndexBlobBuilder(54)
                .addArray([ 0, 1, 2, 2, 1, 3 ])
                .addArray([ 4 + 0, 4 + 1, 4 + 2, 4 + 2, 4 + 1, 4 + 3 ])
                .addArray([ 8 + 0, 8 + 1, 8 + 2, 8 + 2, 8 + 1, 8 + 3 ])

                .addArray([ 12 + 0, 12 + 1, 12 + 2, 12 + 2, 12 + 1, 12 + 3 ])
                .addArray([ 16 + 0, 16 + 1, 16 + 2, 16 + 2, 16 + 1, 16 + 3 ])
                .addArray([ 20 + 0, 20 + 1, 20 + 2, 20 + 2, 20 + 1, 20 + 3 ])

                .addArray([ 24 + 0, 24 + 1, 24 + 2, 24 + 2, 24 + 1, 24 + 3 ])
                .addArray([ 28 + 0, 28 + 1, 28 + 2, 28 + 2, 28 + 1, 28 + 3 ])
                .addArray([ 32 + 0, 32 + 1, 32 + 2, 32 + 2, 32 + 1, 32 + 3 ])

                .indices
        );

        super(_options);

        position.set_xy(_options.x, _options.y);
    }
}