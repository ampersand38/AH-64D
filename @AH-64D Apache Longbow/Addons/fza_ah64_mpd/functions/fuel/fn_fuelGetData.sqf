params ["_heli"];

#define KGTOLBS 2.20462
#define FUEL_FLOW_LBS_PER_HOUR 7936.64;

private _forwardCellWeight   = [_heli] call fza_sfmplus_fnc_fuelSet select 0;
private _ctrFuelWeight       = [_heli] call fza_sfmplus_fnc_fuelSet select 1;
private _aftCellWeight       = [_heli] call fza_sfmplus_fnc_fuelSet select 2;
private _mainFuelCellWeight  = _forwardCellWeight + _aftCellWeight;
private _totalFuelCellWeight = _forwardCellWeight + _ctrFuelWeight + _aftCellWeight;
_forwardCellWeight   = _forwardCellWeight * KGTOLBS;
_ctrFuelWeight       = _ctrFuelWeight * KGTOLBS;
_aftCellWeight       = _aftCellWeight * KGTOLBS;
_mainFuelCellWeight  = _mainFuelCellWeight * KGTOLBS;
_totalFuelCellWeight = _totalFuelCellWeight * KGTOLBS;

private _eng1FF = _heli getVariable "fza_sfmplus_engFF" select 0;
private _eng2FF = _heli getVariable "fza_sfmplus_engFF" select 1;

private _eng1FuelCons = 0;
private _eng1State    = _heli getVariable "fza_sfmplus_engState" select 0;
if (_eng1State == "ON") then {
    _eng1FuelCons = _eng1FF * FUEL_FLOW_LBS_PER_HOUR;
} else {
    _eng1FuelCons = 0;
};

private _eng2FuelCons = 0;
private _eng2State    = _heli getVariable "fza_sfmplus_engState" select 1;
if (_eng2State == "ON") then {
    _eng2FuelCons = _eng2FF * FUEL_FLOW_LBS_PER_HOUR;
} else {
    _eng2FuelCons = 0;
};
//private _totalFuelConsumption  = _engineFuelConsumption # 0 + _engineFuelConsumption # 1;
private _totalFuelConsumption = _eng1FuelCons + _eng2FuelCons;

private _mainEnduranceNumber = if(_totalFuelConsumption > 0) then {
    private _enduranceTotal = 540 min (_mainFuelCellWeight / _totalFuelConsumption * 60); //Minutes
    private _enduranceMinutes = _enduranceTotal % 60;
    private _enduranceHours = floor(_enduranceTotal / 60);
    format["%1:%2", _enduranceHours toFixed 0, [_enduranceMinutes, 2] call CBA_fnc_formatNumber];
} else {"9:99"};

private _totalEnduranceNumber = if(_totalFuelConsumption > 0) then {
    private _enduranceTotal = 540 min (_totalFuelCellWeight / _totalFuelConsumption * 60); //Minutes
    private _enduranceMinutes = _enduranceTotal % 60;
    private _enduranceHours = floor(_enduranceTotal / 60);
    format["%1:%2", _enduranceHours toFixed 0, [_enduranceMinutes, 2] call CBA_fnc_formatNumber];
} else {"9:99"};

[_forwardCellWeight, _ctrFuelWeight, _aftCellWeight, _mainFuelCellWeight, _totalFuelCellWeight, _eng1FuelCons, _eng2FuelCons, _totalFuelConsumption, _mainEnduranceNumber, _totalEnduranceNumber]