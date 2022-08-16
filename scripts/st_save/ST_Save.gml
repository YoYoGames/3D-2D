/// @var {String, Undefined}
global.stSavePath = undefined;

/// @func ST_Save([_store])
///
/// @desc
///
/// @param {Id.Instance, Struct} [_store]
function ST_Save(_store=undefined) constructor
{
	/// @var {String, Undefined}
	SpriteToolVersion = undefined;

	/// @var {Struct.ST_AssetSave, Undefined}
	Asset = undefined;

	/// @var {Bool}
	AmbientEnabled = false;

	/// @var {Struct.BBMOD_Color}
	AmbientUp = BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Color}
	AmbientDown = BBMOD_C_WHITE;

	/// @var {Bool}
	DirectionalLightsEnabled = false;

	/// @var {Array<Struct.ST_DirectionalLightSave>}
	DirectionalLights = [];

	/// @var {Struct.BBMOD_Vec2}
	CameraDirection = new BBMOD_Vec2();

	/// @var {Struct.BBMOD_Vec3}
	CameraPosition = new BBMOD_Vec3();

	/// @var {Real}
	ExportWidth = 1;

	/// @var {Real}
	ExportHeight = 1;

	/// @var {String}
	ExportCamera = "Custom";

	/// @var {Struct.BBMOD_Vec3}
	ExportPosition = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3}
	ExportRotation = new BBMOD_Vec3();

	/// @var {Real}
	ExportScale = 1.0;

	/// @var {Real}
	ExportNumberOfRotations = 1;

	/// @var {Bool}
	ExportAttachments = true;

	/// @var {Bool}
	ExportAttachmentsOnly = false;

	/// @var {String}
	ExportPath = "";

	if (_store)
	{
		FromStore(_store);
	}

	/// @func MakePathsRelative(_root)
	///
	/// @desc
	///
	/// @param {String} _root
	///
	/// @return {Struct.ST_Save} Returns `self`.
	static MakePathsRelative = function (_root) {
		if (Asset)
		{
			Asset.MakePathsRelative(_root);
		}
		return self;
	};

	/// @func FromStore(_store)
	///
	/// @desc
	///
	/// @param {Id.Instance, Struct} [_store]
	///
	/// @return {Struct.ST_Save} Returns `self`.
	static FromStore = function (_store) {
		SpriteToolVersion = ST_VERSION_STRING;
		Asset = _store.Asset ? new ST_AssetSave(_store.Asset) : undefined;
		AmbientEnabled = _store.AmbientLightEnabled;
		AmbientUp = _store.AmbientLightUp.Clone();
		AmbientDown = _store.AmbientLightDown.Clone();
		DirectionalLightsEnabled = global.stDirectionalLightsEnabled;
		DirectionalLights = [];
		var _directionalLightsCount = array_length(global.stDirectionalLights);
		for (var i = 0; i < _directionalLightsCount; ++i)
		{
			array_push(DirectionalLights, new ST_DirectionalLightSave(global.stDirectionalLights[i]));
		}
		global.stCameraDirection.Copy(CameraDirection);
		global.stCameraPosition.Copy(CameraPosition);
		ExportWidth = _store.AssetRenderer.Width;
		ExportHeight = _store.AssetRenderer.Height;
		// FIXME: Holy smokes WTF are these
		ExportCamera = _store.GUI.ExportOptionsPane.ExportOptions.DropdownCamera.Selected.Value;
		_store.AssetRenderer.Position.Copy(ExportPosition);
		_store.AssetRenderer.Rotation.Copy(ExportRotation);
		ExportScale = _store.AssetRenderer.Scale;
		ExportNumberOfRotations = _store.GUI.ExportOptionsPane.ExportOptions.Rotations;
		ExportAttachments = _store.Asset ? _store.Asset.AreAttachmentsVisible : true;
		ExportAttachmentsOnly = _store.GUI.ExportOptionsPane.ExportOptions.CheckboxAttachmentsOnly.Value;
		ExportPath = _store.GUI.ExportOptionsPane.ExportOptions.InputExportPath.Value;
		return self;
	};

	/// @func ToJSON()
	///
	/// @desc
	///
	/// @return {String}
	static ToJSON = function () {
		gml_pragma("forceinline");
		return json_stringify(self);
	};

	/// @func FromJSON(_string)
	///
	/// @desc
	///
	/// @param {String} _string
	///
	/// @return {Struct.ST_Save} Returns `self`.
	static FromJSON = function (_string) {
		gml_pragma("forceinline");
		var _json = json_parse(_string);
		GUI_StructExtend(self, _json);
		return self;
	};

	/// @func ToFile(_path)
	///
	/// @desc
	///
	/// @param {String} _path
	///
	/// @return {Struct.ST_Save} Returns `self`.
	///
	/// @throws {String} If an error occurs.
	static ToFile = function (_path) {
		var _file = file_text_open_write(_path);
		if (_file == -1)
		{
			throw "Could not open file " + _path + "!";
		}
		file_text_write_string(_file, ToJSON());
		file_text_close(_file);
		return self;
	};

	/// @func FromFile(_path)
	///
	/// @desc
	///
	/// @param {String} _path
	///
	/// @return {Struct.ST_Save} Returns `self`.
	///
	/// @throws {String} If an error occurs.
	static FromFile = function (_path) {
		var _file = file_text_open_read(_path);
		if (_file == -1)
		{
			throw "Could not open file " + _path + "!";
		}
		var _string = "";
		while (!file_text_eof(_file))
		{
			_string += file_text_read_string(_file) + "\n";
			file_text_readln(_file);
		}
		file_text_close(_file);
		FromJSON(_string);
		return self;
	};
}
