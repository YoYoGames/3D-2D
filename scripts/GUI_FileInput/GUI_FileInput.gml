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
				? get_save_filename(Filter, Filename)
				: get_open_filename(Filter, Filename);
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

	static Input_Layout = Layout;

	static Layout = function (_force=false) {
		CHECK_LAYOUT_CHANGED;
		RealWidth -= SelectButton.RealWidth;
		Input_Layout(_force);
		return self;
	};
}
