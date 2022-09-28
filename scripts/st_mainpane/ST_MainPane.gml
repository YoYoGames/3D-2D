/// @func ST_MainPane(_store[, _props])
///
/// @extends GUI_ScrollPane
///
/// @desc
///
/// @param {Id.Instance, Store} _store
/// @param {Struct} [_props]
function ST_MainPane(_store, _props={})
	: GUI_ScrollPane(_props) constructor
{
	/// @var {Id.Instance, Store}
	Store = _store;

	SetSize(
		_props[$ "Width"] ?? "100%",
		_props[$ "Height"] ?? "100%"
	);

	EnableScrollbarH = false;

	var _vbox = new GUI_VBox({
		Width: "100%",
	});
	Canvas.Add(_vbox);

	var _vboxModel = new GUI_VBox({
		Width: "100%",
		Spacing: 4,
	});

	var _vboxAttachments = new GUI_VBox({
		Width: "100%",
		Spacing: 4,
	});

	var _tabGroup = new GUI_TabGroup({ Height: 46 });
	_vbox.Add(_tabGroup);

	var _tabModel = new GUI_Tab("Model", { Target: _vboxModel, IsSelected: true });
	_tabGroup.Add(_tabModel);

	var _tabAttachments = new GUI_Tab("Attachments", { Target: _vboxAttachments });
	_tabGroup.Add(_tabAttachments);

	_vbox.Add(_vboxModel);
	_vbox.Add(_vboxAttachments);

	ModelWidget = new ST_ModelWidget(Store, { Height: "100%" });
	_vboxModel.Add(ModelWidget);

	Attachments = new ST_AttachmentsWidget(Store, { Height: "100%" });

	_vboxAttachments.Add(Attachments);
}
