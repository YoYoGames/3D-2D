/// @func ST_ModelWidget(_store[, _props])
///
/// @extends GUI_VBox
///
/// @desc
///
/// @param {Id.Instance, Store} _store
/// @param {Struct} [_props]
function ST_ModelWidget(_store, _props={})
	: GUI_VBox(_props) constructor
{
	/// @var {Id.Instance, Store}
	Store = _store;

	SetWidth(_props[$ "Width"] ?? "100%");

	styleColumnRight = {
		X: 129,
	};

	var _styleSectionVBox = {
		Spacing: 12,
		Width: "100%",
		PaddingLeft: 19,
		PaddingRight: 19,
		PaddingTop: 12,
		PaddingBottom: 12,
	};

	vboxImport = new GUI_VBox(_styleSectionVBox);
	textImport = new GUI_SectionHeader("Import", { Target: vboxImport });
	Add(textImport);
	Add(vboxImport);

	var _assetPath = (Store.Save && Store.Save.Asset)
		? Store.Save.Asset.Path
		: "";

	inputImportPath = new GUI_FileInput(_assetPath, {
		Filter: ST_FILTER_MODEL,
		Width: "100%",
	});
	vboxImport.Add(inputImportPath);

	buttonImport = new GUI_Button("Import", {
		Width: "100%",
		Disabled: method(self, function () {
			return (inputImportPath.Value == "");
		}),
		OnClick: method(self, function () {
			var _path = inputImportPath.Value;
			if (_path != "")
			{
				Store.ImportAsset(_path);
				if (Store.Asset)
				{
					vboxAsset
						.RemoveChildWidgets()
						.Add(new ST_AssetWidget(Store.Asset));
					Root.FramesPane.AddFrames();
					Root.MainPane.Attachments.Reset();
				}
			}
		}),
	});
	vboxImport.Add(buttonImport);

	////////////////////////////////////////////////////////////////////////////////
	// Asset
	vboxAsset = new GUI_VBox({ Width: "100%" });
	Add(vboxAsset);

	if (Store.Asset)
	{
		vboxAsset.Add(new ST_AssetWidget(Store.Asset));
	}

	////////////////////////////////////////////////////////////////////////////////
	// Ambient light
	vboxAmbientLight = new GUI_VBox(_styleSectionVBox);
	textAmbientLight = new GUI_SectionHeader("Ambient Light", { Target: vboxAmbientLight });
	Add(textAmbientLight);
	Add(vboxAmbientLight);

	var _textAmbientEnabled = new GUI_Text("Enabled");
	vboxAmbientLight.Add(_textAmbientEnabled);

	var _checkboxAmbientEnabled = new GUI_Checkbox(Store.AmbientLightEnabled, GUI_StructExtend({}, styleColumnRight, {
		OnChange: method(self, function (_value) {
			Store.AmbientLightEnabled = _value;
			bbmod_light_ambient_set_up(_value ? Store.AmbientLightUp : BBMOD_C_BLACK);
			bbmod_light_ambient_set_down(_value ? Store.AmbientLightDown : BBMOD_C_BLACK);
		}),
	}));
	_textAmbientEnabled.Add(_checkboxAmbientEnabled);

	var _textAmbientUpColor = new GUI_Text("Colour Up");
	vboxAmbientLight.Add(_textAmbientUpColor);

	_textAmbientUpColor.Add(new GUI_ColorInput(Store.AmbientLightUp, GUI_StructExtend({}, styleColumnRight, {
		Width: 282,
	})));

	var _textAmbientDownColor = new GUI_Text("Colour Down");
	vboxAmbientLight.Add(_textAmbientDownColor);

	_textAmbientDownColor.Add(new GUI_ColorInput(Store.AmbientLightDown, GUI_StructExtend({}, styleColumnRight, {
		Width: 282,
	})));

	//checkboxAmbientLock = new GUI_Checkbox(true, {
	//	Tooltip: "Use same as Colour Up",
	//	OnChange: method(self, function (_value) {
	//		if (_value)
	//		{
	//			AmbientLightDown.Red = AmbientLightUp.Red;
	//			AmbientLightDown.Green = AmbientLightUp.Green;
	//			AmbientLightDown.Blue = AmbientLightUp.Blue;

	//			inputAmbientDownR.SetValue(AmbientLightDown.Red);
	//			inputAmbientDownG.SetValue(AmbientLightDown.Green);
	//			inputAmbientDownB.SetValue(AmbientLightDown.Blue);
	//		}

	//		inputAmbientDownR.Disabled = _value;
	//		inputAmbientDownG.Disabled = _value;
	//		inputAmbientDownB.Disabled = _value;
	//	}),
	//});

	//_hboxAmbientDownColor.Add(checkboxAmbientLock);

	////////////////////////////////////////////////////////////////////////////////
	// Directional light
	sectionDirectionalLights = new GUI_VBox(_styleSectionVBox);
	textDirectionalLights = new GUI_SectionHeader("Directional Lights", { Target: sectionDirectionalLights });
	Add(textDirectionalLights);
	Add(sectionDirectionalLights);

	var _textDirectionalEnabled = new GUI_Text("Enabled");
	sectionDirectionalLights.Add(_textDirectionalEnabled);

	var _checkboxDirectionalEnabled = new GUI_Checkbox(global.stDirectionalLightsEnabled, GUI_StructExtend({}, styleColumnRight, {
		OnChange: function (_value) {
			global.stDirectionalLightsEnabled = _value;
		},
	}));
	_textDirectionalEnabled.Add(_checkboxDirectionalEnabled);

	buttonAddDirectionalLight = new GUI_Button("Add", {
		Width: "100%",
		OnClick: method(self, function () {
			AddDirectionalLight();
		}),
		Disabled: function () {
			return (array_length(global.stDirectionalLights) >= 8);
		},
	});
	sectionDirectionalLights.Add(buttonAddDirectionalLight);

	accordionDirectionalLights = new GUI_Accordion({ Width: "100%" });
	sectionDirectionalLights.Add(accordionDirectionalLights);

	DirectionalLightCounter = 0;

	for (var i = 0; i < array_length(global.stDirectionalLights); ++i)
	{
		AddDirectionalLight(global.stDirectionalLights[i]);
	}

	/// @func AddDirectionalLight([_directionalLight])
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_DirectionalLight} [_directionalLight] Use when adding
	/// a widget for an already existing light.
	///
	/// @return {Struct.ST_ModelWidget} Returns `self`.
	static AddDirectionalLight = function (_directionalLight=undefined) {
		if (_directionalLight == undefined)
		{
			_directionalLight = new BBMOD_DirectionalLight();
			array_push(global.stDirectionalLights, _directionalLight);
		}

		var _vbox = new GUI_VBox({ Spacing: 12, Padding: 10 });
		var _body = new GUI_AccordionBody({}, [_vbox]);
		var _header = new GUI_AccordionHeader(
			"Directional light " + string(++DirectionalLightCounter), { Target: _body });

		var _item = new GUI_AccordionItem({}, [
			_header,
			_body,
		]);

		var _hbox = new GUI_HBox({
			AnchorLeft: 1.0,
			X: -48,
		}, [
			new GUI_GlyphButton(ST_EIcon.Visible, {
				Font: ST_FntIcons,
				BackgroundSprite: undefined,
				OnClick: method(_directionalLight, function (_iconButton) {
					Enabled = !Enabled;
					_iconButton.Glyph = Enabled ? ST_EIcon.Visible : ST_EIcon.Invisible;
				}),
			}),
			new GUI_GlyphButton(ST_EIcon.Delete, {
				Font: ST_FntIcons,
				BackgroundSprite: undefined,
				OnClick: method({ Item: _item, Light: _directionalLight }, function () {
					Item.Destroy();
					for (var i = array_length(global.stDirectionalLights) - 1; i >= 0; --i)
					{
						if (global.stDirectionalLights[i] == Light)
						{
							array_delete(global.stDirectionalLights, i, 1);
							break;
						}
					}
				}),
			}),
		]);
		_header.Add(_hbox);

		var _textDirectionalDir = new GUI_Text("Direction");
		_vbox.Add(_textDirectionalDir);

		var _hboxDirectionalDir = new GUI_HBox({ X: 129, Spacing: 4 });
		_textDirectionalDir.Add(_hboxDirectionalDir);

		_hboxDirectionalDir.Add(new ST_VectorInput(_directionalLight.Direction, {
			Min: -1.0,
			Max: 1.0,
			Step: 0.01,
		}));

		var _textDirectionalColor = new GUI_Text("Colour");
		_vbox.Add(_textDirectionalColor);

		_textDirectionalColor.Add(new GUI_ColorInput(_directionalLight.Color, {
			X: 129,
			Width: 282,
		}));

		accordionDirectionalLights.Add(_item);

		return self;
	};
}
