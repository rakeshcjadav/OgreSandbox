uniform mat4 mWorldViewMat;

void main()
{
    gl_Position = gl_ProjectionMatrix*(mWorldViewMat*gl_Vertex);
}
