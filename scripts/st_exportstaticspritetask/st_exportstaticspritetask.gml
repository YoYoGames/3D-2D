/// @func ST_ExportStaticSpriteTask(_assetRenderer, _asset, _rotation, _path[, _callback])
///
/// @extends ST_Task
///
/// @desc
///
/// @param {Struct.ST_AssetRenderer} _assetRenderer
/// @param {Struct.ST_Asset} _asset
/// @param {Real} _rotation
/// @param {String} _path
/// @param {Function} [_callback]
function ST_ExportStaticSpriteTask(_assetRenderer, _asset, _rotation, _path, _callback=undefined)
	: ST_Task(_callback) constructor
{
	IsBlocking = true;

	/// @var {Struct.ST_AssetRenderer}
	AssetRenderer = _assetRenderer;

	/// @var {Struct.ST_Asset}
	Asset = _asset;

	/// @var {Real}
	Rotation = _rotation;

	/// @var {String}
	Path = _path;

	static Process = function () {
		var _sprite = AssetRenderer.CreateStaticSprite(Asset, Rotation);
		var _savePath = filename_change_ext(Path, string(Rotation) + ".png");
		var _directory = filename_dir(_savePath);
		if (!directory_exists(_directory))
		{
			directory_create(_directory);
		}
		sprite_save(_sprite, 0, _savePath);
		sprite_delete(_sprite);
		IsFinished = true;
		return self;
	};
}
