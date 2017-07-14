#version 150

uniform vec4 lightAmbient;
uniform vec4 ambient;
uniform float alpha;

out vec4 oColor;

/*
  Basic ambient lighting fragment program for GLSL ES
*/
void main()
{
	oColor = vec4(lightAmbient.rgb * ambient.rgb, alpha);
}
