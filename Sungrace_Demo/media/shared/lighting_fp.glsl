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
	// diffuse
	vec3 norm = normalize(oNormal);
	vec3 lightDir = vec3(1.0);
	
	// For "Directional light" forth component in light position is set 0.0
	if(oPosLight.w == 0.0)
		lightDir = oPosLight.xyz;
	else
		lightDir = normalize(oPosLight.xyz - oPos.xyz);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightDiffuse.rgb;
	
	// specular
    float specularStrength = 1.0;
    vec3 viewDir = normalize(oPosEye.xyz - oPos.xyz);
    vec3 reflectDir = reflect(-lightDir, norm);  
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 20);
    vec3 specular = specularStrength * spec * lightSpecular.rgb;  
	
	oColor = vec4(diffuse + specular, 1.0);	
}