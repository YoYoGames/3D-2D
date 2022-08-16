// FIXME: Temporary fix!
precision highp float;

////////////////////////////////////////////////////////////////////////////////
//
// Attributes
//
attribute vec4 in_Position;
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord0;
attribute vec4 in_TangentW;

////////////////////////////////////////////////////////////////////////////////
//
// Main
//
void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * in_Position;
}
