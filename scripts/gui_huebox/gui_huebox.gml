/// @func GUI_HueBox([_props])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
function GUI_HueBox(_props={})
	: GUI_Widget(_props) constructor
{
	MaxChildCount = 0;

	/// @var {Id.Surface}
	Surface = noone;

	OnPress = function () {
		DragStart();
	};

	static Widget_Update = Update;

	static Update = function () {
		Widget_Update();
		if (IsDragged())
		{
			Parent.SetProps({
				"Sat": clamp(((window_mouse_get_x() - RealX) / RealWidth) * 255, 0, 255),
				"Val": clamp((1.0 - ((window_mouse_get_y() - RealY) / RealHeight)) * 255, 0, 255),
			});
			if (!mouse_check_button(mb_left))
			{
				DragEnd();
			}
		}
		return self;
	};

	static Draw = function () {
		if (Visible && RealWidth > 0 && RealHeight > 0)
		{
			Surface = GUI_CheckSurface(Surface, RealWidth, RealHeight);

			surface_set_target(Surface);
			draw_clear(c_black);
			var _matrixWorld = matrix_get(matrix_world);
			matrix_set(matrix_world, matrix_build_identity());

			shader_set(GUI_ShHueBox);
			var _uHue = shader_get_uniform(GUI_ShHueBox, "u_fHue");
			shader_set_uniform_f(_uHue, Parent.Hue / 256.0);
			GUI_DrawRectangle(0, 0, RealWidth, RealHeight);
			shader_reset();

			draw_sprite(
				GUI_SprHueBoxCrosshair, 0,
				(Parent.Sat / 255.0) * RealWidth,
				(1.0 - (Parent.Val / 255.0)) * RealHeight);

			matrix_set(matrix_world, _matrixWorld);
			surface_reset_target();
			draw_surface(Surface, RealX, RealY);
		}
		return self;
	};

	static Widget_Destroy = Destroy;

	static Destroy = function () {
		Widget_Destroy();
		if (surface_exists(Surface))
		{
			surface_free(Surface);
		}
		return undefined;
	};
}
