/* ----------------------------------------------------------------------------
Function: fza_customise_fnc_remove

Description:
    Remove the component to the apache

Parameters:
    _target - The apache
    _player - The player
    _targetcomp - desired components to remove

Returns:
    Nothing

Examples:

Author:
    Snow(Dryden)
---------------------------------------------------------------------------- */
params ["_target","_player","_targetComp"];

if (_targetComp == "FCR") exitwith {
    [
        300,
        [_target, _player],
        {
            params ["_args"];
            _args params ["_target", "_player"];
            _target animateSource ["fcr_enable", 0];
            private _object = "fza_ah64_FireControlRadar" createVehicle [0,0,0];
            [_player, _object] call ace_dragging_fnc_carryObject;
        },
        {},
        localize "STR_A3_MP_GroundSupport_ProgressBar_LoadingGroup",
        {
            params ["_args"];
            _args params ["_target", "_player"];
            if (_player distance _target > 10 ) exitWith {false};
            true;
        },
        ["isNotInside"]
    ] call ace_common_fnc_progressBar;
};