#pragma include("SpecularMaterial.xsh")
#pragma include("Color.xsh")
#pragma include("RGBM.xsh")
#pragma include("ShadowMap.xsh")
#pragma include("DoDirectionalLightPS.xsh")
#pragma include("DoPointLightPS.xsh")
// #pragma include("Fog.xsh")
#pragma include("Exposure.xsh")
#pragma include("GammaCorrect.xsh")

void DefaultShader(Material material, float depth)
{
	vec3 N = material.Normal;
#if defined(X_2D)
	vec3 lightDiffuse = vec3(0.0);
#else
	vec3 lightDiffuse = v_vLight;
#endif
	vec3 lightSpecular = vec3(0.0);

	// Ambient light
	vec3 ambientUp = xGammaToLinear(bbmod_LightAmbientUp.rgb) * bbmod_LightAmbientUp.a;
	vec3 ambientDown = xGammaToLinear(bbmod_LightAmbientDown.rgb) * bbmod_LightAmbientDown.a;
	lightDiffuse += mix(ambientDown, ambientUp, N.z * 0.5 + 0.5);
	// Shadow mapping
	float shadow = 0.0;
#if !defined(X_2D)
	if (bbmod_ShadowmapEnablePS == 1.0)
	{
		shadow = ShadowMap(bbmod_Shadowmap, bbmod_ShadowmapTexel, v_vPosShadowmap.xy, v_vPosShadowmap.z);
	}
#endif

#if defined(X_2D)
	vec3 V = vec3(0.0, 0.0, 1.0);
#else
	vec3 V = normalize(bbmod_CamPos - v_vVertex);
#endif
	// Directional lights
	for (int i = 0; i < MAX_DIRECTIONAL_LIGHTS; ++i)
	{
		vec3 dir = normalize(u_vLightDirectionalData[i * 2].xyz);
		vec4 colorAlpha = u_vLightDirectionalData[(i * 2) + 1];
		vec3 color = xGammaToLinear(colorAlpha.rgb) * colorAlpha.a;
		DoDirectionalLightPS(
			dir,
			color * (1.0 - shadow),
			v_vVertex, N, V, material, lightDiffuse, lightSpecular);
	}
#if defined(X_2D)
	// Point lights
	for (int i = 0; i < MAX_POINT_LIGHTS; ++i)
	{
		vec4 positionRange = bbmod_LightPointData[i * 2];
		vec4 colorAlpha = bbmod_LightPointData[(i * 2) + 1];
		vec3 color = xGammaToLinear(colorAlpha.rgb) * colorAlpha.a;
		DoPointLightPS(positionRange.xyz, positionRange.w, color, v_vVertex, N, V,
			material, lightDiffuse, lightSpecular);
	}
#endif // X_2D
	// Diffuse
	gl_FragColor.rgb = material.Base * lightDiffuse;
	// Specular
	// gl_FragColor.rgb += lightSpecular;
	// Emissive
	gl_FragColor.rgb += material.Emissive;
	// Opacity
	gl_FragColor.a = material.Opacity;
	// // Fog
	// Fog(depth);

	Exposure();
	GammaCorrect();

	if (u_fHighlightMaterial > -1.0
		&& u_vHighlightInstance == bbmod_InstanceID
		&& u_fHighlightMaterial != bbmod_MaterialIndex)
	{
		gl_FragColor.rgb = mix(gl_FragColor.rgb, u_vHighlightColor.rgb,
			/*(sin(u_fTime * 0.005) * 0.5 + 0.5) **/ u_vHighlightColor.a);
	}
}
