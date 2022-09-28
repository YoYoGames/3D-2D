/// @func ST_AttachmentsWidget(_store[, _props])
///
/// @extends GUI_VBox
///
/// @param {Id.Instance, Struct} _store
/// @param {Struct} [_props]
function ST_AttachmentsWidget(_store, _props={})
	: GUI_VBox(_props) constructor
{
	/// @var {Id.Instance, Struct}
	Store = _store;

	SetWidth(_props[$ "Width"] ?? "100%");

	SectionAttachmentsList = new GUI_VBox({
		Width: "100%",
		PaddingLeft: 19,
		PaddingRight: 19,
		PaddingTop: 12,
		PaddingBottom: 12,
		Spacing: 12,
	});

	ButtonAddAttachment = new GUI_Button("Add Attachment", {
		Width: "100%",
		OnClick: method(self, function () {
			AddAttachment();
		}),
		Disabled: method(self, function () {
			return !Store.Asset;
		}),
	});
	SectionAttachmentsList.Add(ButtonAddAttachment);

	AttachmentsList = new GUI_SelectList({
		Width: "100%",
		Height: 133,
	});
	SectionAttachmentsList.Add(AttachmentsList);

	TextAttachmentsList = new GUI_SectionHeader("Attachments List", {
		Target: SectionAttachmentsList,
	});

	Add(TextAttachmentsList);
	Add(SectionAttachmentsList);

	SectionSettings = new GUI_VBox({
		Width: "100%",
		PaddingLeft: 19,
		PaddingRight: 19,
		PaddingTop: 12,
		PaddingBottom: 12,
	});

	TextSettings = new GUI_SectionHeader("Settings");

	Add(TextSettings);
	Add(SectionSettings);

	AttachmentCounter = 0;

	if (Store.Asset)
	{
		for (var i = 0; i < array_length(Store.Asset.Attachments); ++i)
		{
			AddAttachment(Store.Asset.Attachments[i]);
		}
	}

	/// @func AddAttachment([_attachment])
	///
	/// @desc
	///
	/// @param {Struct.ST_Asset} [_attachment]
	///
	/// @return {Struct.ST_AttachmentsWidget} Returns `self`.
	static AddAttachment = function (_attachment=undefined) {
		++AttachmentCounter;

		var _items1 = AttachmentsList.GetItems();
		var _items2 = SectionSettings.Children;
		var i = 0;
		repeat (array_length(_items1))
		{
			_items1[i].IsSelected = false;
			_items2[i].SetProps({
				Visible: false,
			});
			++i;
		}

		var _attachmentName = _attachment
			? _attachment.Name
			: "Attachment " + string(AttachmentCounter);

		var _listItem = new GUI_SelectListItem(_attachmentName, {
			IsSelected: true,
			OnClick: method(self, function (_listItem) {
				var _items1 = AttachmentsList.GetItems();
				var _items2 = SectionSettings.Children;
				var i = 0;
				repeat (array_length(_items1))
				{
					_items1[i].IsSelected = false;
					_items2[i].SetProps({
						Visible: false,
					});
					++i;
				}

				_listItem.IsSelected = true;
				_listItem.Target.SetProps({
					Visible: true,
				});
			}),
		});

		var _settings = new ST_AttachmentSettingsWidget(Store, _attachmentName, _listItem, {
			Asset: _attachment,
		});
		SectionSettings.Add(_settings);

		_listItem.Target = _settings;

		AttachmentsList.Add(_listItem);

		return self;
	};

	/// @func Reset()
	///
	/// @desc
	///
	/// @return {Struct.ST_AttachmentsWidget} Returns `self`.
	static Reset = function () {
		AttachmentsList.VBox.RemoveChildWidgets();
		SectionSettings.RemoveChildWidgets();
		AttachmentCounter = 0;
		return self;
	};

	static VBox_Update = Update;

	static Update = function () {
		VBox_Update();
		//TextSettings.SetProps({
		//	Visible: (AttachmentCounter > 0),
		//});
		SectionSettings.SetProps({
			Visible: (!TextSettings.Collapsed && AttachmentCounter > 0),
		});
		return self;
	};
}
