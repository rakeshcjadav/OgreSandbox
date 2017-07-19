#version 150

uniform vec4 lightDiffuse;
uniform vec4 lightSpecular;
uniform vec4 lightParams;
uniform vec4 lightAttenuation;

uniform vec4 diffuse;
uniform vec4 specular;
uniform float specularStrength;
uniform float alpha;
uniform float reflection;

uniform float lightCastShadows;

uniform sampler2D ShadowMap;

in vec4 oPos;
in vec3 oNormal;
in vec4 oUv0;
in vec4 oPosLight;
in vec4 oDirLight;
in vec4 oPosEye;

out vec4 oColor;

void main()
{
	// diffuse
	vec3 normal = normalize(oNormal);
	vec3 lightDir = vec3(1.0);
	float attenuation = 0.0;
	
	// For "Directional light" forth component in light position is set 0.0
	if(oPosLight.w == 0.0)
	{
		lightDir = oPosLight.xyz;
		attenuation = 1.0;
	}
	else
	{
		vec3 vertexToLightSource = vec3(oPosLight.xyz - oPos.xyz);
		lightDir = normalize(vertexToLightSource);
		float distance = length(vertexToLightSource);
		float r = clamp(distance/lightAttenuation.x, 0.0, 1.0);
		attenuation = 1.0 / ( 1.0 + 25.0 * r * r);
	}
	
    float diff = max(0.0, dot(normal, lightDir));
    vec3 colorDiffuse = diff * lightDiffuse.rgb * diffuse.rgb * attenuation;
	
	vec3 colorSpecular = vec3(0.0);
	if(specular.a > 0.0)
	{
		// specular
		vec3 viewDir = normalize(oPosEye.xyz - oPos.xyz);
		vec3 reflectDir = reflect(-lightDir, normal);  
		float spec = pow(max(dot(viewDir, reflectDir), 0.0), specular.a);
		colorSpecular = specularStrength * spec * lightSpecular.rgb * specular.rgb * attenuation;
	}
	
	// If light is a spotlight <=> lightParams.y > 0.0
	float colorSpotLight = 1.0;
    if (lightParams.y > 0.0)
    {
        float cosCurAngle = dot(-lightDir, normalize(oDirLight.xyz));
		//if(cosCurAngle < lightParams.y)
		//	colorSpotLight = 0.0;
        float cosInnerConeAngle = lightParams.x;
        float cosOuterConeAngle = lightParams.y;
        float cosInnerMinusOuterAngle = cosInnerConeAngle - cosOuterConeAngle;
        colorSpotLight *= clamp((cosCurAngle - cosOuterConeAngle)/cosInnerMinusOuterAngle, 0.0, 1.0);
    }
	
	// Shadow
    //float depth = 0.001*length(oPosLight.xyz - oPos.xyz);
    //float maskCoefficient = diff*shadowPCF(shadowMap, positionShadowLightSpace, u_invShadowMapSize.xy, depth);
	
	oColor = vec4((colorDiffuse * vec3(alpha) * vec3(colorSpotLight) + colorSpecular), 1.0);	
}