#version 150

uniform vec4 ambient;

out vec4 oColor;

/*
  Basic ambient lighting fragment program for GLSL ES
*/
void main()
{
	oColor = ambient;
}
