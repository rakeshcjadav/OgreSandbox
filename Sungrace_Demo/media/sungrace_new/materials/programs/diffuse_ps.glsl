#version 150

uniform vec2 u_uvScale;

// 1: use texture, 0: use constant color.
uniform int u_hasDiffuseTexture;

// The diffuse texture.
uniform sampler2D u_diffuse;

// The constant diffuse color.
uniform vec3 u_constantDiffuseColor;

// the alpha blend factor.
uniform float u_alphaBlendFactor;

uniform float u_reflectivity;

in vec2 outUV;

out vec4 finalColor;

void main()
{
    vec4 colorDiffuse = vec4(1.0);
	colorDiffuse.rgb = u_constantDiffuseColor;
	
    if (u_hasDiffuseTexture != 0)
    {
        colorDiffuse = texture2D(u_diffuse, u_uvScale*outUV);
		colorDiffuse.rgb += vec3(1.0 - colorDiffuse.a * u_alphaBlendFactor);
    }
	
	colorDiffuse.rgb = mix(colorDiffuse.rgb, vec3(0.0), u_reflectivity);
    finalColor = colorDiffuse;
}