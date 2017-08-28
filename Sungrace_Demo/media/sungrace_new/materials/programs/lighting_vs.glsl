uniform mat4 mWorldViewMat;
uniform mat4 mWorldMatrix;

// Light data
uniform mat4 u_texViewProjMatrix0;
uniform mat4 u_texViewProjMatrix1;
uniform mat4 u_texViewProjMatrix2;
uniform mat4 u_texViewProjMatrix3;

// Varying per light.
varying vec4 v_positionShadowLightSpace[4];

attribute vec4 colour;

varying vec2 texCoord;
varying vec3 v_positionWorldSpace;
varying vec3 v_normalWorldSpace;
varying vec4 vertexColor;

void main()
{
    vertexColor = colour;

    v_normalWorldSpace = (mWorldMatrix*vec4(gl_Normal.xyz, 0.0)).xyz;

    v_positionWorldSpace = (mWorldMatrix*gl_Vertex).xyz;

    texCoord = vec2(gl_MultiTexCoord0.x, 1.0 - gl_MultiTexCoord0.y);

    gl_Position = gl_ProjectionMatrix * (mWorldViewMat * gl_Vertex); 
    
    // Calculate the position of vertex in light space for shadowing.
    v_positionShadowLightSpace[0] = u_texViewProjMatrix0 * vec4(v_positionWorldSpace, 1.0);
    v_positionShadowLightSpace[1] = u_texViewProjMatrix1 * vec4(v_positionWorldSpace, 1.0);
    v_positionShadowLightSpace[2] = u_texViewProjMatrix2 * vec4(v_positionWorldSpace, 1.0);
    v_positionShadowLightSpace[3] = u_texViewProjMatrix3 * vec4(v_positionWorldSpace, 1.0);
}
