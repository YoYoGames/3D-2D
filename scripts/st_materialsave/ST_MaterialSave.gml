/// @func ST_MaterialSave([_asset, _materialIndex])
///
/// @desc
///
/// @param {Struct.ST_Asset} [_asset]
/// @param {Real} [_materialIndex]
function ST_MaterialSave(_asset=undefined, _materialIndex=0) constructor
{
	/// @var {String, Undefined}
	Texture = undefined;

	/// @var {Struct.BBMOD_Color}
	Color = BBMOD_C_WHITE;

	if (_asset)
	{
		FromAssetMaterial(_asset, _materialIndex);
	}

	/// @func MakePathsRelative(_root)
	///
	/// @desc
	///
	/// @param {String} _root
	///
	/// @return {Struct.ST_MaterialSave} Returns `self`.
	static MakePathsRelative = function (_root) {
		if (Texture != undefined)
		{
			Texture = ST_PathGetRelative(Texture, _root);
		}
		return self;
	};

	/// @func FromAssetMaterial(_asset, _materialIndex)
	///
	/// @desc
	///
	/// @param {Struct.ST_Asset} _asset
	/// @param {Real} _materialIndex
	///
	/// @return {Struct.ST_MaterialSave} Returns `self`.
	static FromAssetMaterial = function (_asset, _materialIndex) {
		Texture = _asset.MaterialSprites[_materialIndex];
		_asset.Materials[_materialIndex].BaseOpacityMultiplier.Copy(Color);
		return self;
	};
}
