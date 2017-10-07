#version 330

uniform float u_numLights;

uniform float u_castShadows0;
uniform float u_castShadows1;
uniform float u_castShadows2;
uniform float u_castShadows3;
uniform float u_castShadows4;
uniform float u_castShadows5;
uniform float u_castShadows6;
uniform float u_castShadows7;

uniform sampler2D u_shadowMap0;
uniform sampler2D u_shadowMap1;
uniform sampler2D u_shadowMap2;
uniform sampler2D u_shadowMap3;
uniform sampler2D u_shadowMap4;
uniform sampler2D u_shadowMap5;
uniform sampler2D u_shadowMap6;
uniform sampler2D u_shadowMap7;

// .xyz = the specular color, .w = the specular exponent.
uniform vec4 u_specular_exponent;

// the alpha blend factor.
uniform float u_alphaBlendFactor;

// environment mapping.
uniform float u_reflectivity;

uniform vec4 u_lightParameters0;
uniform vec4 u_lightParameters1;
uniform vec4 u_lightParameters2;
uniform vec4 u_lightParameters3;
uniform vec4 u_lightParameters4;
uniform vec4 u_lightParameters5;
uniform vec4 u_lightParameters6;
uniform vec4 u_lightParameters7;
uniform vec4 u_lightPositionWorldSpace0;
uniform vec4 u_lightPositionWorldSpace1;
uniform vec4 u_lightPositionWorldSpace2;
uniform vec4 u_lightPositionWorldSpace3;
uniform vec4 u_lightPositionWorldSpace4;
uniform vec4 u_lightPositionWorldSpace5;
uniform vec4 u_lightPositionWorldSpace6;
uniform vec4 u_lightPositionWorldSpace7;
uniform vec4 u_lightDirection0;
uniform vec4 u_lightDirection1;
uniform vec4 u_lightDirection2;
uniform vec4 u_lightDirection3;
uniform vec4 u_lightDirection4;
uniform vec4 u_lightDirection5;
uniform vec4 u_lightDirection6;
uniform vec4 u_lightDirection7;
uniform vec4 u_lightDiffuseColor0;
uniform vec4 u_lightDiffuseColor1;
uniform vec4 u_lightDiffuseColor2;
uniform vec4 u_lightDiffuseColor3;
uniform vec4 u_lightDiffuseColor4;
uniform vec4 u_lightDiffuseColor5;
uniform vec4 u_lightDiffuseColor6;
uniform vec4 u_lightDiffuseColor7;
uniform vec4 u_lightSpecularColor0;
uniform vec4 u_lightSpecularColor1;
uniform vec4 u_lightSpecularColor2;
uniform vec4 u_lightSpecularColor3;
uniform vec4 u_lightSpecularColor4;
uniform vec4 u_lightSpecularColor5;
uniform vec4 u_lightSpecularColor6;
uniform vec4 u_lightSpecularColor7;
uniform vec4 u_lightAttenuation0;
uniform vec4 u_lightAttenuation1;
uniform vec4 u_lightAttenuation2;
uniform vec4 u_lightAttenuation3;
uniform vec4 u_lightAttenuation4;
uniform vec4 u_lightAttenuation5;
uniform vec4 u_lightAttenuation6;
uniform vec4 u_lightAttenuation7;

uniform vec4 u_invShadowMapSize;
uniform vec3 u_eyePositionWorldSpace;

uniform sampler2D u_diffuse;

// Input from Fragment shader
in vec4 outVertex;
in vec3 outNormal;
in vec2 outUV;
in vec4 outCameraPosition;

// The vertex position in the light space for every 
// shadow casting light.
in vec4 outPositionShadowLightSpace[8];

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
	
	colorDiffuse = colorDiffuse * vec3(colorSpotLight * u_alphaBlendFactor * (1.0-u_reflectivity));
	return colorDiffuse;
}

void main()
{
    vec3 colorLight = vec3(0.0);
	vec3 colorSpecular = vec3(0.0);
	float colorShadow = 1.0;

    // Light #0
    if (u_numLights > 0.5)
    {
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
                outPositionShadowLightSpace[0],
				colorSpecular,
				colorShadow);
    }

    // Light #1
    if (u_numLights > 1.5)
    {
        colorLight += 
            ComputeLight(
                u_lightPositionWorldSpace1,
                u_lightParameters1,
                u_lightDirection1.xyz,
                u_lightDiffuseColor1.rgb,
                u_lightSpecularColor1.rgb,
                u_lightAttenuation1,
                u_shadowMap1,
				u_castShadows1,
                outPositionShadowLightSpace[1],
				colorSpecular,
				colorShadow);
    }

    // Light #2
    if (u_numLights > 2.5)
    {
        colorLight += 
            ComputeLight(
                u_lightPositionWorldSpace2,
                u_lightParameters2,
                u_lightDirection2.xyz,
                u_lightDiffuseColor2.rgb,
                u_lightSpecularColor2.rgb,
                u_lightAttenuation2,
                u_shadowMap2,
				u_castShadows2,
                outPositionShadowLightSpace[2],
				colorSpecular,
				colorShadow);
    }

    // Light #3
    if (u_numLights > 3.5)
    {
        colorLight +=
            ComputeLight(
                u_lightPositionWorldSpace3,
                u_lightParameters3,
                u_lightDirection3.xyz,
                u_lightDiffuseColor3.rgb,
                u_lightSpecularColor3.rgb,
                u_lightAttenuation3,
                u_shadowMap3,
				u_castShadows3,
                outPositionShadowLightSpace[3],
				colorSpecular,
				colorShadow);
    }
	
	// Light #4
    if (u_numLights > 4.5)
    {
        colorLight.rgb += 
            ComputeLight(
                u_lightPositionWorldSpace4,
                u_lightParameters4,
                u_lightDirection4.xyz,
                u_lightDiffuseColor4.rgb,
                u_lightSpecularColor4.rgb,
                u_lightAttenuation4,
                u_shadowMap4,
				u_castShadows4,
                outPositionShadowLightSpace[4],
				colorSpecular,
				colorShadow);
    }

    // Light #5
    if (u_numLights > 5.5)
    {
        colorLight += 
            ComputeLight(
                u_lightPositionWorldSpace5,
                u_lightParameters5,
                u_lightDirection5.xyz,
                u_lightDiffuseColor5.rgb,
                u_lightSpecularColor5.rgb,
                u_lightAttenuation5,
                u_shadowMap5,
				u_castShadows5,
                outPositionShadowLightSpace[5],
				colorSpecular,
				colorShadow);
    }

    // Light #6
    if (u_numLights > 6.5)
    {
        colorLight += 
            ComputeLight(
                u_lightPositionWorldSpace6,
                u_lightParameters6,
                u_lightDirection6.xyz,
                u_lightDiffuseColor6.rgb,
                u_lightSpecularColor6.rgb,
                u_lightAttenuation6,
                u_shadowMap6,
				u_castShadows6,
                outPositionShadowLightSpace[6],
				colorSpecular,
				colorShadow);
    }

    // Light #7
    if (u_numLights > 7.5)
    {
        colorLight +=
            ComputeLight(
                u_lightPositionWorldSpace7,
                u_lightParameters7,
                u_lightDirection7.xyz,
                u_lightDiffuseColor7.rgb,
                u_lightSpecularColor7.rgb,
                u_lightAttenuation7,
                u_shadowMap7,
				u_castShadows7,
                outPositionShadowLightSpace[7],
				colorSpecular,
				colorShadow);
    }
	
	colorLight = colorLight + colorSpecular;
	finalColor = vec4(colorLight * colorShadow, 0.0);
}