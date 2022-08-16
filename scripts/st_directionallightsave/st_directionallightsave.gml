/// @func ST_DirectionalLightSave([_directionalLight])
///
/// @desc
///
/// @param {Struct.BBMOD_DirectionalLight} [_directionalLight]
function ST_DirectionalLightSave(_directionalLight=undefined) constructor
{
	/// @var {Bool}
	Enabled = false;

	/// @var {Struct.BBMOD_Vec3}
	Direction = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Color}
	Color = BBMOD_C_WHITE;

	if (_directionalLight)
	{
		FromDirectionalLight(_directionalLight);
	}

	/// @func FromDirectionalLight(_directionalLight)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_DirectionalLight} _directionalLight
	///
	/// @return {Struct.ST_DirectionalLightSave} Returns `self`.
	static FromDirectionalLight = function (_directionalLight) {
		Enabled = _directionalLight.Enabled;
		_directionalLight.Direction.Copy(Direction);
		_directionalLight.Color.Copy(Color);
		return self;
	};
}
