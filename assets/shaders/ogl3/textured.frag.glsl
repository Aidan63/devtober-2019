#version 330 core

in vec4 Color;
in vec2 TexCoord;

out vec4 FragColor;

uniform sampler2D defaultTexture;

void main()
{
    vec4 texColour = texture(defaultTexture, TexCoord) * Color;
    // if (texColour.a < 0.1)
    // {
    //     discard;
    // }
    
    FragColor = texColour;
}
