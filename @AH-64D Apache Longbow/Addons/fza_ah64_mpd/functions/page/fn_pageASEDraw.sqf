#include "\fza_ah64_dms\headers\constants.h"
#include "\fza_ah64_mpd\headers\mfdConstants.h"
#include "\fza_ah64_controls\headers\wcaConstants.h"
#include "\fza_ah64_controls\headers\systemConstants.h"
params ["_heli", "_mpdIndex"];

//Chaff + Flares
private _chaffState = BOOLTONUM(_heli getVariable "fza_ah64_ase_chaffState" == "Arm");
_heli setUserMfdValue [MFD_INDEX_OFFSET(MFD_IND_ASE_CHAFF_STATE), _chaffState];
private _chaffCount = 0;
private _flareCount= 0;
{
    _x params ["_className", "_turretPath", "_ammoCount"];
    if (_className == "30Rnd_CMChaffMagazine" && _turretPath isEqualTo [-1]) then {
        _chaffCount = _chaffCount + _ammoCount;
    };
    if (_className == "60Rnd_CMFlareMagazine" && _turretPath isEqualTo [-1]) then {
        _flareCount= _flareCount+ _ammoCount;
    };
} forEach magazinesAllTurrets _heli;

if (_heli animationPhase "msn_equip_british" == 1) then {
    _heli setUserMfdText  [MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_CMS_QTY), (str (_chaffCount/2)) + "/" + str _FlareCount];
} else {
    _heli setUserMfdText  [MFD_INDEX_OFFSET(MFD_TEXT_IND_WPN_CMS_QTY), (str (_chaffCount/2))];
};

//IR Jammer
private _irJamPwr   = BOOLTONUM(_heli getVariable "fza_ah64_ase_msnEquipPwr" == "off");
_heli setUserMfdValue [MFD_INDEX_OFFSET(MFD_IND_ASE_IRJAM_PWR), _irJamPwr];
private _irJamState = _heli getVariable "fza_ah64_ase_irJamState";
_heli setUserMfdValue [MFD_INDEX_OFFSET(MFD_IND_ASE_IRJAM_STATE), _irJamState];

//Autopage
private _autopage = _heli getVariable "fza_ah64_ase_autopage";
_heli setUserMfdValue [MFD_INDEX_OFFSET(MFD_IND_ASE_AUTOPAGE), _autopage];

//RLWR
private _rlwrPwr = BOOLTONUM(_heli getVariable "fza_ah64_ase_rlwrPwr" == "off");
_heli setUserMfdValue [MFD_INDEX_OFFSET(MFD_IND_ASE_RLWR_PWR), _rlwrPwr];
private _rlwrCount = _heli getVariable "fza_ah64_ase_rlwrCount";
_heli setUserMfdText  [MFD_INDEX_OFFSET(MFD_TEXT_IND_ASE_RLWR_COUNT), _rlwrCount toFixed 0];

//Mission equipment 
_msn_equip_British = _heli animationPhase "msn_equip_british";
_heli setUserMfdValue  [MFD_INDEX_OFFSET(MFD_IND_ASE_BRITISH), _msn_equip_British];

_msn_equip_american = _heli animationPhase "msn_equip_American";
_heli setUserMfdValue  [MFD_INDEX_OFFSET(MFD_IND_ASE_AMERICAN), _msn_equip_american];

//ASE Points
private _pointsArray = [];
private _aseObjects  = _heli getVariable "fza_ah64_ase_rlwrObjects";
private _radius      = 0.27;
{
    _x params ["_state", "_bearing", "_classification"];
    _ident = [_state, _classification] call fza_ase_fnc_rlwrGetIdent;
    _pointsArray pushBack [MPD_POSMODE_SCREEN, [_radius * sin _bearing + 0.5, -_radius * cos _bearing + 0.5, 0.0], "", POINT_TYPE_ASE, _forEachIndex, _ident];
} forEach _aseObjects;

[_heli, _pointsArray, _mpdIndex, 1, [0.5, 0.5]] call fza_mpd_fnc_drawIcons;