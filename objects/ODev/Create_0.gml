display_set_gui_maximize(1.0, 1.0);
draw_set_font(ST_FntOpenSans10);

GUI = new GUI_Root({
	BackgroundColor: c_yellow,
	BackgroundAlpha: 0.1,
	Padding: 20,
}, [
	new GUI_FlexLayout({
		Width: "100%",
		Height: "100%",
		FlexDirection: "column",
		BackgroundColor: c_orange,
		BackgroundAlpha: 0.1,
		Padding: 20,
		Gap: 10,
	}, [
		new GUI_FlexLayout({
			Width: "100%",
			Height: "auto", // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			Gap: 10,
		}, [
			new GUI_Text("Some text here", {
				Width: "50%",
				MaxWidth: 130,
				TextOverflow: "clip",
				Color: c_white,
				BackgroundColor: c_lime,
			}),
			new GUI_Text("Some other text here", {
				FlexGrow: 1,
				TextOverflow: "clip",
				Color: c_white,
				BackgroundSprite: GUI_SprSectionHeader,
			}),
		]),
		new GUI_Text("Some text here", {
			Padding: 20,
			Height: 200,
			TextAlign: 1.0,
			VerticalAlign: 1.0,
			MinWidth: "1%",
			MaxWidth: "100%",
			TextOverflow: "ellipsis",
			Color: c_white,
			BackgroundColor: c_maroon,
			OnUpdate: function (_text) {
				_text.SetProps({ Width: window_mouse_get_x() - _text.RealX });
			},
		}),
		new GUI_Text("Some other text here", {
			PaddingLeft: 10,
			PaddingRight: 10,
			Width: "auto",
			TextOverflow: "ellipsis",
			Color: c_white,
			BackgroundSprite: GUI_SprSectionHeader,
		}),
	]),
]);
