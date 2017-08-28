#version 150

uniform vec2 u_uvScale;

// 1: use texture, 0: use constant color.
uniform int u_hasDiffuseTexture;

// The diffuse texture.
uniform sampler2D u_diffuse;

uniform int u_hasDecalTexture;

// The decal texture.
uniform sampler2D u_decal;

// The constant diffuse color.
uniform vec3 u_constantDiffuseColor;

// .x = transparency for object.
// .y = transparency for pattern.
uniform vec2 u_transparency;

uniform int u_isTransparent;

uniform float u_reflectivity;

in vec2 outUV;

out vec4 finalColor;

void main()
{
    vec4 colorDiffuse = vec4(1.0);
	colorDiffuse.rgb = u_constantDiffuseColor;
	colorDiffuse.a = u_transparency.x;
	
    if (u_hasDiffuseTexture != 0)
    {
        vec4 colorDiffuseTexture = texture2D(u_diffuse, u_uvScale*vec2(outUV.x, 1.0 - outUV.y));
        colorDiffuse = mix(colorDiffuse, colorDiffuseTexture, colorDiffuseTexture.a * u_transparency.y);
    }

    if (u_hasDecalTexture != 0)
    {
        vec4 colorDecal = texture2D(u_decal, u_uvScale*vec2(outUV.x, 1.0 - outUV.y));
        if (colorDecal != vec4(0.0, 0.0, 0.0, 0.0))
        {
            colorDiffuse = mix(colorDiffuse, colorDecal, u_transparency.y);
        }
    }
	
	if ((u_isTransparent != 0) && (colorDiffuse.a < 0.1))
       discard;
	
    finalColor = colorDiffuse;
}