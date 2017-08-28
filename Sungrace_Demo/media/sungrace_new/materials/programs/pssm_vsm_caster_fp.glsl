#version 330

uniform vec4 depthRange;

// Inputs
in vec4 outVertexDepth;

// Outputs
out vec4 finalColor;

void main()
{
    // derive a per-pixel depth and depth squared
    // (length of the view space position == distance from camera)
    // (this is linear space, not post-projection quadratic space)
	// float d = 0.001*(length(outVertexDepth.xyz) - depthRange.x) * depthRange.w;
    float d = length(0.001*outVertexDepth.xyz);

    finalColor = vec4(d, d * d, 1, 1);
}
