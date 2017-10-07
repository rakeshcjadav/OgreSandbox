#version 330

uniform vec2 u_uvScale;

uniform int u_hasDiffuseTexture;
uniform sampler2D u_diffuse;

// .x = transparency for object.
// .y = transparency for pattern.
uniform vec2 u_transparency;

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
	
	if(u_hasDiffuseTexture != 0)
	{
		float fAlpha = texture2D(u_diffuse, u_uvScale*vec2(outUV.x, 1.0 - outUV.y)).a;
		if(fAlpha * max(u_transparency.x, u_transparency.y) < 0.3)
			discard;
	}

    finalColor = vec4(d, d * d, 1, 1);
}
