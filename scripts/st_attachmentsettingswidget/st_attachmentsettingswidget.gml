/// @func ST_AttachmentSettingsWidget(_store, _attachmentName, _listItem[, _props])
///
/// @extends GUI_VBox
///
/// @desc
///
/// @param {Id.Instance, Struct} _store
/// @param {String} _attachmentName
/// @param {Struct.GUI_SelectListItem} _listItem
/// @param {Struct} [_props]
function ST_AttachmentSettingsWidget(
	_store,
	_attachmentName,
	_listItem,
	_props={}
) : GUI_VBox(_props) constructor
{
	/// @var {Id.Instance, Struct}
	Store = _store;

	/// @var {String}
	AttachmentName = _attachmentName;

	/// @var {Struct.GUI_SelectListItem}
	ListItem = _listItem;

	/// @var {Struct.ST_Asset}
	Asset = _props[$ "Asset"];

	Spacing = _props[$ "Spacing"] ?? 12;

	SetWidth(_props[$ "Width"] ?? "100%");

	Add(new GUI_FileInput(Asset ? Asset.Path : "", {
		Filter: ST_FILTER_MODEL,
		Width: "100%",
		Disabled: method(self, function () {
			return !Store.Asset;
		}),
		OnChange: method(self, function (_path) {
			if (_path != "" && file_exists(_path))
			{
				var _attachment = Store.ImportAttachment(_path);
				if (_attachment)
				{
					if (Asset)
					{
						Asset.Destroy();
						with (ST_OAttachment)
						{
							if (Asset == other.Asset)
							{
								instance_destroy();
							}
						}
					}

					Asset = _attachment;
					Asset.Name = AttachmentName;
					AddSettingsWidgets();
				}
			}
		}),
	}));

	SettingsContainer = new GUI_VBox({ Width: "100%", Spacing: Spacing });
	Add(SettingsContainer);

	//MaxChildCount = array_length(Children);

	if (Asset)
	{
		AddSettingsWidgets();
	}

	static AddSettingsWidgets = function () {
		SettingsContainer.RemoveChildWidgets();

		var _columnRightX     = 109;
		var _columnRightWidth = 282;

		SettingsContainer.Add(new GUI_Widget({ Width: "100%" }, [
			new GUI_Text("Name"),
			new GUI_Input(Asset.Name, {
				X: _columnRightX,
				Width: _columnRightWidth,
				OnChange: method(self, function (_value) {
					Asset.Name = _value;
					AttachmentName = _value;
					ListItem.Text = _value;
				}),
			}),
		]));

		SettingsContainer.Add(new GUI_VSeparator());

		if (Store.Asset.IsAnimated)
		{
			var _dropdownBone = new GUI_Dropdown({
				X: _columnRightX,
				Width: _columnRightWidth,
				OnChange: method(Asset, function (_value) {
					AttachedToBone = _value;
				}),
			});

			_dropdownBone.AddOption(new GUI_DropdownOption("None", {
				Value: undefined,
				IsDefault: true,
			}));

			var _parent = Asset.AttachedTo;

			for (var i = 0; i < _parent.Model.BoneCount; ++i)
			{
				var _boneName = _parent.Model.find_node(i).Name;
				var _boneOption = new GUI_DropdownOption(_boneName, {
					Value: i,
				});
				_dropdownBone.AddOption(_boneOption);
				if (Asset.AttachedToBone == i)
				{
					_dropdownBone.SetProps({ Selected: _boneOption });
				}
			}

			SettingsContainer.Add(new GUI_Widget({ Width: "100%" }, [
				new GUI_Text("Bone"),
				_dropdownBone,
			]));

			SettingsContainer.Add(new GUI_VSeparator());
		}

		SettingsContainer.Add(new ST_TransformWidget(Asset));

		SettingsContainer.Add(new GUI_VSeparator());

		var _materialsGrid = new GUI_Grid(3, undefined, {
			X: _columnRightX,
			Width: _columnRightWidth,
		});

		for (var i = 0; i < array_length(Asset.Materials); ++i)
		{
			_materialsGrid.Add(new ST_MaterialThumbnailWidget(Asset, i));
		}

		SettingsContainer.Add(new GUI_Widget({ Width: "100%" }, [
			new GUI_Text("Materials"),
			_materialsGrid,
		]));
	};

	//var _buttonDuplicate = new GUI_Button("Duplicate", {
	//	Width: "100%",
	//	OnClick: method(self, function () {
	//		var _duplicate = Asset.Duplicate();
	//		Parent.Add(new ST_AssetWidget(_duplicate));

	//		var _i = instance_create_layer(0, 0, "Instances", ST_OAttachment);
	//		_i.Asset = _duplicate;
	//	}),
	//});
	//SettingsContainer.Add(_buttonDuplicate);

	var _buttonDelete = new GUI_Button("Delete", {
		Width: "100%",
		OnClick: method(self, function () {
			var _asset = Asset;
			if (_asset)
			{
				with (ST_OAttachment)
				{
					if (Asset == _asset)
					{
						instance_destroy();
					}
				}
				_asset.Destroy();
				_asset = undefined;
			}
			ListItem.Destroy();
			Destroy();
		}),
	});
	Add(_buttonDelete);
}
