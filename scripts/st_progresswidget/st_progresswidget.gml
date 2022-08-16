/// @func ST_ProgressWidget([_props])
///
/// @extends GUI_Widget
///
/// @desc
///
/// @param {Struct} [_props]
function ST_ProgressWidget(_props={})
	: GUI_Widget(_props) constructor
{
	/// @var {String}
	Text = _props[$ "Text"] ?? "Processing... ";

	/// @var {Real}
	Progress = _props[$ "Progress"] ?? 0;

	/// @var {Real}
	ProgressMax = _props[$ "ProgressMax"] ?? 0;

	SetSize(
		_props[$ "Width"] ?? 200,
		_props[$ "Height"] ?? (GUI_LINE_HEIGHT + 4),
	);

	static Draw = function () {
		var _progressCircleSize = sprite_get_width(ST_SprProgressCircle);

		// Background
		GUI_DrawRectangle(RealX, RealY, RealWidth, RealHeight, #3F434C);

		// Progress bar background
		var _progressBarWidth = RealWidth - 7 - _progressCircleSize - 20;
		var _progressBarX = RealX + 7;
		var _progressBarHeight = sprite_get_height(ST_SprProgressBar);
		var _progressBarY = RealY + floor((RealHeight - _progressBarHeight) * 0.5);
		GUI_DrawRectangle(_progressBarX, _progressBarY, _progressBarWidth, _progressBarHeight, #181818);

		// Progress bar fill
		draw_sprite_stretched(ST_SprProgressBar, 0, _progressBarX, _progressBarY,
			_progressBarWidth * (Progress / max(ProgressMax, 1)), _progressBarHeight);

		// Progress bar text
		var _progressText = Text + string(Progress) + "/" + string(ProgressMax);
		var _progressTextShortened = GUI_GetTextPartRight(_progressText, _progressBarWidth - 8);
		var _progressTextX = _progressBarX + 4;
		var _progressTextY = _progressBarY + floor((_progressBarHeight - GUI_FONT_HEIGHT) * 0.5);
		GUI_DrawText(_progressTextX - 1, _progressTextY, _progressTextShortened, c_black);
		GUI_DrawText(_progressTextX + 1, _progressTextY, _progressTextShortened, c_black);
		GUI_DrawText(_progressTextX, _progressTextY - 1, _progressTextShortened, c_black);
		GUI_DrawText(_progressTextX, _progressTextY + 1, _progressTextShortened, c_black);
		GUI_DrawText(_progressTextX, _progressTextY, _progressTextShortened, c_white);

		// Progress circle
		var _progressCircleSizeHalf = floor(_progressCircleSize * 0.5);
		var _progressCircleX = _progressBarX + _progressBarWidth + 10 + _progressCircleSizeHalf;
		var _progressCircleY = RealY + floor((RealHeight - _progressCircleSize) * 0.5) + _progressCircleSizeHalf;
		gpu_push_state();
		gpu_set_tex_filter(true);
		draw_sprite_ext(ST_SprProgressCircle, 0, _progressCircleX, _progressCircleY, 1, 1, -current_time, c_white, 1.0);
		gpu_pop_state();

		return self;
	};
}
