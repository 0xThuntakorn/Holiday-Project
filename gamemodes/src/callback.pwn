GivePlayerMoneyEx(playerid, value)
{
	playerData[playerid][pMoney] += value;
	GivePlayerMoney(playerid, value);
	return 1;
}

UpdatePlayerRegister(playerid)
{
    new query[256];
    mysql_format(g_SQL, query, sizeof query, "UPDATE `players` SET `playerGender` = %d, `playerBirthday` = '%s', `playerTutorial` = %d WHERE `ID` = %d LIMIT 1",
    playerData[playerid][pGender], playerData[playerid][pBirthday], playerData[playerid][pTutorial], playerData[playerid][ID]);
    mysql_tquery(g_SQL, query);
    return 1;
}

ShowDialog_Tutorial(playerid)
{
    for(new i = 0; i != 8; i++)
    {
        TextDrawHideForPlayer(playerid, Login[i]);
    }	
    new string[256];
    format(string, sizeof(string), "{ffffff}กรุณาเลือกเพศของท่าน\n\nกดปุ่ม -{00ff00}[ชาย] {ffffff} = เพศชาย\nกดปุ่ม -{ff0000}[หญิง] {ffffff}= เพศหญิง");
    Dialog_Show(playerid, DIALOG_GENDER, DIALOG_STYLE_MSGBOX, "[เลือกเพศ]",string, "ชาย", "หญิง");
    return 1;
}

GetPlayerNameEx(playerid)
{
    new string[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, string, sizeof(string));
    return string;
}
/*--> เปิดเมื่อต้องการใช้
ClearPlayerChat(playerid, lines)
{
	for(new i = 0; i <= lines; i++)
	{
	    SendClientMessage(playerid, COLOR_WHITE, "");
	}
	return 1;
}
*/
SendClientMessageEx(playerid, color, const text[], {Float, _}:...)
{
	static
	    args,
	    str[144];

	/*
     *  Custom function that uses #emit to format variables into a string.
     *  This code is very fragile; touching any code here will cause crashing!
	*/
	if ((args = numargs()) == 3)
	{
	    SendClientMessage(playerid, color, text);
	}
	else
	{
		while (--args >= 3)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit PUSH.S 8
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessage(playerid, color, str);

		#emit RETN
	}
	return 1;
}

SendAdminMessage(color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 8)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 8); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        foreach (new i : Player)
		{
			if (playerData[i][pAdministrator] >= 1) {
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
	foreach (new i : Player)
	{
		if (playerData[i][pAdministrator] >= 1) {
			SendClientMessage(i, color, str);
		}
	}
	return 1;
}


SendPlayerToPlayer(playerid, targetid)
{
	new
	    Float:x,
	    Float:y,
	    Float:z;

	GetPlayerPos(targetid, x, y, z);

	if (IsPlayerInAnyVehicle(playerid))
	{
	    SetVehiclePos(GetPlayerVehicleID(playerid), x, y + 2, z);
		LinkVehicleToInterior(GetPlayerVehicleID(playerid), GetPlayerInterior(targetid));
	}
	else
		SetPlayerPos(playerid, x + 1, y, z);

	SetPlayerInterior(playerid, GetPlayerInterior(targetid));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));
}

SetPlayerMoneyEx(playerid, amount)
{
	ResetPlayerMoney(playerid);
	playerData[playerid][pMoney] = amount;
	GivePlayerMoney(playerid, amount);
	return 1;
}

FormatMoney(number, const prefix[] = "$")
{
	static
		value[32],
		length;

	format(value, sizeof(value), "%d", (number < 0) ? (-number) : (number));

	if ((length = strlen(value)) > 3)
	{
		for (new i = length, l = 0; --i >= 0; l ++) {
		    if ((l > 0) && (l % 3 == 0)) strins(value, ",", i + 1);
		}
	}
	if (prefix[0] != 0)
	    strins(value, prefix, 0);

	if (number < 0)
		strins(value, "-", 0);

	return value;
}

IsPlayerSpawnedEx(playerid)
{
	if (playerid < 0 || playerid >= MAX_PLAYERS)
	    return 0;

	return (GetPlayerState(playerid) != PLAYER_STATE_SPECTATING && GetPlayerState(playerid) != PLAYER_STATE_NONE && GetPlayerState(playerid) != PLAYER_STATE_WASTED);
}