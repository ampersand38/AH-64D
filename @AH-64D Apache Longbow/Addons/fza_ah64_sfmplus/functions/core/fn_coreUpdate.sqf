/* ----------------------------------------------------------------------------
Function: fza_sfmplus_fnc_coreUpdate

Description:
    Updates all of the modules core functions.
    
Parameters:
    _heli - The helicopter to get information from [Unit].

Returns:
    ...

Examples:
    ...

Author:
    BradMick
---------------------------------------------------------------------------- */
params ["_heli"];
#include "\fza_ah64_sfmplus\headers\core.hpp"

if (isGamePaused) exitwith {};
if (CBA_missionTime < 0.1) exitwith {};

private _config      = configFile >> "CfgVehicles" >> typeof _heli;
private _flightModel = getText (_config >> "fza_flightModel");

private _deltaTime   = ["sfmplus_deltaTime"] call BIS_fnc_deltaTime;

if (isAutoHoverOn _heli && _flightModel != "SFMPlus") then {
    _heli action ["AutoHoverCancel", _heli];  
};

//Environment
private _altitude          = _heli getVariable "fza_sfmplus_PA"; //0;     //ft
private _altimeter         = 29.92; //in mg
private _temperature       = _heli getVariable "fza_sfmplus_FAT"; //15;    //deg c 

private _referencePressure = _altimeter * IN_MG_TO_HPA;
private _referenceAltitude = 0;
private _exp               = -GRAVITY * MOLAR_MASS_OF_AIR * (_altitude - _referenceAltitude) / (UNIVERSAL_GAS_CONSTANT * (_temperature + DEG_C_TO_KELVIN));
private _pressure          = ((_referencePressure / 0.01) * (EXP _exp)) * 0.01;

private _densityAltitude   = (_altitude + ((SEA_LEVEL_PRESSURE - _altimeter) * 1000)) + (120 * (_temperature - (STANDARD_TEMP - ((_altitude / 1000) * 2))));
private _dryAirDensity     = (_pressure / 0.01) / (287.05 * (_temperature + DEG_C_TO_KELVIN));

//Input
([_heli, _deltaTime] call fza_sfmplus_fnc_fmc)
    params ["_attHoldCycPitchOut", "_attHoldCycRollOut", "_hdgHoldPedalYawOut", "_altHoldCollOut"];
[_heli, _deltaTime, _attHoldCycPitchOut, _attHoldCycRollOut] call fza_sfmplus_fnc_getInput;

//Weight
private _emptyMass = 0;
if (_heli animationPhase "fcr_enable" == 1) then {
    _emptyMass = _heli getVariable "fza_sfmplus_emptyMassFCR";
} else {
    _emptyMass = _heli getVariable "fza_sfmplus_emptyMassNonFCR";
};
private _maxTotFuelMass = _heli getVariable "fza_sfmplus_maxTotFuelMass";
private _fwdFuelMass    = [_heli] call fza_sfmplus_fnc_fuelSet select 0;
private _ctrFuelMass    = [_heli] call fza_sfmplus_fnc_fuelSet select 1;
private _aftFuelMass    = [_heli] call fza_sfmplus_fnc_fuelSet select 2;

//Performance
[_heli] call fza_sfmplus_fnc_perfData;

//Engines
[_heli, _deltaTime] call fza_sfmplus_fnc_engineController;

if (_flightModel != "SFMPlus") then {
    //Main Rotor
    [_heli, _deltaTime, _altitude, _temperature, _dryAirDensity, _attHoldCycPitchOut, _attHoldCycRollOut, _altHoldCollOut] call fza_sfmplus_fnc_simpleRotorMain;
    //Tail Rotor
    [_heli, _deltaTime, _altitude, _temperature, _dryAirDensity, _hdgHoldPedalYawOut] call fza_sfmplus_fnc_simpleRotorTail;
    //Drag
    [_heli, _deltaTime, _altitude, _temperature, _dryAirDensity] call fza_sfmplus_fnc_fuselageDrag;

    //Vertical fin
    private _vertFinPosition   = [0.0, -6.40, -1.75];
    private _vertFinSweep      = -1.2;
    private _vertFinRot        = 7.5;
    private _vertFinDimensions = [2.25, 0.90];
    [_heli, _deltaTime, _dryAirDensity, 1, _vertFinPosition, _vertFinSweep, _vertFinDimensions, _vertFinRot] call fza_sfmplus_fnc_aeroWing;
};

//Fuel
private _apuFF_kgs  = _heli getVariable "fza_systems_apuFF_kgs";
private _eng1FF = _heli getVariable "fza_sfmplus_engFF" select 0;
private _eng2FF = _heli getVariable "fza_sfmplus_engFF" select 1;
private _curFuelFlow = 0;

_curFuelFlow = (_apuFF_kgs + _eng1FF + _eng2FF) * _deltaTime;

private _totFuelMass  = _fwdFuelMass + _ctrFuelMass + _aftFuelMass;
_totFuelMass          = _totFuelMass - _curFuelFlow;
private _armaFuelFrac = _totFuelMass / _maxTotFuelMass;
if (local _heli) then {
    _heli setFuel _armaFuelFrac;
};

//Pylons
private _pylonMass = 0;
{
    _x params ["_magName","", "_magAmmo"];
    private _magConfig    = configFile >> "cfgMagazines" >> _magName;
    private _magMaxWeight = getNumber (_magConfig >> "weight");
    private _magMaxAmmo   = getNumber (_magConfig >> "count");
    _pylonMass = _pylonMass + linearConversion [0, _magMaxAmmo, _magAmmo, 0, _magMaxWeight];
} foreach magazinesAllTurrets _heli;

private _curMass = _emptyMass + _totFuelMass + _pylonMass; //GWT * 0.453592;
if (local _heli) then {
    _heli setMass _curMass;
};
_heli setVariable ["fza_sfmplus_GWT", _curMass];

//Damage
[_heli, _deltaTime] call fza_sfmplus_fnc_damageApply;

//Stabilator
if(fza_ah64_sfmPlusStabilatorEnabled == STABILATOR_MODE_ALWAYSENABLED 
    || fza_ah64_sfmPlusStabilatorEnabled == STABILATOR_MODE_JOYSTICKONLY && !fza_ah64_sfmPlusKeyboardOnly) then {
    [_heli, _deltaTime] call fza_sfmplus_fnc_aeroStabilator;
};

#ifdef __A3_DEBUG_
/*
(_heli call BIS_fnc_getPitchBank)
    params ["_pitch", "_roll"];

hintsilent format ["Pitch =%1
                    \nRoll = %2", _pitch toFixed 0, _roll toFixed 0];

hintsilent format ["v0.11
                    \nEngine 1 Ng = %1
                    \nEngine 1 TQ = %2
                    \nEngine 1 TGT = %3
                    \n------------------
                    \nEngine 2 Ng = %4
                    \nEngine 2 TQ = %5
                    \nEngine 2 TGT = %6
                    \n------------------
                    \nEng State = %7
                    \nIs Single Engine? = %8
                    \nPercent NP = %9
                    \nEng Power Lever = %10;
                    \n-------------------
                    \nColl Pos = %11
                    \nEng FF = %12
                    \nEngine Base NG = %13",
                    _heli getVariable "fza_sfmplus_engPctNG" select 0, 
                    _heli getVariable "fza_sfmplus_engPctTQ" select 0, 
                    _heli getVariable "fza_sfmplus_engTGT" select 0,
                    _heli getVariable "fza_sfmplus_engPctNG" select 1, 
                    _heli getVariable "fza_sfmplus_engPctTQ" select 1, 
                    _heli getVariable "fza_sfmplus_engTGT" select 1,
                    _heli getVariable "fza_sfmplus_engState",
                    _heli getVariable "fza_sfmplus_isSingleEng",
                    _heli getVariable "fza_sfmplus_engPctNP",
                    _heli getVariable "fza_sfmplus_engPowerLeverState",
                    fza_sfmplus_collectiveOutput,
                    _heli getVariable "fza_sfmplus_engFF",
                    _heli getVariable "fza_sfmplus_engBaseNG"];
*/
#endif