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

	var _styleColumnLeft = {
		Width: 129,
		MaxWidth: "25%",
	};

	var _styleSectionVBox = {
		Gap: 12,
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

	DoImport = function () {
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
	};

	inputImportPath = new GUI_FileInput(_assetPath, {
		Filter: ST_FILTER_MODEL,
		Width: "100%",
		OnSelect: method(self, DoImport),
	});
	vboxImport.Add(inputImportPath);

	buttonImport = new GUI_Button("Import", {
		Width: "100%",
		Disabled: method(self, function () {
			return (inputImportPath.Value == "");
		}),
		OnClick: method(self, DoImport),
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

	vboxAmbientLight.Add(
		new GUI_FlexLayout({
			Width: "100%",
			Height: "auto",
		}, [
			new GUI_Text("Enabled", _styleColumnLeft),
			new GUI_Checkbox(Store.AmbientLightEnabled, {
				OnChange: method(self, function (_value) {
					Store.AmbientLightEnabled = _value;
					bbmod_light_ambient_set_up(_value ? Store.AmbientLightUp : BBMOD_C_BLACK);
					bbmod_light_ambient_set_down(_value ? Store.AmbientLightDown : BBMOD_C_BLACK);
				}),
			}),
		])
	);

	vboxAmbientLight.Add(
		new GUI_FlexLayout({
			Width: "100%",
			Height: "auto",
		}, [
			new GUI_Text("Colour Up", _styleColumnLeft),
			new GUI_ColorInput(Store.AmbientLightUp, { FlexGrow: 1 }),
		])
	);

	vboxAmbientLight.Add(
		new GUI_FlexLayout({
			Width: "100%",
			Height: "auto",
		}, [
			new GUI_Text("Colour Down", _styleColumnLeft),
			new GUI_ColorInput(Store.AmbientLightDown, { FlexGrow: 1 }),
		])
	);

	////////////////////////////////////////////////////////////////////////////////
	// Directional light
	sectionDirectionalLights = new GUI_VBox(_styleSectionVBox);
	textDirectionalLights = new GUI_SectionHeader("Directional Lights", { Target: sectionDirectionalLights });
	Add(textDirectionalLights);
	Add(sectionDirectionalLights);

	sectionDirectionalLights.Add(
		new GUI_FlexLayout({
			Width: "100%",
			Height: "auto",
		}, [
			new GUI_Text("Enabled", _styleColumnLeft),
			new GUI_Checkbox(global.stDirectionalLightsEnabled, {
				OnChange: function (_value) {
					global.stDirectionalLightsEnabled = _value;
				},
			}),
		])
	);

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

		var _body = new GUI_AccordionBody({
			Gap: 12,
			Padding: 10,
			Width: "100%",
			Height: "auto",
		});

		var _header = new GUI_AccordionHeader(
			"Directional light " + string(++DirectionalLightCounter), { Target: _body });

		var _item = new GUI_AccordionItem({}, [
			_header,
			_body,
		]);

		_header.Add(new GUI_GlyphButton(ST_EIcon.Visible, {
			Font: ST_FntIcons11,
			Minimal: true,
			OnClick: method(_directionalLight, function (_iconButton) {
				Enabled = !Enabled;
				_iconButton.Glyph = Enabled ? ST_EIcon.Visible : ST_EIcon.Invisible;
			}),
		}));

		_header.Add(new GUI_GlyphButton(ST_EIcon.Delete, {
			Font: ST_FntIcons11,
			Minimal: true,
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
		}));

		// Light direction controls
		_body.Add(
			new GUI_FlexLayout({
				Width: "100%",
				Height: "auto",
			}, [
				new GUI_Text("Direction", { Width: 120, MaxWidth: "25%" }),
				new ST_VectorInput(_directionalLight.Direction, {
					FlexGrow: 1,
					Min: -1.0,
					Max: 1.0,
					Step: 0.01,
				}),
			])
		);

		// Light color controls
		_body.Add(
			new GUI_FlexLayout({
				Width: "100%",
				Height: "auto",
			}, [
				new GUI_Text("Colour", { Width: 120, MaxWidth: "25%" }),
				new GUI_ColorInput(_directionalLight.Color, {
					FlexGrow: 1,
					X: 129,
					Width: 282,
				}),
			])
		);

		accordionDirectionalLights.Add(_item);

		return self;
	};
}
