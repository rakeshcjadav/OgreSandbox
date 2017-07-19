#version 150

uniform samplerCube EnvMap;
uniform float alpha;
uniform float reflection;

in vec4 oPos;
in vec3 oNormal;
in vec4 oUv0;
in vec4 oPosEye;

out vec4 oColor;

void main()
{
	if(reflection == 0.0)
		discard;
		
	vec3 normal = normalize(oNormal);
	vec3 viewDir = normalize(oPosEye.xyz - oPos.xyz);
	vec3 colorReflection = texture(EnvMap, reflect(-viewDir, normal)).rgb;
	
	float cosine = dot(viewDir, normal);
	float sine = sqrt(1.0 - cosine);

	oColor = vec4(colorReflection.rgb * reflection, alpha);
}
