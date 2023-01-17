
_plane = _this select 0;
hint "STARTING";
TAG_LShift = false;
TAG_Z = false;
_maxPitchAngle = 180;
_speed=1;
_speedAcceleration = 0.1;
_maxSpeed = 2;
_turnSpeedacceleration = 0.1;
_maxTurnSpeed = 180;
_maxPithcTurnSpeed = 5;
_yaw = getDir _plane;
_pitchTruenSpeedFactor = 1;
_pitch = 0;
_roll = 0;
_maxRoll = 40;
XPosition = 0;
YPosition = 0;
invertY = true;
_fire = false;
_fireWeapon = str (weaponsItems _plane select 0 select 0);

_disp = findDisplay 46 createDisplay "RscDisplayEmpty";
_ctrl = _disp ctrlCreate ["RscBackground", -1];
_ctrl ctrlSetBackgroundColor [0, 0, 0, 0];
_ctrl ctrlSetPosition [0, 0, 1, 1];
_ctrl ctrlCommit 0;
ctrlSetFocus _ctrl;

_disp displayAddEventHandler ["MouseMoving", {
	if (alive player) then {
		getMousePosition params ["_xpos","_ypos"]; //get mouse position
		if (invertY) then {
			_ypos = _ypos * -1; //invert y
			_ypos = _ypos + 1.4; //move y
		};

		XPosition = _xpos;
		YPosition = _ypos;
	}
}];

_disp displayAddEventHandler ["KeyDown", 
{
	_keyPress = _this select 1;
	if (_keyPress == 16) then {TAG_LShift=true;};
	if (_keyPress == 44) then {TAG_Z=true;};
}];
_disp displayAddEventHandler ["KeyUp", 
{
	_keyPress = _this select 1;
	if (_keyPress == 16) then {TAG_LShift=false;};
	if (_keyPress == 44) then {TAG_Z=false;};
}];
//fire
_disp displayAddEventHandler ["MouseButtonDown", 
{
	_keyPress = _this select 1;
	
	if (_keyPress == 0) then {
		[_plane, "JMSLLTE_va_LS1_TIE_cannon"] call BIS_fnc_fire; //"JMSLLTE_va_LS1_TIE_cannon"
	};
}];

while {alive player} do {
	//movment:
	//speed
	if (TAG_LShift) then {_speed = _speed + _speedAcceleration;}; 
	if (TAG_Z) then {_speed = _speed - _speedAcceleration;}; 
	if (_speed > _maxSpeed) then {_speed = _maxSpeed;};
	if (_speed < 0) then {_speed = 0;};

	//pitch
	_pitchTruenSpeed = _maxPithcTurnSpeed * (YPosition - 0.5);
	if (_pitchTruenSpeed > _maxPithcTurnSpeed) then {_pitchTruenSpeed = _maxPithcTurnSpeed;};
	if (_pitchTruenSpeed < -_maxPithcTurnSpeed) then {_pitchTruenSpeed = -_maxPithcTurnSpeed;};
	_pitch = _pitch + _pitchTruenSpeed * _pitchTruenSpeedFactor;
	if (_pitch > _maxPitchAngle) then {_pitch = _maxPitchAngle;};
	if (_pitch < -_maxPitchAngle) then {_pitch = -_maxPitchAngle;};

	//roll
	_roll = _maxRoll * (XPosition - 0.5);
	if (_roll > _maxRoll) then {_roll = _maxRoll;};
	if (_roll < -_maxRoll) then {_roll = -_maxRoll;};
	//yaw
	_yaw = _yaw + _turnSpeedacceleration * _roll;
	if (_yaw > 360) then {_yaw = _yaw - 360;};
	if (_yaw < 0) then {_yaw = _yaw + 360;};
	//set position
	_plane setVectorDirAndUp [
		[sin _yaw * cos _pitch, cos _yaw * cos _pitch, sin _pitch], 
		[[sin _roll, -sin _pitch, cos _roll * cos _pitch], -_yaw] call BIS_fnc_rotateVector2D 
	]; 
	_plane setPosASL (getPosASL _plane vectorAdd [sin _yaw * cos _pitch * _speed, cos _yaw * cos _pitch * _speed, sin _pitch * _speed]);


	sleep 0.03333; //30fps
}
