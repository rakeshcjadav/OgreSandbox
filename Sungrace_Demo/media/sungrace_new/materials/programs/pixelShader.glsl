uniform float u_numLights;

uniform float u_castShadows0;
uniform float u_castShadows1;
uniform float u_castShadows2;
uniform float u_castShadows3;

uniform sampler2D u_shadowMap0;
uniform sampler2D u_shadowMap1;
uniform sampler2D u_shadowMap2;
uniform sampler2D u_shadowMap3;

uniform vec4 u_lightParameters0;
uniform vec4 u_lightParameters1;
uniform vec4 u_lightParameters2;
uniform vec4 u_lightParameters3;
uniform vec4 u_lightPositionWorldSpace0;
uniform vec4 u_lightPositionWorldSpace1;
uniform vec4 u_lightPositionWorldSpace2;
uniform vec4 u_lightPositionWorldSpace3;
uniform vec4 u_lightDirection0;
uniform vec4 u_lightDirection1;
uniform vec4 u_lightDirection2;
uniform vec4 u_lightDirection3;
uniform vec4 u_lightDiffuseColor0;
uniform vec4 u_lightDiffuseColor1;
uniform vec4 u_lightDiffuseColor2;
uniform vec4 u_lightDiffuseColor3;
uniform vec4 u_lightSpecularColor0;
uniform vec4 u_lightSpecularColor1;
uniform vec4 u_lightSpecularColor2;
uniform vec4 u_lightSpecularColor3;
uniform vec4 u_lightAttenuation0;
uniform vec4 u_lightAttenuation1;
uniform vec4 u_lightAttenuation2;
uniform vec4 u_lightAttenuation3;

uniform vec4 u_invShadowMapSize;
uniform vec3 u_eyePositionWorldSpace;

// The vertex position in the light space for every 
// shadow casting light.
varying vec4 v_positionShadowLightSpace[4];

varying vec2 texCoord;
varying vec3 v_normalWorldSpace;
varying vec3 v_positionWorldSpace;
varying vec4 vertexColor;

// Diffuse texture.
uniform int mHasDiffuseTexture;
uniform sampler2D mTexture0;

// Decal texture.
uniform int mHasDecalTexture;
uniform sampler2D mDecalTexture0;

// .x = transparency for object.
// .y = transparency for pattern.
uniform vec2 u_transparency;

uniform int u_isTransparent;
uniform int u_enableLighting;

uniform vec4 u_specular_exponent;
uniform float u_reflectivity;



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
    in vec3 lightPositionWorldSpace,
    in vec4 lightParameters,
    in vec3 lightDirection,
    in vec3 lightDiffuseColor,
    in vec3 lightSpecularColor,
    in vec4 lightAttenuation,
    sampler2D shadowMap,
    in vec4 positionShadowLightSpace,
    vec3 diffuseColor)
{
    vec3 normal = normalize(v_normalWorldSpace);

    // Basic lighting.
    vec3 pointToLight = normalize(lightPositionWorldSpace - v_positionWorldSpace.xyz);

    // Specular
    vec3 pointToEye = normalize(u_eyePositionWorldSpace - v_positionWorldSpace.xyz);
    vec3 halfV = normalize(pointToLight + pointToEye);
    float NdotHV = max(dot(normal, halfV), 0.0);

    vec3 specular = pow(NdotHV, u_specular_exponent.a)*u_specular_exponent.rgb*lightSpecularColor;

    // Diffuse
    float tu = max(0.0, dot(pointToLight, normal));
    vec3 diffuse = (0.5 + 0.5*tu)*diffuseColor*lightDiffuseColor;

    // Shadow
    float depth = 0.001 * length(lightPositionWorldSpace - v_positionWorldSpace.xyz);
    float maskCoefficient = tu*shadowPCF(shadowMap, positionShadowLightSpace, u_invShadowMapSize.xy, depth);

    // This only works if light is a spotlight,
    // i.e. if u_lightParameters.y > 0.0
    float cosCurAngle = dot(-pointToLight, normalize(lightDirection));
    float cosInnerConeAngle = lightParameters.x;
    float cosOuterConeAngle = lightParameters.y;
    float cosInnerMinusOuterAngle = cosInnerConeAngle - cosOuterConeAngle;
    maskCoefficient *= clamp((cosCurAngle - cosOuterConeAngle)/cosInnerMinusOuterAngle, 0.0, 1.0);

    return maskCoefficient*(specular + (1.0 - u_reflectivity)*diffuse);
}


vec3 ComputeOptionalLight(
    in vec4 lightPositionWorldSpace,
    in vec4 lightParameters,
    in vec3 lightDirection,
    in vec3 lightDiffuseColor,
    in vec3 lightSpecularColor,
    in vec4 lightAttenuation,
    vec3 diffuseColor)
{
    vec3 normal = normalize(v_normalWorldSpace);

    // Basic lighting.

    // Directional lights w = 0 
    // spotlights/pointlights w != 0
    vec3 dir = 
        (lightPositionWorldSpace.w != 0.0) ?
        normalize(v_positionWorldSpace.xyz - lightPositionWorldSpace.xyz) :
        normalize(lightDirection) ;

    // Specular
    vec3 pointToEye = normalize(u_eyePositionWorldSpace - v_positionWorldSpace.xyz);

    vec3 halfV = normalize(-dir + pointToEye);
    float NdotHV = max(dot(normal, halfV), 0.0);
    vec3 specular = pow(NdotHV, u_specular_exponent.a)*u_specular_exponent.rgb*lightSpecularColor.rgb;

    // Diffuse
    float tu = max(0.0, dot(-dir, normal));
    vec3 diffuse = (0.5 + 0.5*tu)*diffuseColor*lightDiffuseColor;

    float maskCoefficient = 1.0;

    // If light is a spotlight <=> u_lightParameters.y > 0.0
    if (lightParameters.y > 0.0)
    {
        float cosCurAngle = dot(dir, normalize(lightDirection));
        float cosInnerConeAngle = lightParameters.x;
        float cosOuterConeAngle = lightParameters.y;
        float cosInnerMinusOuterAngle = cosInnerConeAngle - cosOuterConeAngle;
        maskCoefficient *= clamp((cosCurAngle - cosOuterConeAngle)/cosInnerMinusOuterAngle, 0.0, 1.0);
    }

    // Consider attenuation only for spotlights and pointlights.
    if (lightPositionWorldSpace.w != 0.0)
    {
        float r = length(v_positionWorldSpace.xyz - lightPositionWorldSpace.xyz);
        r = clamp(r/lightAttenuation.x, 0.0, 1.0);
        maskCoefficient *= 1.0 - r;
    }

    return maskCoefficient*(specular + (1.0 - u_reflectivity)*diffuse);
}



void main()
{
    vec4 diffuse = vertexColor;
    diffuse.a = u_transparency.x;
    if (mHasDiffuseTexture != 0)
    {
        vec4 diffuseTexture = texture2D(mTexture0, texCoord);
        diffuse = mix(diffuse, diffuseTexture, diffuseTexture.a*u_transparency.y);
    }

    if (mHasDecalTexture != 0)
    {
        vec4 decal = texture2D(mDecalTexture0, texCoord);
        if (decal != vec4(0.0, 0.0, 0.0, 0.0))
        {
            diffuse = mix(diffuse, decal, u_transparency.y);
        }
    }
    if ((u_isTransparent != 0) && (diffuse.a < 0.1))
        discard;

    // Lights.
    gl_FragColor = vec4(0.0, 0.0, 0.0, diffuse.a);

    // Light #0
    if (u_numLights < 0.5)
        return;
    gl_FragColor.rgb += u_castShadows0 > 0.0 ?
        ComputeLight(
            u_lightPositionWorldSpace0.xyz,
            u_lightParameters0,
            u_lightDirection0.xyz,
            u_lightDiffuseColor0.rgb,
            u_lightSpecularColor0.rgb,
            u_lightAttenuation0,
            u_shadowMap0,
            v_positionShadowLightSpace[0],
            diffuse.rgb) :
        ComputeOptionalLight(
            u_lightPositionWorldSpace0,
            u_lightParameters0,
            u_lightDirection0.xyz,
            u_lightDiffuseColor0.rgb,
            u_lightSpecularColor0.rgb,
            u_lightAttenuation0,
            diffuse.rgb) ;

    // Light #1
    if (u_numLights < 1.5)
        return;
    gl_FragColor.rgb += u_castShadows1 > 0.0 ?
        ComputeLight(
            u_lightPositionWorldSpace1.xyz,
            u_lightParameters1,
            u_lightDirection1.xyz,
            u_lightDiffuseColor1.rgb,
            u_lightSpecularColor1.rgb,
            u_lightAttenuation1,
            u_shadowMap1,
            v_positionShadowLightSpace[1],
            diffuse.rgb) :
        ComputeOptionalLight(
            u_lightPositionWorldSpace1,
            u_lightParameters1,
            u_lightDirection1.xyz,
            u_lightDiffuseColor1.rgb,
            u_lightSpecularColor1.rgb,
            u_lightAttenuation1,
            diffuse.rgb) ;

    // Light #2
    if (u_numLights < 2.5)
        return;
    gl_FragColor.rgb += u_castShadows2 > 0.0 ?
        ComputeLight(
            u_lightPositionWorldSpace2.xyz,
            u_lightParameters2,
            u_lightDirection2.xyz,
            u_lightDiffuseColor2.rgb,
            u_lightSpecularColor2.rgb,
            u_lightAttenuation2,
            u_shadowMap2,
            v_positionShadowLightSpace[2],
            diffuse.rgb) :
        ComputeOptionalLight(
            u_lightPositionWorldSpace2,
            u_lightParameters2,
            u_lightDirection2.xyz,
            u_lightDiffuseColor2.rgb,
            u_lightSpecularColor2.rgb,
            u_lightAttenuation2,
            diffuse.rgb) ;

    // Light #3
    if (u_numLights < 3.5)
        return;
    gl_FragColor.rgb += u_castShadows3 > 0.0 ?
        ComputeLight(
            u_lightPositionWorldSpace3.xyz,
            u_lightParameters3,
            u_lightDirection3.xyz,
            u_lightDiffuseColor3.rgb,
            u_lightSpecularColor3.rgb,
            u_lightAttenuation3,
            u_shadowMap3,
            v_positionShadowLightSpace[3],
            diffuse.rgb) :
        ComputeOptionalLight(
            u_lightPositionWorldSpace3,
            u_lightParameters3,
            u_lightDirection3.xyz,
            u_lightDiffuseColor3.rgb,
            u_lightSpecularColor3.rgb,
            u_lightAttenuation3,
            diffuse.rgb) ;
}
