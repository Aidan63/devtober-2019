#version 460 core

layout(binding = 0) uniform sampler2D defaultTexture;

layout(location = 0) in vec4 Color;
layout(location = 1) in vec2 TexCoord;

layout(location = 0) out vec4 FragColor;

void main()
{
    vec4 texColour = texture(defaultTexture, TexCoord) * Color;
    if (texColour.a < 0.1)
    {
        discard;
    }

    FragColor = texColour;
}
