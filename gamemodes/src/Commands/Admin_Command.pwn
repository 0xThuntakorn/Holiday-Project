public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if (playerData[playerid][pAdministrator] >= 6)
	{
    	SetPlayerPosFindZ(playerid, fX, fY, fZ+5);
	}
    return 1;
}

alias:setadmin("ให้แอดมิน")
CMD:setadmin(playerid, params[])
{
    if(playerData[playerid][pAdministrator] > 5)
    {
    	new userid, level;
        if(sscanf(params, "ud", userid, level))
			return SendClientMessage(playerid, COLOR_WHITE, "/setadmin [ไอดี/ชื่อ] [เลเวล]");

        if(userid == INVALID_PLAYER_ID)
			return SendClientMessage(playerid, COLOR_RED, "[ระบบ] {FFFFFF}ผู้เล่นไอดีนี้ไม่ได้อยู่ในเกม");

        playerData[userid][pAdministrator] = level;

        SendAdminMessage(COLOR_ADMIN, "AdmLog: %s ได้ปรับเลเวลแอดมินให้กับ %s(%d) เป็นแอดมินเลเวล %d", GetPlayerNameEx(playerid), GetPlayerNameEx(userid), userid, level);
	}
    return 1;
}

alias:givemoney("เสกเงิน")
CMD:givemoney(playerid, params[])
{
    if(playerData[playerid][pAdministrator] >= 6)
    {
    	new userid, amount;
        if(sscanf(params, "ud", userid, amount))
			return SendClientMessage(playerid, COLOR_WHITE, "/givemoney [ไอดี/ชื่อ] [จำนวน]");

        if(userid == INVALID_PLAYER_ID)
			return SendClientMessage(playerid, COLOR_RED, "[ระบบ] {FFFFFF}ผู้เล่นไอดีนี้ไม่ได้อยู่ในเกม");

        GivePlayerMoneyEx(userid, amount);

        SendAdminMessage(COLOR_ADMIN, "AdmLog: %s ได้ให้เงินกับ %s(%d) จำนวน %s", GetPlayerNameEx(playerid), GetPlayerNameEx(userid), userid, FormatMoney(amount));
	}
    return 1;
}

CMD:setmoney(playerid, params[])
{
    if(playerData[playerid][pAdministrator] >= 6)
    {
    	new userid, amount;
        if(sscanf(params, "ud", userid, amount))
			return SendClientMessage(playerid, COLOR_WHITE, "/setmoney [ไอดี/ชื่อ] [จำนวน]");

        if(userid == INVALID_PLAYER_ID)
			return SendClientMessage(playerid, COLOR_RED, "[ระบบ] {FFFFFF}ผู้เล่นไอดีนี้ไม่ได้อยู่ในเกม");

        SetPlayerMoneyEx(userid, amount);

        SendAdminMessage(COLOR_ADMIN, "AdmLog: %s ได้ปรับเงินให้กับ %s(%d) เหลือจำนวน %s", GetPlayerNameEx(playerid), GetPlayerNameEx(userid), userid, FormatMoney(amount));
	}
    return 1;
}

alias:bring("ดึง")
CMD:bring(playerid, params[])
{
	static
	    userid;

	if (playerData[playerid][pAdministrator] < 1)
	    return 1;

	if (sscanf(params, "u", userid))
     	return SendClientMessage(playerid, COLOR_WHITE, "/bring [ไอดี/ชื่อ]");

    if (userid == INVALID_PLAYER_ID)
	    return SendClientMessage(playerid, COLOR_RED, "[ระบบ] {FFFFFF}ผู้เล่นไอดีนี้ไม่ได้อยู่ในเกม");

	if (!IsPlayerSpawnedEx(userid))
		return SendClientMessage(playerid, COLOR_RED, "[ระบบ] {FFFFFF}ผู้เล่นไอดีนี้ยังไม่ได้อยู่ในสถานะปกติ");

	SendPlayerToPlayer(userid, playerid);
	SendClientMessageEx(playerid, COLOR_SERVER, "คุณได้ดึงผู้เล่น %s มาหา", GetPlayerNameEx(userid));
	return 1;
}

alias:goto("ไปหา")
CMD:goto(playerid, params[])
{
	static
	    id,
	    type[24],
		string[64];

	if (playerData[playerid][pAdministrator] < 1)
	    return 1;

	if (sscanf(params, "u", id))
 	{
	 	SendClientMessage(playerid, COLOR_WHITE, "/goto [ไอดี/ชื่อ]");
		SendClientMessage(playerid, COLOR_YELLOW, "[ชื่อรายการ]:{FFFFFF} entrance, interior");
		return 1;
	}
    if (id == INVALID_PLAYER_ID)
	{
	    if (sscanf(params, "s[24]S()[64]", type, string))
		{
		 	SendClientMessage(playerid, COLOR_WHITE, "/goto [ไอดี/ชื่อ]");
			return 1;
	    }
	    else return SendClientMessage(playerid, COLOR_RED, "[ระบบ] {FFFFFF}ผู้เล่นไอดีนี้ไม่ได้อยู่ในเกม");
	}
	if (!IsPlayerSpawnedEx(id))
		return SendClientMessage(playerid, COLOR_RED, "[ระบบ] {FFFFFF}ผู้เล่นไอดีนี้ยังไม่ได้อยู่ในสถานะปกติ");

	SendPlayerToPlayer(playerid, id);

	format(string, sizeof(string), "You have ~y~teleported~w~ to %s.", GetPlayerNameEx(id));
	GameTextForPlayer(playerid, string, 5000, 1);

	return 1;
}
