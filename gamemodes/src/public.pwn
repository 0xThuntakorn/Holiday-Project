#include <YSI_Coding/y_hooks>


public OnGameModeInit()
{
    //--> MySQL R41-4
	new MySQLOpt: option_id = mysql_init_options();
	mysql_set_option(option_id, AUTO_RECONNECT, true); 
	g_SQL = mysql_connect(MYSQL_HOSTNAME, MYSQL_USERNAME, MYSQL_PASSWORD, MYSQL_DATABASE, option_id);
	if (g_SQL == MYSQL_INVALID_HANDLE || mysql_errno(g_SQL) != 0)
	{
		print("MYSQL ERROR : SERVER OFF");
		SendRconCommand("exit"); 
		return 1;
	}
	print("MySQL connection is successful.");

    SendRconCommand("hostname "GM_HOST_NAME"");
    SetGameModeText(GM_VERSION);

	LoadTextdrawLogin();
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	gPlayerAccount[playerid] = 0;	
	gPlayerLogged[playerid] = 0;

	InterpolateCameraPos(playerid, 1849.279663, -1173.270019, 49.163814, 1899.455566, -1171.870727, 33.920963, 11000);
	InterpolateCameraLookAt(playerid, 1854.062133, -1173.136596, 47.710987, 1904.238037, -1171.737304, 32.468135, 1000);

	ShowTextDrawLogin(playerid);	
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	playerData[playerid][LoggenIn] = false;	
    SavePlayer(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(playerData[playerid][pTutorial] == 0)
	{
        playerData[playerid][pPos_X] = 1.808619;
        playerData[playerid][pPos_Y] = 32.384357;
        playerData[playerid][pPos_Z] = 1199.593750;
        playerData[playerid][pPos_A] = 0.0;
        playerData[playerid][pInterior] = 1;
		SetPlayerInterior(playerid, playerData[playerid][pInterior]);
		SetPlayerVirtualWorld(playerid, playerData[playerid][pWorld]);
		SetPlayerPos(playerid, playerData[playerid][pPos_X], playerData[playerid][pPos_Y], playerData[playerid][pPos_Z]);
		SetPlayerFacingAngle(playerid, playerData[playerid][pPos_A]);
		ShowDialog_Tutorial(playerid);
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if (GetPlayerMoney(playerid) != playerData[playerid][pMoney])
	{
	    ResetPlayerMoney(playerid);
	    GivePlayerMoney(playerid, playerData[playerid][pMoney]);
	}
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	AccountCheck(playerid);
	SelectTextDraw(playerid,0xFF0000FF);
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if (clickedid == Login[1])
	{
		Dialog_Show(playerid,DIALOG_ENTER_USER,DIALOG_STYLE_INPUT,"ล็อกอิน","---[ GTA:HOLIDAY ]---\nยินดีต้อนรับเข้าสู่ SERVER!\nกรุณา*กรอกชื่อผู้ใช้*","ล็อกอิน","ออก");
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
		return 1;
	}
    if (clickedid == Login[2])
    {
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
		Dialog_Show(playerid,DIALOG_REGISTER_USER,DIALOG_STYLE_INPUT,"สมัครสมาชิก","---[ GTA:HOLIDAY ]---\nยินดีต้อนรับเข้าสู่ SERVER!\nกรุณา*สร้างชื่อผู้ใช้*","ยืนยัน","ออก");
		return 1;
    }
    return 0;
}

public OnModelSelectionResponse(playerid, extraid, index, modelid, response)
{
	if ((response) && (extraid == MODEL_SELECTION_CLOTHES))
	{
	    playerData[playerid][pSkin] = modelid;
     	SetPlayerSkin(playerid, modelid);
	}
	return 1;
}
