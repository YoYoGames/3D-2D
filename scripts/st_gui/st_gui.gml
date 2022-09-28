/// @func ST_GUI(_store[, _props])
///
/// @extends GUI_Root
///
/// @desc
///
/// @param {Id.Instance, Struct} _store
/// @param {Struct} [_props]
function ST_GUI(_store, _props={})
	: GUI_Root(_props) constructor
{
	/// @var {Id.Instance, Struct}
	Store = _store;

	FlexLayout = new GUI_FlexLayout({
		FlexDirection: "column",
		Width: "100%",
		Height: "100%",
	});
	Add(FlexLayout);

	Menu = new ST_MenuBar();
	FlexLayout.Add(Menu);

	HSplitterLeft = new GUI_HSplitter({
		Width: "100%",
		Height: "100%",
		FlexGrow: 1,
		Split: 0.25,
	});
	FlexLayout.Add(HSplitterLeft);

	HSplitterRight = new GUI_HSplitter({
		Width: "100%",
		Height: "100%",
		Split: 0.7,
	});
	HSplitterRight.Right.SetProps({ Visible: false });
	HSplitterLeft.Right.Add(HSplitterRight);

	FlexLayout = new GUI_FlexLayout({
		Width: "100%",
		Height: "100%",
		FlexDirection: "column",
	});
	HSplitterRight.Left.Add(FlexLayout);

	Viewport = new ST_ViewportWidget(Store, {
		Width: "100%",
		Height: "100%",
		FlexGrow: 1,
	});
	FlexLayout.Add(Viewport);

	AnimationPlayer = new ST_AnimationPlayerWidget(Store, { Visible: false });
	FlexLayout.Add(AnimationPlayer);

	FramesPane = new ST_FramesPane(Store, { Visible: false });
	FlexLayout.Add(FramesPane);

	MainPane = new ST_MainPane(Store);
	HSplitterLeft.Left.Add(MainPane);

	ExportOptionsPane = new ST_ExportOptionsPane(Store);
	HSplitterRight.Right.Add(ExportOptionsPane);

	Blocker = new (function (_props={}) : GUI_Widget(_props) constructor {
		MaxChildCount = 0;

		SetSize("100%", "100%");

		static Draw = function () {
			GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, c_black, 0.5);
			return self;
		};
	})();
	Add(Blocker);

	ProgressBar = new ST_ProgressWidget({
		AnchorLeft: 1.0,
		Visible: false,
	});
	Add(ProgressBar);

	AddEventListener("AnimationChange", function (_self, _event) {
		_self.FramesPane.AddFrames();
	});

	static Root_Update = Update;

	static Update = function () {
		Root_Update();
		var _taskQueue = Store.TaskQueue;
		Blocker.SetProps({
			Visible: (_taskQueue.BlockingTaskCount > 0),
		});
		ProgressBar.SetProps({
			Visible: (_taskQueue.GetTaskCount() > 0),
			Progress: _taskQueue.Progress,
			ProgressMax: _taskQueue.ProgressMax,
		});
		var _animationPlayerVisible = (Store.Asset
			&& Store.Asset.IsAnimated
			&& Store.Asset.AnimationIndex != undefined);
		AnimationPlayer.SetProps({
			Visible: _animationPlayerVisible,
		});
		FramesPane.SetProps({
			Visible: _animationPlayerVisible,
		});
		return self;
	};
}
