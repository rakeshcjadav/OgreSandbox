#version 150

uniform vec2 u_uvScale;

uniform vec3 u_eyePositionWorldSpace;

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
    vec3 diffuse = u_hasDiffuseTexture == 0 ? 
       u_constantDiffuseColor : texture2D(u_diffuse, u_uvScale*outUV).rgb;

	diffuse = mix(diffuse, vec3(0.0), u_reflectivity);
    finalColor = vec4(diffuse, u_alphaBlendFactor);
}