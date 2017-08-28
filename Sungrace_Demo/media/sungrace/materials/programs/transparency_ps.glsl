#version 150

// the alpha blend factor.
uniform float u_alphaBlendFactor;

out vec4 finalColor;

void main()
{
	finalColor = vec4(vec3(u_alphaBlendFactor - 1.0), u_alphaBlendFactor);// vec4(1.0, 1.0, 1.0, u_alphaBlendFactor);
}
