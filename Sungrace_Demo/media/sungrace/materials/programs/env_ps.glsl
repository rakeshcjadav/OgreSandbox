#version 150

uniform samplerCube u_env;

// the alpha blend factor.
uniform float u_alphaBlendFactor;

// environment mapping.
uniform float u_reflectivity;

in vec4 outVertex;
in vec3 outNormal;
in vec4 outCameraPosition;

out vec4 finalColor;

void main()
{
	if(u_reflectivity == 0.0)
		discard;

	vec3 normal = normalize(outNormal);
	vec3 viewDir = normalize(outCameraPosition.xyz - outVertex.xyz);
	vec3 colorReflection = texture(u_env, reflect(-viewDir, normal)).rgb;
	
	//float cosine = dot(viewDir, normal);
	//float sine = sqrt(1.0 - cosine);

	finalColor = vec4(colorReflection.rgb * u_reflectivity, u_alphaBlendFactor);
}
