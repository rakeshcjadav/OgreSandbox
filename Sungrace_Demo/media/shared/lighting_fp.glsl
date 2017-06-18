#version 150

uniform vec4 lightDiffuse;
uniform vec4 lightSpecular;

in vec4 oPos;
in vec3 oNormal;
in vec4 oUv0;
in vec4 oPosLight;
in vec4 oPosEye;

out vec4 oColor;

void main()
{
	vec3 N = normalize(oNormal);
 
    vec3 EyeDir = normalize(oPosEye.xyz - oPos.xyz);
    vec3 LightDir = normalize(oPosLight.xyz -  (oPos.xyz * oPosLight.w));
    vec3 HalfAngle = normalize(LightDir + EyeDir);
 
	float diffuse = dot(LightDir, N);
	float specular = pow(dot(HalfAngle, N), 127);

	oColor = lightDiffuse * diffuse + lightSpecular * specular;
}