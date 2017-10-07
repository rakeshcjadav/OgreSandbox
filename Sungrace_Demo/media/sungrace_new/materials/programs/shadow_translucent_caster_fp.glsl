#version 330

uniform sampler2D u_diffuse;

uniform float u_alphaBlendFactor;

uniform vec4 depthRange;

// Inputs
in vec4 outVertexDepth;
in vec2 outUV;

// Outputs
out vec4 finalColor;

void main()
{
    // derive a per-pixel depth and depth squared
    // (length of the view space position == distance from camera)
    // (this is linear space, not post-projection quadratic space)
	// float d = 0.001*(length(outVertexDepth.xyz) - depthRange.x) * depthRange.w;
    float d = length(0.001*outVertexDepth.xyz);
	
	vec4 diffuseColor = texture2D(u_diffuse, outUV);
	//d *= (1.0-diffuseColor.a);
	if(diffuseColor.a * u_alphaBlendFactor < 0.3)
		discard;

    finalColor = vec4(d, d * d, 1, 1);
}
