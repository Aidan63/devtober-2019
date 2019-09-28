Texture2D    defaultTexture : register(t0);
SamplerState defaultSampler : register(s0);

float4 PShader(float4 position : SV_POSITION, float4 color : COLOR, float2 texcoord : TEXCOORD) : SV_TARGET
{
	return defaultTexture.Sample(defaultSampler, texcoord) * color;
}