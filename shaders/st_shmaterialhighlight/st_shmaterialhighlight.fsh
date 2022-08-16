varying vec2 v_vTexCoord;

uniform vec2 u_vTexel;
uniform vec4 u_vColor;
uniform float u_fMaterialIndex;

float IsMaterial(vec2 uv, float materialIndex)
{
	vec4 sample = texture2D(gm_BaseTexture, uv);
	return (sample.r != materialIndex || sample.a == 0.0) ? 1.0 : 0.0;
}

void main()
{
	float x = IsMaterial(v_vTexCoord + vec2(-1.0, 0.0) * u_vTexel, u_fMaterialIndex)
			//+ IsMaterial(v_vTexCoord + vec2(-2.0, 0.0) * u_vTexel, u_fMaterialIndex)
			- IsMaterial(v_vTexCoord + vec2(+1.0, 0.0) * u_vTexel, u_fMaterialIndex)
			//- IsMaterial(v_vTexCoord + vec2(+2.0, 0.0) * u_vTexel, u_fMaterialIndex)
			;
	float y = IsMaterial(v_vTexCoord + vec2(0.0, -1.0) * u_vTexel, u_fMaterialIndex)
			//+ IsMaterial(v_vTexCoord + vec2(0.0, -2.0) * u_vTexel, u_fMaterialIndex)
			- IsMaterial(v_vTexCoord + vec2(0.0, +1.0) * u_vTexel, u_fMaterialIndex)
			//- IsMaterial(v_vTexCoord + vec2(0.0, +2.0) * u_vTexel, u_fMaterialIndex)
			;
	gl_FragColor = u_vColor;
	gl_FragColor.a *= sqrt((x * x) + (y * y));
}
