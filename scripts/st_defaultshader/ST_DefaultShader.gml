/// @var {Bool}
global.stMaterialHighlight = false;

/// @var {Id.Instance}
global.stMaterialHighlightInstance = undefined;

/// @var {Real}
global.stMaterialHighlightIndex = -1;

/// @var {Struct.BBMOD_Color}
global.stMaterialHighlightColor = BBMOD_C_BLACK; //new BBMOD_Color().FromConstant(#1C8395);
global.stMaterialHighlightColor.Alpha = 0.5;

/// @func ST_HighlightAssetMaterial(_asset[, _materialIndex])
///
/// @desc
///
/// @param {Struct.ST_Asset, Undefined} _asset
/// @param {Real} [_materialIndex]
function ST_HighlightAssetMaterial(_asset, _materialIndex=0)
{
	global.stMaterialHighlightInstance = undefined;
	global.stMaterialHighlightIndex = -1;

	if (_asset != undefined)
	{
		with (ST_OAssetParent)
		{
			if (Asset == _asset)
			{
				global.stMaterialHighlightInstance = id;
				break;
			}
		}
		global.stMaterialHighlightIndex = _materialIndex;
	}
}

/// @func ST_DefaultShader(_shader, _vertexFormat)
///
/// @extends BBMOD_DefaultShader
///
/// @desc
///
/// @param {Asset.GMShader} _shader
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat
function ST_DefaultShader(_shader, _vertexFormat)
	: BBMOD_DefaultShader(_shader, _vertexFormat) constructor
{
	static Super_DefaultShader = {
		on_set: on_set,
	};

	MaxDirectionalLights = 8;

	ULightDirectionalData = get_uniform("u_vLightDirectionalData");

	static on_set = function () {
		method(self, Super_DefaultShader.on_set)();
		var _index = 0;
		var _indexMax = MaxDirectionalLights * 8;
		var _directionalLights = array_create(_indexMax, 0);
		if (global.stDirectionalLightsEnabled)
		{
			var _lightCount = min(array_length(global.stDirectionalLights), MaxDirectionalLights);
			for (var i = 0; i < _lightCount && _index < _indexMax; ++i)
			{
				var _light = global.stDirectionalLights[i];
				if (_light.Enabled)
				{
					_light.Direction.ToArray(_directionalLights, _index);
					_directionalLights[_index + 4] = _light.Color.Red / 255.0;
					_directionalLights[_index + 5] = _light.Color.Green / 255.0;
					_directionalLights[_index + 6] = _light.Color.Blue / 255.0;
					_directionalLights[_index + 7] = _light.Color.Alpha;
					_index += 8;
				}
			}
		}
		set_uniform_f_array(ULightDirectionalData, _directionalLights);
	};
}
