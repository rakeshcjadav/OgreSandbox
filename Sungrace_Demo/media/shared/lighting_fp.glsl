#version 150

uniform vec4 lightDiffuse;
uniform vec4 lightSpecular;

uniform vec4 diffuse;
uniform vec4 specular;
uniform float specularStrength;
uniform float alpha;

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
    float diff = max(0.0, dot(norm, lightDir));
    vec3 colorDiffuse = diff * lightDiffuse.rgb * diffuse.rgb;
	
	/*
	vec3 colorSpecular;
	if (dot(norm, lightDir) < 0.0) // light source on the wrong side?
    {
		colorSpecular = vec3(0.0, 0.0, 0.0); // no specular reflection
    }
	else
	{
		vec3 vecReflection = reflect(-lightDir.xyz, norm);
		vec3 vecViewDirection = normalize(vec3(oPosEye.xyz - oPos.xyz));
		float sf = pow(max(0.0, dot(vecReflection, vecViewDirection)), specular.w);
		colorSpecular = sf * lightSpecular.rgb * specular.rgb;
	}*/
	
	vec3 colorSpecular = vec3(0.0);
	if(specular.a > 0.0)
	{
		// specular
		vec3 viewDir = normalize(oPosEye.xyz - oPos.xyz);
		vec3 reflectDir = reflect(-lightDir, norm);  
		float spec = pow(max(dot(viewDir, reflectDir), 0.0), specular.a);
		colorSpecular = specularStrength * spec * lightSpecular.rgb * specular.rgb;
	}
	
	oColor = vec4(colorDiffuse * vec3(alpha) + colorSpecular, 1.0);	
}