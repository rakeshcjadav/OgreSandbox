
varying vec2 v_texCoord;
varying vec3 v_normalWorldSpace;
varying vec3 v_positionWorldSpace;

// Diffuse texture.
uniform sampler2D mTexture0;

// .x = transparency for object.
// .y = transparency for pattern.
uniform float u_transparency;

uniform vec3 objColor;

void main()
{
	vec4 diffuse = texture2D(mTexture0, mod(0.005*v_texCoord.xy, 1.0));
	
    vec3 normal = normalize(v_normalWorldSpace);

    float l1 = max(0.0, dot(normal, normalize(vec3(5.4, 2.0, 5.0))));
    float l2 = max(0.0, dot(normal, normalize(vec3(-4.5, 2.0, 5.4))));
    float l3 = max(0.0, dot(normal, normalize(vec3(5.2, 2.0, -3.2))));
    float l4 = max(0.0, dot(normal, normalize(vec3(-4.2, 2.0, -5.2))));

	vec3 cl = 
		l1*vec3(1.01, 1.02, 1.03)*diffuse.rgb +
		l2*vec3(1.02, 1.01, 1.03)*diffuse.rgb +
		l3*vec3(1.03, 1.0, 1.01)*diffuse.rgb +
		l4*vec3(1.0, 1.03, 1.0)*diffuse.rgb;
    cl *= 0.4;

	diffuse.a = u_transparency.x;
	diffuse.rgb += objColor;
	gl_FragColor = vec4(cl + 0.4*diffuse.rgb, diffuse.a);
}