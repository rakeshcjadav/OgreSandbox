attribute vec4 vertex;
attribute vec3 normal;
attribute vec2 uv0;

uniform mat4 mWorldViewMat;
uniform mat4 mWorldViewProjMat;
uniform mat4 mWorldMatrix;

varying vec2 v_texCoord;
varying vec3 v_positionWorldSpace;
varying vec3 v_normalWorldSpace;



void main()
{
    v_normalWorldSpace = (mWorldMatrix*vec4(normal.xyz, 0.0)).xyz;
    v_positionWorldSpace = (mWorldMatrix*vertex).xyz;
    v_texCoord = uv0;
    gl_Position = gl_ProjectionMatrix*(mWorldViewMat*vertex);
}