/// @var {Struct.BBMOD_Vec3}
global.stCameraPosition = new BBMOD_Vec3();

/// @var {Struct.BBMOD_Vec2}
global.stCameraDirection = new BBMOD_Vec2();

/// @func ApplyCameraSetting(_value)
///
/// @desc
///
/// @param {String} _value
function ApplyCameraSetting(_value)
{
	switch (_value)
	{
	case "Isometric":
		Direction = 90.0;
		DirectionUp = -45.0;
		break;

	case "Isometric 45":
		Direction = 135.0;
		DirectionUp = -45.0;
		break;

	case "Left":
		Direction = 270.0;
		DirectionUp = 0.0;
		break;

	case "Right":
		Direction = 90.0;
		DirectionUp = 0.0;
		break;

	case "Front":
		Direction = 180.0;
		DirectionUp = 0.0;
		break;

	case "Back":
		Direction = 0.0;
		DirectionUp = 0.0;
		break;

	case "Top":
		Direction = 90.0;
		DirectionUp = -89.999;
		break;

	case "Bottom":
		Direction = 90.0;
		DirectionUp = 89.999;
		break;

	case "Custom":
		Direction = global.stCameraDirection.X;
		DirectionUp = global.stCameraDirection.Y;
		break;
	}
}
