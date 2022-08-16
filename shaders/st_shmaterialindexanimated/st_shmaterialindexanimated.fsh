// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
//
// Uniforms
//
uniform float u_fMaterialIndex;

////////////////////////////////////////////////////////////////////////////////
//
// Varyings
//
varying vec3 v_vVertex;

varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;

////////////////////////////////////////////////////////////////////////////////
//
// Main
//
void main()
{
	gl_FragColor = vec4(u_fMaterialIndex, 0.0, 0.0, 1.0);
}
