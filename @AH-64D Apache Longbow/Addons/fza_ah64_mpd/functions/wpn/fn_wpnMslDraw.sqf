params["_heli", "_mpdIndex", "_state"];
#include "\fza_ah64_mpd\headers\mfdConstants.h"

private _missileInventory = [_heli] call fza_fnc_weaponMissileInventory;
private _curAmmo = getText (configFile >> "CfgWeapons" >> _heli getVariable "fza_ah64_selectedMissile" >> "fza_ammoType");
private _selectedMsl = [_missileInventory, _curAmmo] call fza_fnc_weaponMissileGetSelected;
private _seekerType = getText (configFile >> "CfgAmmo" >> _curAmmo >> "fza_salType");

_heli setUserMfdValue [MFD_INDEX_OFFSET(MFD_IND_WPN_SELECTED_HF), _selectedMsl + 1];
_heli setUserMfdValue [MFD_INDEX_OFFSET(MFD_IND_WPN_MSL_SELECTED_TYPE), [0,1] select (_seekerType == "rf")];
_heli setUserMfdValue[MFD_INDEX_OFFSET(MFD_IND_WPN_MSL_MENU), _state get "variant"];

if (_seekerType != "rf") then { //Sal1, sal2
    private _pri = _heli getVariable "fza_ah64_laserMissilePrimaryCode";
    private _alt = _heli getVariable "fza_ah64_laserMissileAlternateCode";
    private _chanCodes = _heli getVariable "fza_ah64_laserChannelCodes";
    private _priCode = "";
    private _altCode = "";
    private _textLine1 = "L";
    private _textLine2 = "S";

    if !(_pri == -1) then {
        _priCode = _chanCodes # _pri;
        private _lasePos = [_heli] call fza_hellfire_fnc_salLasePos;
        if !isNil "_lasePos" then {
            _textLine1 = toUpper _priCode;
            _textLine2 = "T";
        } else {
            _textLine1 = toUpper _priCode;
            _textLine2 = "R";
        };
    };
    if !(_alt == -1) then {
        _altCode = _chanCodes # _alt;
    };
    
    _heli setUserMfdText[MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_MSL_PRI_CODE), _priCode + " PRF"];
    _heli setUserMfdText[MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_MSL_ALT_CODE), _altCode + " PRF"];
    _heli setUserMfdValue[MFD_INDEX_OFFSET(MFD_IND_WPN_SELECTED_PRI_CH), _pri + 1];
    _heli setUserMfdValue[MFD_INDEX_OFFSET(MFD_IND_WPN_SELECTED_ALT_CH), _alt + 1];
    _heli setUserMfdText [MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_MSL_CHAN_1_CODE), _chanCodes # 0];
    _heli setUserMfdText [MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_MSL_CHAN_2_CODE), _chanCodes # 1];
    _heli setUserMfdText [MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_MSL_CHAN_3_CODE), _chanCodes # 2];
    _heli setUserMfdText [MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_MSL_CHAN_4_CODE), _chanCodes # 3];
    _heli setUserMfdText [MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_MSL_SAL_SEL), toUpper _seekerType];
    _heli setUserMfdText [MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_MSL_TRAJ), toUpper (_heli getVariable "fza_ah64_hellfireTrajectory")];    
    _heli setUserMfdText [MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_MSL_IMAGE_LINE_1), _textLine1];
    _heli setUserMfdText [MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_MSL_IMAGE_LINE_2), _textLine2];
    _this call fza_mpd_fnc_WpnTrajDraw;
};

if (_seekerType == "rf") then { //RF
	_heli getVariable "fza_ah64_fcrNts" params ["_ntsObj", "_ntsPos"];
    _indicateLobl = ([_heli, [_ntsPos, "", speed _ntsObj, _ntsObj]] call fza_hellfire_fnc_limaLoblCheck) # 1;
    if (_indicateLobl && !isNull _ntsObj)  then {
        _heli setUserMfdText [MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_MSL_IMAGE_LINE_1), ""];
        _heli setUserMfdText [MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_MSL_IMAGE_LINE_2), "T"];
    } else {
        _heli setUserMfdText [MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_MSL_IMAGE_LINE_1), ""];
        _heli setUserMfdText [MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_MSL_IMAGE_LINE_2), "R"];
    };
};