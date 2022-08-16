/// @func ST_AssetSave([_asset])
///
/// @desc
///
/// @param {Struct.ST_Asset} [_asset]
function ST_AssetSave(_asset=undefined) constructor
{
	/// @var {String}
	Path = "";

	/// @var {String}
	Name = "";

	/// @var {String, Undefined}
	AttachedTo = undefined;

	/// @var {Struct.BBMOD_Vec3}
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3}
	Rotation = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3}
	Scale = new BBMOD_Vec3(1.0);

	/// @var {Bool}
	FlipUVHorizontally = false;

	/// @var {Bool}
	FlipUVVertically = false;

	/// @var {Array<Struct.ST_MaterialSave>}
	Materials = [];

	/// @var {Real}
	AnimationFramerate = 30;

	/// @var {Array<Array<Bool>>}
	AnimationFrameFilters = [];

	/// @var {Array<Struct.ST_AssetSave>}
	Attachments = [];

	if (_asset)
	{
		FromAsset(_asset);
	}

	/// @func MakePathsRelative(_root)
	///
	/// @desc
	///
	/// @param {String} _root
	///
	/// @return {Struct.ST_AssetSave} Returns `self`.
	static MakePathsRelative = function (_root) {
		Path = ST_PathGetRelative(Path, _root);

		for (var i = array_length(Materials) - 1; i >= 0; --i)
		{
			Materials[i].MakePathsRelative(_root);
		}

		for (var i = array_length(Attachments) - 1; i >= 0; --i)
		{
			Attachments[i].MakePathsRelative(_root);
		}

		return self;
	};

	/// @func FromAsset(_asset)
	///
	/// @desc
	///
	/// @param {Struct.ST_Asset} _asset
	///
	/// @return {Struct.ST_AssetSave} Returns `self`.
	static FromAsset = function (_asset) {
		Path = _asset.Path;
		Name = _asset.Name;
		AttachedTo = _asset.AttachedToBone
			? _asset.AttachedTo.Model.find_node(_asset.AttachedToBone).Name
			: undefined;
		_asset.Position.Copy(Position);
		_asset.Rotation.Copy(Rotation);
		_asset.Scale.Copy(Scale);
		FlipUVHorizontally = _asset.FlipUVHorizontally;
		FlipUVVertically = _asset.FlipUVVertically;

		Materials = [];
		var _materialsLength = array_length(_asset.Materials);
		for (var i = 0; i < _materialsLength; ++i)
		{
			array_push(Materials, new ST_MaterialSave(_asset, i));
		}

		AnimationFramerate = _asset.SamplingRate;
	
		var _frameFiltersLength = array_length(_asset.FrameFilters);
		AnimationFrameFilters = array_create(_frameFiltersLength);
		for (var i = 0; i < _frameFiltersLength; ++i)
		{
			var _frameFilterCurrent = _asset.FrameFilters[i];
			var _frameFilterCurrentLength = array_length(_frameFilterCurrent);
			AnimationFrameFilters[@ i] = array_create(_frameFilterCurrentLength);
			array_copy(AnimationFrameFilters[i], 0,
				_frameFilterCurrent, 0, _frameFilterCurrentLength);
		}

		var _attachmentsLength = array_length(_asset.Attachments);
		Attachments = [];
		for (var i = 0; i < _attachmentsLength; ++i)
		{
			array_push(Attachments, new ST_AssetSave(_asset.Attachments[i]));
		}

		return self;
	};
}
