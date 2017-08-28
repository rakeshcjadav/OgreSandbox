
attribute vec4 vertex;
attribute vec3 normal;
attribute vec2 uv0;

uniform mat4 u_worldMatrix;
uniform mat4 u_worldViewMatrix;

// Light data
uniform mat4 u_texViewProjMatrix0;
uniform mat4 u_texViewProjMatrix1;
uniform mat4 u_texViewProjMatrix2;
uniform mat4 u_texViewProjMatrix3;

uniform int u_numShadowLights;

// Varying.
varying vec3 v_normalWorldSpace;
varying vec4 v_positionWorldSpace;
varying vec2 v_uv;

// Varying per light.
varying vec4 v_positionShadowLightSpace[4];


void main()
{
    // get vertex position in world space
    v_positionWorldSpace = u_worldMatrix * vertex;

    // get normal in world space
    v_normalWorldSpace = vec3(u_worldMatrix * vec4(normalize(normal), 0.0));

    // pass the vertex position, transforming it to clip space
    // We must use the exact same way of producing the position vector
    // as in the ambient pass vertex shader.  If we instead do the following:
    //   gl_Position = u_worldViewProjMatrix*vertex;
    // The resulting z-values are slightly off because of rounding errors, and
    // this will result in z-fighting.
    gl_Position = gl_ProjectionMatrix*(u_worldViewMatrix*vertex);
    
    // pass texture co-ords through unchanged
    v_uv = uv0;

    // Calculate the position of vertex in light space for shadowing.
    v_positionShadowLightSpace[0] = u_texViewProjMatrix0 * v_positionWorldSpace;
    v_positionShadowLightSpace[1] = u_texViewProjMatrix1 * v_positionWorldSpace;
    v_positionShadowLightSpace[2] = u_texViewProjMatrix2 * v_positionWorldSpace;
    v_positionShadowLightSpace[3] = u_texViewProjMatrix3 * v_positionWorldSpace;
}

