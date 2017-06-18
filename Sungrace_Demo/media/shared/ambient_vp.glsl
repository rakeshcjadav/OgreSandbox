#version 150

uniform mat4 matWorldViewProj;
in vec4 vertex;

/*
  Basic ambient lighting vertex program
*/
void main()
{
	gl_Position = matWorldViewProj * vertex;
}


