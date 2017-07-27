#version 150

uniform vec4 u_OutlineColor;

out vec4 finalColor;

void main()
{
	finalColor = u_OutlineColor;
}
