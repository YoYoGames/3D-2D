/// @func ST_AssetImporter([_tempDir])
///
/// @desc
///
/// @param {String} [_tempDir] Path to the temporary directory. Default value is
/// `<temp_directory>\SpriteTool`.
function ST_AssetImporter(_tempDir=game_save_id + "Temp") constructor
{
	/// @var {Struct.BBMOD_DLL}
	/// @readonly
	Dll = new BBMOD_DLL();

	//FIXME: get these working on macOS
	if (os_type == os_windows) 
	{
		Dll.set_optimize_animations(2);
		Dll.set_optimize_nodes(true);
		Dll.set_optimize_meshes(true);
		Dll.set_optimize_materials(false);
	}

	/// @var {String}
	/// @readonly
	TempDir = _tempDir;

	/// @func Import(_path)
	///
	/// @desc
	///
	/// @param {String} _path Path to the model to import.
	///
	/// @return {Struct}
	///
	/// @throws {Any}
	static Import = function (_path) {
		if (!file_exists(_path))
		{
			throw "File \"" + _path + "\" does not exist!";
		}

		if (directory_exists(TempDir))
		{
			directory_destroy(TempDir);
		}
		directory_create(TempDir);

		// Convert and load model - throws a BBMOD_Exception if fails!
		var _pathModel = TempDir + "/temp.bbmod";
		Dll.set_sampling_rate(30);
		Dll.set_flip_uv_horizontally(false);
		Dll.set_flip_uv_vertically(false);
		Dll.convert(_path, _pathModel);
		var _model = new BBMOD_Model(_pathModel);

		// Get materials
		var _materials = [];
		for (var i = 0; i < array_length(_model.Materials); ++i)
		{
			var _material = (_model.Materials[i] == BBMOD_MATERIAL_DEFAULT_ANIMATED)
				? ST_GetDefaultMaterialAnimated().clone()
				: ST_GetDefaultMaterial().clone();
			array_push(_materials, _material);
		}

		// Load animations
		var _animationNames = [];
		var _animations = [];
		var _fileName = file_find_first(TempDir + "/*.bbanim", 0);
		while (_fileName != "")
		{
			var _animationName = string_delete(_fileName, 1, 5); // Delete "temp_"
			_animationName = string_copy(_animationName, 1, string_length(_animationName) - 7); // Delete ".bbanim"
			array_push(_animationNames, _animationName);
			var _animation = new BBMOD_Animation(TempDir + "/" + _fileName);
			_animation.TransitionIn = 0.0;
			_animation.TransitionOut = 0.0;
			array_push(_animations, _animation);
			_fileName = file_find_next();
		}
		file_find_close();

		var _asset = new ST_Asset(
			_model,
			_materials,
			_animationNames,
			_animations);

		_asset.Path = _path;
		_asset.FlipUVHorizontally = Dll.get_flip_uv_horizontally();
		_asset.FlipUVVertically = Dll.get_flip_uv_vertically();
		_asset.SamplingRate = Dll.get_sampling_rate();

		return _asset;
	};

	/// @func Reload(_asset)
	///
	/// @desc Reloads an already imported Asset.
	///
	/// @param {Struct.ST_Asset} _asset The Asset to reload.
	///
	/// @return {Struct.ST_AssetImporter} Returns `self`.
	static Reload = function (_asset) {
		if (directory_exists(TempDir))
		{
			directory_destroy(TempDir);
		}
		directory_create(TempDir);

		// Convert and load model - throws a BBMOD_Exception if fails!
		var _pathModel = TempDir + "/temp.bbmod";
		Dll.set_disable_bone(!_asset.IsAnimated);
		Dll.set_sampling_rate(_asset.SamplingRate);
		Dll.set_flip_uv_horizontally(_asset.FlipUVHorizontally);
		Dll.set_flip_uv_vertically(_asset.FlipUVVertically);
		Dll.convert(_asset.Path, _pathModel);
		var _model = new BBMOD_Model(_pathModel);

		// Load animations
		var _animationNames = [];
		var _animations = [];
		var _fileName = file_find_first(TempDir + "/*.bbanim", 0);
		while (_fileName != "")
		{
			var _animationName = string_delete(_fileName, 1, 5); // Delete "temp_"
			_animationName = string_copy(_animationName, 1, string_length(_animationName) - 7); // Delete ".bbanim"
			array_push(_animationNames, _animationName);
			var _animation = new BBMOD_Animation(TempDir + "/" + _fileName);
			_animation.TransitionIn = 0.0;
			_animation.TransitionOut = 0.0;
			array_push(_animations, _animation);
			_fileName = file_find_next();
		}
		file_find_close();

		// Replace data
		_asset.Model.destroy();
		_asset.Model = _model;

		if (_asset.IsAnimated)
		{
			for (var i = 0; i < array_length(_asset.Animations); ++i)
			{
				_asset.Animations[i].destroy();
			}
			_asset.Animations = _animations;
			_asset.AnimationNames = _animationNames;
			_asset.AnimationPlayer.Model = _model;
			var _time = _asset.AnimationPlayer.Time;
			_asset.AnimationPlayer.play(_animations[_asset.AnimationIndex]);
			_asset.AnimationPlayer.Time = _time;
		}

		_asset.ResetFrameFilters();
		_asset.FreeAnimationsPreview();

		return self;
	};

	/// @func Destroy()
	///
	/// @desc Frees resources used by the Asset importer from memory.
	///
	/// @return {Undefined}
	static Destroy = function () {
		Dll.destroy();
		return undefined;
	};
}
