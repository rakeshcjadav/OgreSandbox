#version 150

// Global scene ambient color.
uniform vec4 u_lightAmbientColor;

// ambient color reflection for this material.
uniform vec3 u_constantAmbientColor;

uniform float u_lightCount;

uniform vec2 u_uvScale;

uniform int u_hasDiffuseTexture;
uniform sampler2D u_diffuse;

uniform int u_hasDecalTexture;
uniform sampler2D u_decal;

// .x = transparency for object.
// .y = transparency for pattern.
uniform vec2 u_transparency;

// Inputs
in vec2 outUV;

// Outputs
out vec4 finalColor;

void main()
{
	float fAlpha = u_transparency.x;
	
	if (u_hasDiffuseTexture != 0)
    {
        fAlpha *= texture2D(u_diffuse, u_uvScale*vec2(outUV.x, 1.0 - outUV.y)).a;
    }
	
	if (u_hasDecalTexture != 0)
    {
        float fDecalAlpha = texture2D(u_decal, u_uvScale*vec2(outUV.x, 1.0 - outUV.y)).a;
		fAlpha = clamp(fAlpha + fDecalAlpha * u_transparency.y, 0.0, 1.0);
    }
	
	if(u_lightCount < 1.0)
		finalColor = vec4(1.0, 1.0, 1.0, fAlpha);
	else
		finalColor = vec4(u_lightAmbientColor.rgb * u_constantAmbientColor.rgb, fAlpha);
}
