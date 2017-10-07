#version 150

// Global scene ambient color.
uniform vec4 u_lightAmbientColor;

// ambient color reflection for this material.
uniform vec3 u_constantAmbientColor;

// the alpha blend factor.
uniform float u_alphaBlendFactor;

uniform float u_lightCount;

uniform int u_hasDiffuseTexture;
uniform vec2 u_uvScale;
uniform sampler2D u_diffuse;

// Inputs
in vec2 outUV;

// Outputs
out vec4 finalColor;

void main()
{
	float fAlpha = u_alphaBlendFactor;
	
	if (u_hasDiffuseTexture != 0)
    {
        fAlpha *= texture2D(u_diffuse, u_uvScale*outUV).a;
    }
	
	if(u_lightCount < 1.0)
		finalColor = vec4(1.0, 1.0, 1.0, fAlpha);
	else
		finalColor = vec4(u_lightAmbientColor.rgb * u_constantAmbientColor.rgb, fAlpha);
}
