#version 150

// Global scene ambient color.
uniform vec4 u_lightAmbientColor;

// ambient color reflection for this material.
uniform vec3 u_constantAmbientColor;

// the alpha blend factor.
uniform float u_alphaBlendFactor;

out vec4 finalColor;

void main()
{
	finalColor = vec4(u_lightAmbientColor.rgb * u_constantAmbientColor.rgb, u_alphaBlendFactor);
}
