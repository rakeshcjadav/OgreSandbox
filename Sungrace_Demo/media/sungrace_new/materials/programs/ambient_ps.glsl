#version 150

// Global scene ambient color.
uniform vec4 u_lightAmbientColor;

// ambient color reflection for this material.
uniform vec3 u_constantAmbientColor;

// the alpha blend factor.
uniform float u_alphaBlendFactor;

uniform float u_lightCount;

out vec4 finalColor;

void main()
{
	if(u_lightCount < 1.0)
		finalColor = vec4(1.0, 1.0, 1.0, u_alphaBlendFactor);
	else
		finalColor = vec4(u_lightAmbientColor.rgb * u_constantAmbientColor.rgb, u_alphaBlendFactor);
}
