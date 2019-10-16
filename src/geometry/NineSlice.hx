package geometry;

import uk.aidanlee.flurry.api.gpu.geometry.Vertex;
import uk.aidanlee.flurry.api.maths.Rectangle;
import uk.aidanlee.flurry.api.maths.Vector;
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
        super(_options);

        final texWidth  = _options.textures[0].width;
        final texHeight = _options.textures[0].height;

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

        vertices.resize(36);

        // Top Left
        vertices[0] = new Vertex( new Vector(x1, y2), color, new Vector(u1, v2) );
        vertices[1] = new Vertex( new Vector(x2, y2), color, new Vector(u2, v2) );
        vertices[2] = new Vertex( new Vector(x1, y1), color, new Vector(u1, v1) );
        vertices[3] = new Vertex( new Vector(x2, y1), color, new Vector(u2, v1) );

        // Top Middle
        vertices[4] = new Vertex( new Vector(x2, y2), color, new Vector(u2, v2) );
        vertices[5] = new Vertex( new Vector(x3, y2), color, new Vector(u3, v2) );
        vertices[6] = new Vertex( new Vector(x2, y1), color, new Vector(u2, v1) );
        vertices[7] = new Vertex( new Vector(x3, y1), color, new Vector(u3, v1) );

        // Top Right
        vertices[ 8] = new Vertex( new Vector(x3, y2), color, new Vector(u3, v2) );
        vertices[ 9] = new Vertex( new Vector(x4, y2), color, new Vector(u4, v2) );
        vertices[10] = new Vertex( new Vector(x3, y1), color, new Vector(u3, v1) );
        vertices[11] = new Vertex( new Vector(x4, y1), color, new Vector(u4, v1) );

        // Middle Left
        vertices[12] = new Vertex( new Vector(x1, y3), color, new Vector(u1, v3) );
        vertices[13] = new Vertex( new Vector(x2, y3), color, new Vector(u2, v3) );
        vertices[14] = new Vertex( new Vector(x1, y2), color, new Vector(u1, v2) );
        vertices[15] = new Vertex( new Vector(x2, y2), color, new Vector(u2, v2) );

        // Middle Middle
        vertices[16] = new Vertex( new Vector(x2, y3), color, new Vector(u2, v3) );
        vertices[17] = new Vertex( new Vector(x3, y3), color, new Vector(u3, v3) );
        vertices[18] = new Vertex( new Vector(x2, y2), color, new Vector(u2, v2) );
        vertices[19] = new Vertex( new Vector(x3, y2), color, new Vector(u3, v2) );

        // Middle Right
        vertices[20] = new Vertex( new Vector(x3, y3), color, new Vector(u3, v3) );
        vertices[21] = new Vertex( new Vector(x4, y3), color, new Vector(u4, v3) );
        vertices[22] = new Vertex( new Vector(x3, y2), color, new Vector(u3, v2) );
        vertices[23] = new Vertex( new Vector(x4, y2), color, new Vector(u4, v2) );

        // Bottom Left
        vertices[24] = new Vertex( new Vector(x1, y4), color, new Vector(u1, v4) );
        vertices[25] = new Vertex( new Vector(x2, y4), color, new Vector(u2, v4) );
        vertices[26] = new Vertex( new Vector(x1, y3), color, new Vector(u1, v3) );
        vertices[27] = new Vertex( new Vector(x2, y3), color, new Vector(u2, v3) );

        // Bottom Middle
        vertices[28] = new Vertex( new Vector(x2, y4), color, new Vector(u2, v4) );
        vertices[29] = new Vertex( new Vector(x3, y4), color, new Vector(u3, v4) );
        vertices[30] = new Vertex( new Vector(x2, y3), color, new Vector(u2, v3) );
        vertices[31] = new Vertex( new Vector(x3, y3), color, new Vector(u3, v3) );

        // Bottom Right
        vertices[32] = new Vertex( new Vector(x3, y4), color, new Vector(u3, v4) );
        vertices[33] = new Vertex( new Vector(x4, y4), color, new Vector(u4, v4) );
        vertices[34] = new Vertex( new Vector(x3, y3), color, new Vector(u3, v3) );
        vertices[35] = new Vertex( new Vector(x4, y3), color, new Vector(u4, v3) );

        indices.resize(54);

        indices[0] = 0;
        indices[1] = 1;
        indices[2] = 2;
        indices[3] = 2;
        indices[4] = 1;
        indices[5] = 3;

        indices[6 + 0] = 4 + 0;
        indices[6 + 1] = 4 + 1;
        indices[6 + 2] = 4 + 2;
        indices[6 + 3] = 4 + 2;
        indices[6 + 4] = 4 + 1;
        indices[6 + 5] = 4 + 3;

        indices[12 + 0] = 8 + 0;
        indices[12 + 1] = 8 + 1;
        indices[12 + 2] = 8 + 2;
        indices[12 + 3] = 8 + 2;
        indices[12 + 4] = 8 + 1;
        indices[12 + 5] = 8 + 3;

        indices[18 + 0] = 12 + 0;
        indices[18 + 1] = 12 + 1;
        indices[18 + 2] = 12 + 2;
        indices[18 + 3] = 12 + 2;
        indices[18 + 4] = 12 + 1;
        indices[18 + 5] = 12 + 3;

        indices[24 + 0] = 16 + 0;
        indices[24 + 1] = 16 + 1;
        indices[24 + 2] = 16 + 2;
        indices[24 + 3] = 16 + 2;
        indices[24 + 4] = 16 + 1;
        indices[24 + 5] = 16 + 3;

        indices[30 + 0] = 20 + 0;
        indices[30 + 1] = 20 + 1;
        indices[30 + 2] = 20 + 2;
        indices[30 + 3] = 20 + 2;
        indices[30 + 4] = 20 + 1;
        indices[30 + 5] = 20 + 3;

        indices[36 + 0] = 24 + 0;
        indices[36 + 1] = 24 + 1;
        indices[36 + 2] = 24 + 2;
        indices[36 + 3] = 24 + 2;
        indices[36 + 4] = 24 + 1;
        indices[36 + 5] = 24 + 3;

        indices[42 + 0] = 28 + 0;
        indices[42 + 1] = 28 + 1;
        indices[42 + 2] = 28 + 2;
        indices[42 + 3] = 28 + 2;
        indices[42 + 4] = 28 + 1;
        indices[42 + 5] = 28 + 3;

        indices[48 + 0] = 32 + 0;
        indices[48 + 1] = 32 + 1;
        indices[48 + 2] = 32 + 2;
        indices[48 + 3] = 32 + 2;
        indices[48 + 4] = 32 + 1;
        indices[48 + 5] = 32 + 3;


        position.set_xy(_options.x, _options.y);
    }
}