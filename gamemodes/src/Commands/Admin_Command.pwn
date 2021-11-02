public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if (playerData[playerid][pAdministrator] >= 6)
	{
    	SetPlayerPosFindZ(playerid, fX, fY, fZ+5);
	}
    return 1;
}

alias:setadmin("����ʹ�Թ")
CMD:setadmin(playerid, params[])
{
    if(playerData[playerid][pAdministrator] > 5)
    {
    	new userid, level;
        if(sscanf(params, "ud", userid, level))
			return SendClientMessage(playerid, COLOR_WHITE, "/setadmin [�ʹ�/����] [�����]");

        if(userid == INVALID_PLAYER_ID)
			return SendClientMessage(playerid, COLOR_RED, "[�к�] {FFFFFF}�������ʹչ��������������");

        playerData[userid][pAdministrator] = level;

        SendAdminMessage(COLOR_ADMIN, "AdmLog: %s ���Ѻ������ʹ�Թ���Ѻ %s(%d) ���ʹ�Թ����� %d", GetPlayerNameEx(playerid), GetPlayerNameEx(userid), userid, level);
	}
    return 1;
}

alias:givemoney("�ʡ�Թ")
CMD:givemoney(playerid, params[])
{
    if(playerData[playerid][pAdministrator] >= 6)
    {
    	new userid, amount;
        if(sscanf(params, "ud", userid, amount))
			return SendClientMessage(playerid, COLOR_WHITE, "/givemoney [�ʹ�/����] [�ӹǹ]");

        if(userid == INVALID_PLAYER_ID)
			return SendClientMessage(playerid, COLOR_RED, "[�к�] {FFFFFF}�������ʹչ��������������");

        GivePlayerMoneyEx(userid, amount);

        SendAdminMessage(COLOR_ADMIN, "AdmLog: %s ������Թ�Ѻ %s(%d) �ӹǹ %s", GetPlayerNameEx(playerid), GetPlayerNameEx(userid), userid, FormatMoney(amount));
	}
    return 1;
}

CMD:setmoney(playerid, params[])
{
    if(playerData[playerid][pAdministrator] >= 6)
    {
    	new userid, amount;
        if(sscanf(params, "ud", userid, amount))
			return SendClientMessage(playerid, COLOR_WHITE, "/setmoney [�ʹ�/����] [�ӹǹ]");

        if(userid == INVALID_PLAYER_ID)
			return SendClientMessage(playerid, COLOR_RED, "[�к�] {FFFFFF}�������ʹչ��������������");

        SetPlayerMoneyEx(userid, amount);

        SendAdminMessage(COLOR_ADMIN, "AdmLog: %s ���Ѻ�Թ���Ѻ %s(%d) ����ͨӹǹ %s", GetPlayerNameEx(playerid), GetPlayerNameEx(userid), userid, FormatMoney(amount));
	}
    return 1;
}

alias:bring("�֧")
CMD:bring(playerid, params[])
{
	static
	    userid;

	if (playerData[playerid][pAdministrator] < 1)
	    return 1;

	if (sscanf(params, "u", userid))
     	return SendClientMessage(playerid, COLOR_WHITE, "/bring [�ʹ�/����]");

    if (userid == INVALID_PLAYER_ID)
	    return SendClientMessage(playerid, COLOR_RED, "[�к�] {FFFFFF}�������ʹչ��������������");

	if (!IsPlayerSpawnedEx(userid))
		return SendClientMessage(playerid, COLOR_RED, "[�к�] {FFFFFF}�������ʹչ���ѧ����������ʶҹл���");

	SendPlayerToPlayer(userid, playerid);
	SendClientMessageEx(playerid, COLOR_SERVER, "�س��֧������ %s ����", GetPlayerNameEx(userid));
	return 1;
}

alias:goto("���")
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
	 	SendClientMessage(playerid, COLOR_WHITE, "/goto [�ʹ�/����]");
		SendClientMessage(playerid, COLOR_YELLOW, "[������¡��]:{FFFFFF} entrance, interior");
		return 1;
	}
    if (id == INVALID_PLAYER_ID)
	{
	    if (sscanf(params, "s[24]S()[64]", type, string))
		{
		 	SendClientMessage(playerid, COLOR_WHITE, "/goto [�ʹ�/����]");
			return 1;
	    }
	    else return SendClientMessage(playerid, COLOR_RED, "[�к�] {FFFFFF}�������ʹչ��������������");
	}
	if (!IsPlayerSpawnedEx(id))
		return SendClientMessage(playerid, COLOR_RED, "[�к�] {FFFFFF}�������ʹչ���ѧ����������ʶҹл���");

	SendPlayerToPlayer(playerid, id);

	format(string, sizeof(string), "You have ~y~teleported~w~ to %s.", GetPlayerNameEx(id));
	GameTextForPlayer(playerid, string, 5000, 1);

	return 1;
}
