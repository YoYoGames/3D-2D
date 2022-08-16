/// @func ST_GetDefaultMaterial()
///
/// @desc
///
/// @return {Struct.BBMOD_DefaultMaterial}
function ST_GetDefaultMaterial()
{
	static _material = undefined;
	if (!_material)
	{
		var _shader = new ST_DefaultShader(ST_ShDefault, BBMOD_VFORMAT_DEFAULT);
		_material = new BBMOD_DefaultMaterial(_shader);
		_material.set_shader(BBMOD_ERenderPass.Id, BBMOD_SHADER_INSTANCE_ID);
		_material.Culling = cull_noculling;
	}
	return _material;
}

/// @func ST_GetDefaultMaterialAnimated()
///
/// @desc
///
/// @return {Struct.BBMOD_DefaultMaterial}
function ST_GetDefaultMaterialAnimated()
{
	static _material = undefined;
	if (!_material)
	{
		var _shader = new ST_DefaultShader(ST_ShDefaultAnimated, BBMOD_VFORMAT_DEFAULT_ANIMATED);
		_material = ST_GetDefaultMaterial().clone();
		_material.set_shader(BBMOD_ERenderPass.Forward, _shader);
		_material.set_shader(BBMOD_ERenderPass.Id, BBMOD_SHADER_INSTANCE_ID_ANIMATED);
	}
	return _material;
}
