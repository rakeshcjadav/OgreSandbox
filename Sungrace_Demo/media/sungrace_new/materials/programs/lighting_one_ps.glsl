#version 330

uniform float u_numLights;

uniform float u_castShadows0;

uniform sampler2D u_shadowMap0;

// .xyz = the specular color, .w = the specular exponent.
uniform vec4 u_specular_exponent;

// the alpha blend factor.
uniform float u_alphaBlendFactor;

// environment mapping.
uniform float u_reflectivity;

uniform vec4 u_lightParameters0;
uniform vec4 u_lightPositionWorldSpace0;
uniform vec4 u_lightDirection0;
uniform vec4 u_lightDiffuseColor0;
uniform vec4 u_lightSpecularColor0;
uniform vec4 u_lightAttenuation0;

uniform vec4 u_invShadowMapSize;
uniform vec3 u_eyePositionWorldSpace;

uniform vec2 u_uvScale;

uniform int u_hasDiffuseTexture;
uniform sampler2D u_diffuse;

uniform int u_hasDecalTexture;
uniform sampler2D u_decal;

// .x = transparency for object.
// .y = transparency for pattern.
uniform vec2 u_transparency;

// Input from Fragment shader
in vec4 outVertex;
in vec3 outNormal;
in vec2 outUV;
in vec4 outCameraPosition;

// The vertex position in the light space for every 
// shadow casting light.
in vec4 outPositionShadowLightSpace;

// Output
out vec4 finalColor;


float
shadowPCF(
    sampler2D shadowMap,
    vec4 shadowMapPos,
    vec2 offset,
    float depth)
{
    vec2 uv = (shadowMapPos / shadowMapPos.w).xy;

    vec2 o = offset;
    vec2 moments = texture2D(shadowMap, uv).rg +
          texture2D(shadowMap, uv - o).rg +
          texture2D(shadowMap, uv + o).rg +
          texture2D(shadowMap, vec2(uv.x - o.x, uv.y)).rg +
          texture2D(shadowMap, vec2(uv.x + o.x, uv.y)).rg +
          texture2D(shadowMap, vec2(uv.x, uv.y + o.y)).rg +
          texture2D(shadowMap, vec2(uv.x, uv.y - o.y)).rg +
          texture2D(shadowMap, vec2(uv.x - o.x, uv.y + o.y)).rg +
          texture2D(shadowMap, vec2(uv.x + o.x, uv.y - o.y)).rg;
      moments /= 9.0;
	  
      float litFactor = (depth <= moments.x ? 1.0 : 0.0);

      // standard variance shadow mapping code
      float E_x2 = moments.y;
      float Ex_2 = moments.x * moments.x;
      float vsmEpsilon = 0.01;
      float variance = min(max(E_x2 - Ex_2, 0.0) + vsmEpsilon, 1.0);
      float m_d = moments.x - depth;
      float p = variance / (variance + m_d * m_d);

      return smoothstep(0.4, 1.0, max(litFactor, p));
}

vec3 ComputeLight(
    in vec4 lightPositionWorldSpace,
    in vec4 lightParameters,
    in vec3 lightDirection,
    in vec3 lightDiffuseColor,
    in vec3 lightSpecularColor,
    in vec4 lightAttenuation,
    in sampler2D shadowMap,
	in float bCastShadows,
    in vec4 positionShadowLightSpace,
	inout vec3 colorSpecular,
	inout float colorShadow)
{
	vec3 normal = normalize(outNormal);
	
	if(gl_FrontFacing == false)
		normal *= vec3(-1.0);
	
	// diffuse component
	vec3 dirLightToFragment = vec3(1.0);
	float attenuation = 0.0;
	
	// For "Directional light" forth component in light position is set 0.0
	if(lightPositionWorldSpace.w == 0.0)
	{
		dirLightToFragment = -normalize(lightDirection.xyz);
		attenuation = 1.0;
	}
	else
	{
		vec3 vFragmentToLightSource = vec3(lightPositionWorldSpace.xyz - outVertex.xyz);
		dirLightToFragment = normalize(vFragmentToLightSource);
		float distance = length(vFragmentToLightSource);
		distance = distance/lightAttenuation.x;
		if(distance == 0.0)
			attenuation = 1.0;
		else if(distance > 0.0)
			attenuation = 1.0/(25.0 * distance * distance);
	}
	
    float diffuseComponent = max(0.0, dot(normal, dirLightToFragment));
    vec3 colorDiffuse = diffuseComponent * 
						lightDiffuseColor.rgb * 
						attenuation;
	
	// specular component
	//vec3 colorSpecular = vec3(0.0);
	if(u_specular_exponent.a > 0.0)
	{
		float u_specularStrengh = 1.0;
		vec3 viewDir = normalize(outCameraPosition.xyz - outVertex.xyz);
		vec3 reflectDir = reflect(-dirLightToFragment, normal);  
		float specularComponent = pow(max(dot(viewDir, reflectDir), 0.0), u_specular_exponent.w);
		colorSpecular += u_specularStrengh * 
						specularComponent * 
						lightSpecularColor.rgb * 
						u_specular_exponent.rgb *
						attenuation * 
						u_alphaBlendFactor;
	}
	
	// Spot light cone
	// If light is a spotlight <=> lightParameters.y > 0.0
	float colorSpotLight = 1.0;
    if (lightParameters.y > 0.0)
    {
        float cosCurAngle = dot(-dirLightToFragment, normalize(lightDirection.xyz));
        float cosInnerConeAngle = lightParameters.x;
        float cosOuterConeAngle = lightParameters.y;
        float cosInnerMinusOuterAngle = cosInnerConeAngle - cosOuterConeAngle;
        colorSpotLight *= clamp((cosCurAngle - cosOuterConeAngle)/cosInnerMinusOuterAngle, 0.0, 1.0);
    
		// Shadow
		if(bCastShadows > 0.0)
		{
			float depth = 0.001*length(lightPositionWorldSpace.xyz - outVertex.xyz);
			float f = shadowPCF(shadowMap, positionShadowLightSpace, u_invShadowMapSize.xy, depth);		
			colorSpotLight *= f;
		}
	}
	
	colorDiffuse = colorDiffuse * vec3(colorSpotLight * (1.0-u_reflectivity));
	return colorDiffuse;
}

void main()
{
    vec3 colorLight = vec3(0.0);
	vec3 colorSpecular = vec3(0.0);
	float colorShadow = 1.0;
	
	float fAlpha = u_transparency.x;
	
	if (u_hasDiffuseTexture != 0 && u_transparency.x > 0.0)
    {
        fAlpha *= texture2D(u_diffuse, u_uvScale*vec2(outUV.x, 1.0 - outUV.y)).a;
    }
	
	if (u_hasDecalTexture != 0)
    {
       float fDecalAlpha = texture2D(u_decal, u_uvScale*vec2(outUV.x, 1.0 - outUV.y)).a;
	   fAlpha = clamp(fAlpha + fDecalAlpha * u_transparency.y, 0.0, 1.0);
    }

	colorLight.rgb += 
		ComputeLight(
			u_lightPositionWorldSpace0,
			u_lightParameters0,
			u_lightDirection0.xyz,
			u_lightDiffuseColor0.rgb,
			u_lightSpecularColor0.rgb,
			u_lightAttenuation0,
			u_shadowMap0,
			u_castShadows0,
			outPositionShadowLightSpace,
			colorSpecular,
			colorShadow);
			
	
	colorLight = colorLight + colorSpecular;
	finalColor = vec4(colorLight * colorShadow * fAlpha, 0.0);
}