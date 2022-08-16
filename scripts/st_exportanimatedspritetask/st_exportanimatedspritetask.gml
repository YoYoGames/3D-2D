/// @func ST_ExportAnimatedSpriteTask(_assetRenderer, _asset, _animationIndex, _rotation, _path[, _callback])
///
/// @extends ST_Task
///
/// @desc
///
/// @param {Struct.ST_AssetRenderer} _assetRenderer
/// @param {Struct.ST_Asset} _asset
/// @param {Real} _animationIndex
/// @param {Real} _rotation
/// @param {String} _path
/// @param {Function} [_callback]
function ST_ExportAnimatedSpriteTask(
	_assetRenderer,
	_asset,
	_animationIndex,
	_rotation,
	_path,
	_callback=undefined
) : ST_Task(_callback) constructor
{
	IsBlocking = true;

	/// @var {Struct.ST_AssetRenderer}
	AssetRenderer = _assetRenderer;

	/// @var {Struct.ST_Asset}
	Asset = _asset;

	/// @var {Real}
	AnimationIndex = _animationIndex;

	/// @var {Real}
	Rotation = _rotation;

	/// @var {String}
	Path = _path;

	/// @var {Real}
	Frame = 0;

	/// @var {Asset.GMSprite}
	Sprite = undefined;

	static Process = function () {
		var _frame = Frame;
		var _sprite = Sprite;
		var _asset = Asset;
		var _animationIndex = AnimationIndex;
		var _animation = _asset.Animations[_animationIndex];
		var _animationDuration = _animation.Duration;

		if (_frame >= _animationDuration)
		{
			sprite_save_strip(_sprite, Path);
			sprite_delete(_sprite);
			IsFinished = true;
			return self;
		}

		//var _sprite = AssetRenderer.CreateAnimatedSprite(Asset, AnimationIndex, Rotation);

		var _direction = Rotation;
		var _frameFilter = _asset.FrameFilters[_animationIndex];

		if (_frameFilter[_frame])
		{
			with (AssetRenderer)
			{
				UpdateCamera();
				Surface = bbmod_surface_check(Surface, Width, Height);
				var _matrix = new BBMOD_Matrix()
					.Scale(Scale, Scale, Scale)
					.RotateEuler(Rotation)
					.Translate(Position)
					.RotateZ(_direction);
				surface_set_target(Surface);
				draw_clear_alpha(BackgroundColor, BackgroundAlpha);
				Camera.apply();
				_asset.DrawAnimationFrame(_animationIndex, _frame, _matrix);
				surface_reset_target();
				if (_sprite == undefined)
				{
					_sprite = sprite_create_from_surface(Surface, 0, 0, Width, Height, false, SmoothEdges, 0, 0);
				}
				else
				{
					sprite_add_from_surface(_sprite, Surface, 0, 0, Width, Height, false, SmoothEdges);
				}
			}

			Sprite = _sprite;
		}

		++Frame;

		return self;
	};
}
