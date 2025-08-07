// INITIALIZATION
XWing = _this select 0;
hint "STARTING";

missionNamespace setVariable ["TAG_LShift", false];
missionNamespace setVariable ["TAG_Z", false];
missionNamespace setVariable ["invertY", true];

_maxPitchAngle = 30; // For capital ships, this should be ~30
_speed = 1;
_speedAcceleration = 0.02; // For capital ships, this should be ~0.02
_maxSpeed = 2;

_turnSpeedAcceleration = 0.05;
_maxTurnSpeed = 180;
_maxPitchTurnSpeed = 5;
_pitchTurnSpeedFactor = 1;

_yaw = getDir XWing;
_pitch = 0;
_roll = 0;
_maxRoll = 20; // For capital ships, this should be 20

XPosition = 0;
YPosition = 0;

_fireWeapon = weaponsItems XWing select 0 select 0;

_disp = findDisplay 46 createDisplay "RscDisplayEmpty";

// OPTIONAL: Transparent full-screen background for capturing mouse movement
_ctrl = _disp ctrlCreate ["RscBackground", -1];
_ctrl ctrlSetBackgroundColor [0, 0, 0, 0];
_ctrl ctrlSetPosition [0, 0, 1, 1];
_ctrl ctrlCommit 0;
ctrlSetFocus _ctrl;

// MOUSE MOVEMENT EVENT HANDLER
_disp displayAddEventHandler ["MouseMoving", {
	if (alive player) then {
		private _invertY = missionNamespace getVariable ["invertY", false];
		getMousePosition params ["_xpos", "_ypos"];

		if (_invertY) then {
			_ypos = -_ypos + 1.2;
		};

		missionNamespace setVariable ["XPosition", _xpos - 0.5];
		missionNamespace setVariable ["YPosition", _ypos];
	};
}];

// KEYBOARD HANDLERS
_disp displayAddEventHandler ["KeyDown", {
	private _key = _this select 1;
	if (_key == 16) then { missionNamespace setVariable ["TAG_LShift", true]; };
	if (_key == 44) then { missionNamespace setVariable ["TAG_Z", true]; };
}];

_disp displayAddEventHandler ["KeyUp", {
	private _key = _this select 1;
	if (_key == 16) then { missionNamespace setVariable ["TAG_LShift", false]; };
	if (_key == 44) then { missionNamespace setVariable ["TAG_Z", false]; };
}];

// FIRE HANDLER
_disp displayAddEventHandler ["MouseButtonDown", {
	private _button = _this select 1;
	if (_button == 0) then {
		[XWing, _fireWeapon] call BIS_fnc_fire;
	};
}];

// MAIN LOOP
while { alive player } do {
	private _shift = missionNamespace getVariable ["TAG_LShift", false];
	private _zKey = missionNamespace getVariable ["TAG_Z", false];
	private _xPos = missionNamespace getVariable ["XPosition", 0];
	private _yPos = missionNamespace getVariable ["YPosition", 0.5];

	// Speed control
	if (_shift) then { _speed = _speed + _speedAcceleration; };
	if (_zKey) then { _speed = _speed - _speedAcceleration; };
	_speed = [_speed, 0, _maxSpeed] call BIS_fnc_clamp;

	// Pitch control
	private _pitchSpeed = _maxPitchTurnSpeed * (_yPos - 0.5);
	_pitchSpeed = [_pitchSpeed, -_maxPitchTurnSpeed, _maxPitchTurnSpeed] call BIS_fnc_clamp;
	_pitch = _pitch + _pitchSpeed * _pitchTurnSpeedFactor;
	_pitch = [_pitch, -_maxPitchAngle, _maxPitchAngle] call BIS_fnc_clamp;

	// Roll logic (simplified)
	if (_pitch > 90) then {
		_roll = -_xPos * _maxRoll;
	} else {
		_roll = _xPos * _maxRoll;
	};
	_roll = [_roll, -_maxRoll, _maxRoll] call BIS_fnc_clamp;

	// Yaw control
	_yaw = _yaw + _turnSpeedAcceleration * _roll;
	if (_yaw > 360) then { _yaw = 0; };
	if (_yaw < 0) then { _yaw = 360; };

	// Movement: Apply new vector direction and move forward
	private _dir = [sin _yaw * cos _pitch, cos _yaw * cos _pitch, sin _pitch];
	private _up = [[sin _roll, -sin _pitch, cos _roll * cos _pitch], -_yaw] call BIS_fnc_rotateVector2D;

	XWing setVectorDirAndUp [_dir, _up];
	XWing setPosASL (getPosASL XWing vectorAdd [_dir select 0 * _speed, _dir select 1 * _speed, _dir select 2 * _speed]);

	sleep 0.0333; // ~30 FPS
};
