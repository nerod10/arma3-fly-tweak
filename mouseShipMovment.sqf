
XWing = _this select 0;
hint "STARTING";
TAG_LShift = false;
TAG_Z = false;
_maxPitchAngle = 30; //for capital ships, this should be ~30
_speed=1;
_speedAcceleration = 0.02; //for capital ships, this should be ~0.02
_maxSpeed = 2;
_turnSpeedacceleration = 0.05;
_maxTurnSpeed = 180;
_maxPithcTurnSpeed = 5;
_yaw = getDir XWing;
_maxYaw = 360;
_pitchTruenSpeedFactor = 1;
_pitch = 0;
_roll = 0;
_maxRoll = 20; //for capital ships, this should be 20
XPosition = 0;
YPosition = 0;
invertY = true;
_fire = false;
_fireWeapon = str (weaponsItems XWing select 0 select 0);

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
			_ypos = _ypos + 1.2; //move y
		};
		XPosition = _xpos-0.5;
		YPosition = _ypos;
		// if the ship is upside down, invert the roll and pitch
		if (_pitch > 90) then {
			_roll = -XPosition * _maxRoll;
			_pitch = 180 - _pitch;
		};
		if (_pitch < -90) then {
			_roll = XPosition * _maxRoll;
			_pitch = -180 - _pitch;
		};

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
		[XWing, toString [_fireWeapon]] call BIS_fnc_fire;
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

	//yaw
	_yaw = _yaw + _turnSpeedacceleration * _roll;
	if (_yaw > _maxYaw) then {_yaw = _maxYaw;};
	if (_yaw < -_maxYaw) then {_yaw = -_maxYaw;};

	//roll
	//if the ship is upside down, invert the roll
	if (_pitch > 90) then {_roll = -XPosition * _maxRoll;};
	if (_pitch < -90) then {_roll = XPosition * _maxRoll;};
	if (_pitch < 90 && _pitch > -90) then {_roll = XPosition * _maxRoll;};
	if (_roll > _maxRoll) then {_roll = _maxRoll;};
	if (_roll < -_maxRoll) then {_roll = -_maxRoll;};
	
	//set position
	XWing setVectorDirAndUp [
		[sin _yaw * cos _pitch, cos _yaw * cos _pitch, sin _pitch], 
		[[sin _roll, -sin _pitch, cos _roll * cos _pitch], -_yaw] call BIS_fnc_rotateVector2D 
	]; 
	XWing setPosASL (getPosASL XWing vectorAdd [sin _yaw * cos _pitch * _speed, cos _yaw * cos _pitch * _speed, sin _pitch * _speed]);


	sleep 0.03333; //30fps
}
