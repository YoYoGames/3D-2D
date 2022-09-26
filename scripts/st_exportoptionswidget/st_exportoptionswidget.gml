/// @func ST_ExportOptionsWidget(_store[, _props])
///
/// @desc
///
/// @param {Id.Instance, Struct} _store
/// @param {Struct.GUI_VBox} [_props]
function ST_ExportOptionsWidget(_store, _props={})
	: GUI_VBox(_props) constructor
{
	/// @var {Id.Instance, Struct}
	Store = _store;

	SetWidth(_props[$ "Width"] ?? "100%");

	var _styleInputSpriteSize = {
		Width: 70,
		Min: 1,
		WholeNumbers: true,
	};

	styleColumnRight = { X: 119 };

	Rotations = _store.Save ? _store.Save.ExportNumberOfRotations : 8;

	// Export preview
	var _exportPreview = new (function (_store, _props={}) : GUI_Widget(_props) constructor {
		Store = _store;

		SetSize(
			_props[$ "Width"] ?? "100%",
			_props[$ "Height"] ?? 243
		);

		static Draw = function () {
			GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, c_black);
			if (Store.Asset)
			{
				Store.AssetRenderer.DrawPreview(Store.Asset, RealX, RealY, RealWidth, RealHeight);
			}
			DrawChildren();
			return self;
		};
	})(Store);
	Add(_exportPreview);

	var _vboxExportOptions = new GUI_VBox({
		Width: "100%",
		Spacing: 12,
		PaddingLeft: 10,
		PaddingRight: 10,
		PaddingTop: 12,
		PaddingBottom: 12,
	});
	Add(_vboxExportOptions);

	// Sprite size
	var _textSpriteSize = new GUI_Text("Sprite Size");
	_vboxExportOptions.Add(_textSpriteSize);

	var _hboxSpriteSize = new GUI_HBox({ X: 119, Spacing: 4 });
	_textSpriteSize.Add(_hboxSpriteSize);

	_hboxSpriteSize.Add(new GUI_Text("W"));

	inputSpriteWidth = new GUI_Input(
		Store.AssetRenderer.Width,
		GUI_StructExtend({}, _styleInputSpriteSize, {
			OnChange: method(self, function (_value) {
				if (checkboxSpriteKeepAspectRation.Value)
				{
					var _aspect = Store.AssetRenderer.Width / Store.AssetRenderer.Height;
					Store.AssetRenderer.Height = max(_value / _aspect, 1.0);
					inputSpriteHeight.Value = Store.AssetRenderer.Height;
				}
				Store.AssetRenderer.Width = _value;
			}),
		}));
	_hboxSpriteSize.Add(inputSpriteWidth);

	_hboxSpriteSize.Add(new GUI_Text("H"));

	inputSpriteHeight = new GUI_Input(
		Store.AssetRenderer.Height,
		GUI_StructExtend({}, _styleInputSpriteSize, {
			OnChange: method(self, function (_value) {
				if (checkboxSpriteKeepAspectRation.Value)
				{
					var _aspect = Store.AssetRenderer.Width / Store.AssetRenderer.Height;
					Store.AssetRenderer.Width = max(_value * _aspect, 1.0);
					inputSpriteWidth.Value = Store.AssetRenderer.Width;
				}
				Store.AssetRenderer.Height = _value;
			}),
		}));
	_hboxSpriteSize.Add(inputSpriteHeight);

	checkboxSpriteKeepAspectRation = new GUI_Checkbox(true, { Tooltip: "Keep aspect ratio" });
	_hboxSpriteSize.Add(checkboxSpriteKeepAspectRation);

	_vboxExportOptions.Add(new GUI_VSeparator());

	// Camera
	var _textCamera = new GUI_Text("Camera");
	_vboxExportOptions.Add(_textCamera);

	OptionCustom = new GUI_DropdownOption("Custom");

	DropdownCamera = new GUI_Dropdown(GUI_StructExtend({}, styleColumnRight, {
		Width: 283,
		OnChange: method(Store.AssetRenderer.Camera, ApplyCameraSetting),
	}), [
		new GUI_DropdownOption("Isometric", { IsDefault: true }),
		new GUI_DropdownOption("Isometric 45"),
		new GUI_DropdownOption("Left"),
		new GUI_DropdownOption("Right"),
		new GUI_DropdownOption("Front"),
		new GUI_DropdownOption("Back"),
		new GUI_DropdownOption("Top"),
		new GUI_DropdownOption("Bottom"),
		OptionCustom,
	]);
	_textCamera.Add(DropdownCamera);

	_vboxExportOptions.Add(new GUI_VSeparator());

	// Transform
	var _textPosition = new GUI_Text("Model Position");
	_vboxExportOptions.Add(_textPosition);

	var _inputPosition = new ST_VectorInput(Store.AssetRenderer.Position, { X: 119, Step: 0.1 });
	_textPosition.Add(_inputPosition);

	var _textRotation = new GUI_Text("Model Rotation");
	_vboxExportOptions.Add(_textRotation);

	var _inputRotation = new ST_VectorInput(Store.AssetRenderer.Rotation, { X: 119 });
	_textRotation.Add(_inputRotation);

	var _textScale = new GUI_Text("Model Scale");
	_vboxExportOptions.Add(_textScale);

	_textScale.Add(new GUI_Input(Store.AssetRenderer.Scale, {
		X: 119,
		Width: 70,
		Step: 0.01,
		Min: 0.0,
		OnChange: method(Store.AssetRenderer, function (_value) {
			Scale = _value;
		}),
	}));

	_vboxExportOptions.Add(new GUI_VSeparator());

	// Number of Rotations
	var _textRotations = new GUI_Text("Rotations");
	_vboxExportOptions.Add(_textRotations);

	inputRotations = new GUI_Input(Rotations, GUI_StructExtend({}, styleColumnRight, {
		Min: 1,
		Max: 360,
		WholeNumbers: true,
		OnChange: method(self, function (_value) {
			Rotations = _value;
		}),
		X: 119,
		Width: 70,
	}));
	_textRotations.Add(inputRotations);

	_vboxExportOptions.Add(new GUI_VSeparator());

	// Do export attachments
	var _textExportAttachments = new GUI_Text("Export Attached");
	_vboxExportOptions.Add(_textExportAttachments);

	checkboxExportAttachments = new GUI_Checkbox(
		_store.Save ? _store.Save.ExportAttachments : true,
		GUI_StructExtend({}, styleColumnRight, {
			OnChange: method(self, function (_value) {
				if (Store.Asset)
				{
					Store.Asset.AreAttachmentsVisible = _value;
				}
			}),
		}));
	_textExportAttachments.Add(checkboxExportAttachments);

	// Export attachments only
	var _textAttachmentsOnly = new GUI_Text("Attached Only");
	_vboxExportOptions.Add(_textAttachmentsOnly);

	CheckboxAttachmentsOnly = new GUI_Checkbox(
		_store.Save ? _store.Save.ExportAttachmentsOnly : false,
		styleColumnRight);
	_textAttachmentsOnly.Add(CheckboxAttachmentsOnly);

	_vboxExportOptions.Add(new GUI_VSeparator());

	// TODO: Export range

	// Export path
	InputExportPath = new GUI_FileInput(_store.Save ? _store.Save.ExportPath : "", {
		Width: "100%",
		Save: true,
		Filter: ST_FILTER_TEXTURE,
	});
	_vboxExportOptions.Add(InputExportPath);

	// Export
	buttonExport = new GUI_Button("Export", {
		Width: "100%",
		Disabled: method(self, function () {
			return (InputExportPath.Value == "");
		}),
		OnClick: method(self, ExportSprites),
	});
	_vboxExportOptions.Add(buttonExport);

	/// @func ExportSprites()
	///
	/// @desc
	///
	/// @return {Struct.CExportOptions} Returns `self`.
	static ExportSprites = function () {
		if (!Store.Asset)
		{
			return self;
		}
		var _rot = 0;
		repeat (Rotations)
		{ 
			if (array_length(Store.Asset.Animations) > 0)
			{
				for (var _animationIndex = array_length(Store.Asset.Animations) - 1;
					_animationIndex >= 0;
					--_animationIndex)
				{
					var _savePath = filename_change_ext(InputExportPath.Value,
						Store.Asset.AnimationNames[_animationIndex]
							+ string(_rot)
							+ "_strip"
							+ string(Store.Asset.GetAnimationFrameCount(_animationIndex))
							+ ".png");

					Store.TaskQueue.Add(new ST_ExportAnimatedSpriteTask(
						Store.AssetRenderer,
						Store.Asset,
						_animationIndex,
						_rot,
						_savePath
					));
				}
			}
			else
			{
				Store.TaskQueue.Add(new ST_ExportStaticSpriteTask(
					Store.AssetRenderer,
					Store.Asset,
					_rot,
					InputExportPath.Value
				));
			}
			_rot += 360.0 / Rotations;
		}
		return self;
	};

	static VBox_Update = Update;

	static Update = function () {
		if (Store.Asset)
		{
			Store.Asset.AreAttachmentsVisible = checkboxExportAttachments.Value;
			var _hideBody = Store.Asset.AreAttachmentsVisible && CheckboxAttachmentsOnly.Value;

			var _materials = Store.Asset.Materials;
			var i = 0;
			repeat (array_length(_materials))
			{
				var _material = _materials[i++];
				_material.BaseOpacityMultiplier.Alpha = _hideBody ? 0.0 : 1.0;
				_material.AlphaTest = _hideBody ? 0.0 : 1.0;
			}
		}
		return self;
	};
}
