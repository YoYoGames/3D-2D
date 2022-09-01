/// @func UpdateWindowCaption()
///
/// @desc
///
/// @return Returns `self`.
UpdateWindowCaption = function () {
	var _caption = "SpriteTool " + ST_VERSION_STRING;
	if (global.stSavePath != undefined)
	{
		_caption = filename_change_ext(filename_name(global.stSavePath), "")
			+ " - " + _caption;
	}
	window_set_caption(_caption);
	return self;
};

/// @func NewProject()
///
/// @desc
///
/// @return Returns `self`.
NewProject = function () {
	global.stSavePath = undefined;
	room_restart();
	return self;
};

/// @func SaveProject(_path)
///
/// @desc
///
/// @param {String} _path
///
/// @return Returns `self`.
SaveProject = function (_path) {
	var _save = new ST_Save(self).MakePathsRelative(_path);
	show_debug_message(_save.ToJSON());
	_save.ToFile(_path);
	global.stSavePath = _path;
	UpdateWindowCaption();
	return self;
};

/// @func LoadProject(_path)
///
/// @desc
///
/// @param {String} _path
///
/// @return Returns `self`.
LoadProject = function (_path) {
	global.stSavePath = _path;
	room_restart();
	return self;
};

/// @func ImportAsset(_path)
///
/// @desc
///
/// @param {String} _path
///
/// @return {Struct.ST_Asset, Undefined}
ImportAsset = function (_path) {
	try
	{
		AssetImporter.Dll.set_disable_bone(false);
		var _asset = AssetImporter.Import(_path);

		if (Asset)
		{
			Asset.Destroy();
		}

		Asset = _asset;

		with (ST_OAssetParent)
		{
			instance_destroy();
		}

		var _i = instance_create_layer(0, 0, "Instances", ST_OAsset);
		_i.Asset = Asset;

		return Asset;
	}
	catch (_exception)
	{
		// TODO: Show error in GUI
		show_message("ERROR: " + string(_exception));
		return undefined;
	}
};

/// @func ImportAttachment(_path)
///
/// @desc
///
/// @param {String} _path
///
/// @return {Struct.ST_Asset, Undefined}
ImportAttachment = function (_path) {
	if (!Asset)
	{
		// TODO: Show error in GUI
		show_message("ERROR: Cannot import an attachment when the main asset is not loaded!");
		return undefined;
	}

	try
	{
		AssetImporter.Dll.set_disable_bone(true);
		var _attachment = AssetImporter.Import(_path);
		Asset.Attach(_attachment);
		var _i = instance_create_layer(0, 0, "Instances", ST_OAttachment);
		_i.Asset = _attachment;
		return _attachment;
	}
	catch (_exception)
	{
		// TODO: Show error in GUI
		show_message("ERROR: " + string(_exception));
		return undefined;
	}
};

/// @func __LoadAssetFromSave(_assetSave, _isAttachment)
///
/// @desc
///
/// @param {Struct.ST_AssetSave} _assetSave
/// @param {Bool} _isAttachment
///
/// @private
__LoadAssetFromSave = function (_assetSave, _isAttachment) {
	var _samplingRate = _assetSave.AnimationFramerate;

	AssetImporter.Dll.set_flip_uv_horizontally(_assetSave.FlipUVHorizontally);
	AssetImporter.Dll.set_flip_uv_vertically(_assetSave.FlipUVVertically);
	AssetImporter.Dll.set_sampling_rate(_samplingRate);

	var _assetPath = ST_PathGetAbsolute(_assetSave.Path, global.stSavePath);

	if (!file_exists(_assetPath))
	{
		show_message("Could not find file \"" + _assetPath + "\"! Please select it again.");
		_assetPath = get_open_filename("", filename_name(_assetPath));
	}

	var _asset = _isAttachment
		? ImportAttachment(_assetPath)
		: ImportAsset(_assetPath);

	_asset.Name = _assetSave.Name;
	_asset.Position.X = _assetSave.Position.X;
	_asset.Position.Y = _assetSave.Position.Y;
	_asset.Position.Z = _assetSave.Position.Z;
	_asset.Rotation.X = _assetSave.Rotation.X;
	_asset.Rotation.Y = _assetSave.Rotation.Y;
	_asset.Rotation.Z = _assetSave.Rotation.Z;
	_asset.Scale.X = _assetSave.Scale.X;
	_asset.Scale.Y = _assetSave.Scale.Y;
	_asset.Scale.Z = _assetSave.Scale.Z;
	_asset.SamplingRate = _samplingRate;
	_asset.FrameFilters = _assetSave.AnimationFrameFilters;

	for (var i = 0; i < array_length(_assetSave.Materials); ++i)
	{
		var _materialSaved = _assetSave.Materials[i];
		var _material = _asset.Materials[i];

		var _texturePath = _materialSaved.Texture;
		if (_texturePath != undefined
			&& _texturePath != pointer_null)
		{
			_texturePath = ST_PathGetAbsolute(_texturePath, global.stSavePath);

			if (!file_exists(_texturePath))
			{
				show_message("Could not find file \"" + _texturePath + "\"! Please select it again.");
				_texturePath = get_open_filename("", filename_name(_texturePath));
			}
			var _sprite = _asset.LoadSprite(_texturePath);
			_asset.Materials[i].BaseOpacity = sprite_get_texture(_sprite, 0);
			_asset.MaterialSprites[@ i] = _texturePath;
		}

		_material.BaseOpacityMultiplier.Red   = _materialSaved.Color.Red;
		_material.BaseOpacityMultiplier.Green = _materialSaved.Color.Green;
		_material.BaseOpacityMultiplier.Blue  = _materialSaved.Color.Blue;
		_material.BaseOpacityMultiplier.Alpha = _materialSaved.Color.Alpha;
	}

	for (var i = 0; i < array_length(_assetSave.Attachments); ++i)
	{
		var _attachmentSave = _assetSave.Attachments[i];
		var _attachment = __LoadAssetFromSave(_attachmentSave, true);
		var _attachedTo = _attachmentSave.AttachedTo;
		if (_attachedTo != undefined
			&& _attachedTo != pointer_null)
		{
			_attachment.AttachedToBone = Asset.Model.find_node_id(_attachedTo);
		}
	}

	return _asset;
};

/// @func __LoadSave()
///
/// @desc
///
/// @private
__LoadSave = function () {
	Save = new ST_Save().FromFile(global.stSavePath);

	if (Save.Asset)
	{
		__LoadAssetFromSave(Save.Asset, false);
	}

	AmbientLightEnabled = Save.AmbientEnabled;

	AmbientLightUp.Red   = Save.AmbientUp.Red;
	AmbientLightUp.Green = Save.AmbientUp.Green;
	AmbientLightUp.Blue  = Save.AmbientUp.Blue;
	AmbientLightUp.Alpha = Save.AmbientUp.Alpha;

	AmbientLightDown.Red   = Save.AmbientDown.Red;
	AmbientLightDown.Green = Save.AmbientDown.Green;
	AmbientLightDown.Blue  = Save.AmbientDown.Blue;
	AmbientLightDown.Alpha = Save.AmbientDown.Alpha;

	global.stDirectionalLightsEnabled = Save.DirectionalLightsEnabled;
	global.stDirectionalLights = [];
	var _directionalLightsCount = array_length(Save.DirectionalLights);
	for (var i = 0; i < _directionalLightsCount; ++i)
	{
		var _directionalLightSaved = Save.DirectionalLights[i];
		var _directionalLight = new BBMOD_DirectionalLight(
			new BBMOD_Color(
				_directionalLightSaved.Color.Red,
				_directionalLightSaved.Color.Green,
				_directionalLightSaved.Color.Blue,
				_directionalLightSaved.Color.Alpha),
			new BBMOD_Vec3(
				_directionalLightSaved.Direction.X,
				_directionalLightSaved.Direction.Y,
				_directionalLightSaved.Direction.Z));
		_directionalLight.Enabled = _directionalLightSaved.Enabled;
		array_push(global.stDirectionalLights, _directionalLight);
	}

	global.stCameraDirection.X = Save.CameraDirection.X;
	global.stCameraDirection.Y = Save.CameraDirection.Y;
	global.stCameraPosition.X = Save.CameraPosition.X;
	global.stCameraPosition.Y = Save.CameraPosition.Y;
	global.stCameraPosition.Z = Save.CameraPosition.Y;

	AssetRenderer.Width = Save.ExportWidth;
	AssetRenderer.Height = Save.ExportHeight;
	// TODO: Apply Save.ExportCamera in ST_ExportOptionsWidget
	AssetRenderer.Position.X = Save.ExportPosition.X;
	AssetRenderer.Position.Y = Save.ExportPosition.Y;
	AssetRenderer.Position.Z = Save.ExportPosition.Z;
	AssetRenderer.Rotation.X = Save.ExportRotation.X;
	AssetRenderer.Rotation.Y = Save.ExportRotation.Y;
	AssetRenderer.Rotation.Z = Save.ExportRotation.Z;
	AssetRenderer.Scale = Save.ExportScale;
	// Note:
	// Save.ExportRotations
	// Save.ExportAttachments
	// Save.ExportAttachmentsOnly
	// Save.ExportPath
	// are applied in ST_ExportOptionsWidget
};

/// @var {Struct.BBMOD_Vec3}
global.stCameraPosition = new BBMOD_Vec3();

/// @var {Struct.BBMOD_Vec2}
global.stCameraDirection = new BBMOD_Vec2();

/// @var {Array<Struct.BBMOD_DirectionalLight>}
global.stDirectionalLights = [
	new BBMOD_DirectionalLight(),
];

/// @var {Bool}
global.stDirectionalLightsEnabled = true;

z = 0;

Debug = false;

Gizmo = new ST_Gizmo(15);
Gizmo.KeyNextEditSpace = undefined;
GridVisible = true;

Renderer = new ST_Renderer();
Renderer.UseAppSurface = true;
Renderer.RenderScale = 1.0;
Renderer.Antialiasing = BBMOD_EAntialiasing.FXAA;
Renderer.Gizmo = Gizmo;
Renderer.EditMode = true;
Renderer.InstanceHighlightColor = BBMOD_C_AQUA;

MouseOffset = undefined;
CameraPosition = undefined;

Camera = new BBMOD_Camera();
//Camera.Orthographic = true;
Camera.FollowObject = self;
Camera.Direction = 135.0;
Camera.DirectionUp = -45.0;
Camera.Zoom = 10.0;
Camera.MouseSensitivity = 0.5;

Gizmo.Renderer = Renderer;
Gizmo.Camera = Camera;

AssetImporter = new ST_AssetImporter();

Asset = undefined;

AssetRenderer = new ST_AssetRenderer();

RenderPreviewAnimation = 0;
RenderPreviewFrame = 0;

AmbientLightEnabled = true;

AmbientLightUp = BBMOD_C_WHITE;
bbmod_light_ambient_set_up(AmbientLightUp);

AmbientLightDown = BBMOD_C_GRAY;
bbmod_light_ambient_set_down(AmbientLightDown);

TaskQueue = new ST_TaskQueue();

draw_set_font(ST_FntOpenSans10);
display_set_gui_maximize(1.0, 1.0);
application_surface_draw_enable(false);

MaterialBall = new BBMOD_Model("Data/MaterialBall.bbmod");
MaterialBall.Materials[0] = ST_GetDefaultMaterial().clone();
 
MaterialPreviewCamera = new BBMOD_Camera();
MaterialPreviewCamera.Target.Set(0.0);
MaterialPreviewCamera.AspectRatio = 1;
MaterialPreviewCamera.Zoom = 3;
MaterialPreviewCamera.Direction = 135;
MaterialPreviewCamera.update(0);

/// @var {Struct.ST_Save, Undefined}
Save = undefined;

if (global.stSavePath != undefined)
{
	__LoadSave();
}

GUI = new ST_GUI(self);

UpdateWindowCaption();
