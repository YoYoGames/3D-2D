/// @func GUI_FileInput(_path[, _props])
///
/// @extends GUI_Input
///
/// @desc
///
/// @param {String} _path
/// @param {Struct} [_props]
function GUI_FileInput(_path, _props={})
	: GUI_Input(_path, _props) constructor
{
	static Input_Layout = Layout;

	MaxChildCount = 1;

	IsReal = false;

	/// @var {Bool}
	/// @readonly
	Save = _props[$ "Save"] ?? false;

	/// @var {String}
	Filter = _props[$ "Filter"] ?? "";

	/// @var {String}
	Filename = _props[$ "Filename"] ?? "";

	/// @var {Function}
	OnSelect = _props[$ "OnSelect"];

	BackgroundSprite = _props[$ "Sprite"] ?? GUI_SprButton;

	/// @var {Struct.GUI_Button}
	/// @readonly
	SelectButton = new GUI_Button("...", {
		Tooltip: "Select path...",
		AnchorLeft: 1.0,
		PivotLeft: 1.0,
		X: -1,
		OnClick: method(self, function () {
      var _path = Save
				? GetSaveFileName(Filter, Filename, ST_ENVVAR_HOME, "Save As")
				: GetOpenFileName(Filter, Filename, ST_ENVVAR_HOME, "Open");
			if (_path != "")
			{
				Change(_path);
				if (OnSelect)
				{
					OnSelect(_path);
				}
			}
		}),
	});
	SelectButton.Disabled = Disabled;
	Add(SelectButton);

	static Layout = function (_force=false) {
		RealWidth -= SelectButton.RealWidth;
		//SetProps({
		//	RealWidth: RealWidth - SelectButton.RealWidth,
		//});
		Input_Layout(_force);
		return self;
	};
}
