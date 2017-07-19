#version 150

uniform sampler2D DiffuseMap;

uniform mat4 textureMatrixDiffuse;
uniform float alpha;
uniform float reflection;

in vec4 oVertex;
in vec4 oUV0;

out vec4 oColor;

void main()
{
	vec4 diffuseColor = vec4(1.0);
	vec2 texCoord_Diffuse = (textureMatrixDiffuse * oUV0).st;
	diffuseColor = (texture2D(DiffuseMap, texCoord_Diffuse)).rgba;
	
	oColor = vec4(diffuseColor.rgb, alpha);
}
