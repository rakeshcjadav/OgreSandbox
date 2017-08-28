uniform mat4 u_worldViewMatrix;

void main()
{
    gl_Position = gl_ProjectionMatrix * (u_worldViewMatrix * gl_Vertex); 
}
