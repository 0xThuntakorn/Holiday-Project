//--------------------------------[FUNCTION.PWN]--------------------------------

forward OnPlayerCheckLogin(playerid,name[]);
public OnPlayerCheckLogin(playerid,name[])
{
  new sqlaccountstatus = MySQLCheckAccount(name);
  if(sqlaccountstatus != 0)
    {
		playerData[playerid][ID] = sqlaccountstatus;
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
		Dialog_Show(playerid,DIALOG_PASSWORD_USER,DIALOG_STYLE_INPUT,"ล็อกอิน","---[ GTA:HOLIDAY ]---\nยินดีต้อนรับเข้าสู่ SERVER!\nกรุณา*กรอกรหัสผ่าน*","ล็อกอิน","ออก");
	}
	else 
	{
		login(playerid);
		SendClientMessage(playerid,0xFF0000AA,"SERVER:{FFFFFF} ไม่ชื่อผู้เล่นนี้ในฐานข้อมูล");
	}
  return 1;
}

forward OnPlayerCheckPassLogin(playerid,inputtext[]);
public OnPlayerCheckPassLogin(playerid,inputtext[])
{
	OnPlayerLogin(playerid,inputtext);
	gPlayerAccount[playerid] = 1;
	PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
	return 1;
}

forward OnPlayerCheckRegister(playerid,name[]);
public OnPlayerCheckRegister(playerid,name[])
{
	new sqlaccountstatus = MySQLCheckAccount(name);
	if(sqlaccountstatus > 0 )
	{
		SendClientMessage(playerid,0xFF0000AA,"[!]:{FFFFFF} ชื่อนี้โดนใช้ไปแล้ว");
		return 1;
	}
	mysql_escape_string(name, EnterName);
	PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
	Dialog_Show(playerid,DIALOG_CREATE_PASSWORD,DIALOG_STYLE_INPUT,"สมัครสมาชิก","---[ GTA:HOLIDAY ]---\nยินดีต้อนรับเข้าสู่ SERVER!\nกรุณา*สร้างรหัสผ่าน*","สมัครสมาชิก","ออก");
	return 1;
}

forward OnPlayerCheckPassRegister(playerid,inputtext[]);
public OnPlayerCheckPassRegister(playerid,inputtext[])
{
    if(IsPlayerConnected(playerid))
	{
		new newaccountsqlid = MySQLCreateAccount(EnterName, inputtext);
		if (newaccountsqlid != 0)
		{
			playerData[playerid][ID] = newaccountsqlid;
			SavePlayer(playerid);
			SendClientMessage(playerid, 0xFFFF00AA, "{FF3030}[SERVER]:{FFE7BA}คุณได้ลงทะเบียนเรียบร้อยแล้ว... กรุณากรอก รายละเอียด เพื่อเข้าเล่น");
			gPlayerAccount[playerid] = 1;
			ShowDialog_Tutorial(playerid);
			
			return 1;
		}
		else
		{
			SendClientMessage(playerid, 0xFFFFFFFF, "{FF3030}[SERVER]:{FFE7BA}มีปัญหาบางอย่างในการสร้าง Account เราขอตัดท่านออกจาก SERVER");
			Kick(playerid);
			return 0;
		}
	}
    return 1;
}


forward OnPlayerLogin(playerid,password[]);
public OnPlayerLogin(playerid,password[])
{
	new	query[256];
	format(query,sizeof(query), "SELECT * FROM `players` WHERE `Name` = '%s' AND `Password` = '%s'", EnterName, password);
	mysql_tquery(g_SQL,query, "QuQueryFinished", "dd", playerid, THREAD_LOAD_DATA);
	return 0;
}

forward login(playerid);
public login(playerid)
{
    Dialog_Show(playerid,DIALOG_ENTER_USER,DIALOG_STYLE_INPUT,"ล็อกอิน","---[ GTA:HOLIDAY ]---\nยินดีต้อนรับเข้าสู่ SERVER!\nกรุณากรอกชื่อผู้ใช้","ล็อกอิน","ออก");
}

forward register(playerid);
public register(playerid)
{
    Dialog_Show(playerid,DIALOG_REGISTER_USER,DIALOG_STYLE_INPUT,"สมัครสมาชิก","---[ GTA:HOLIDAY ]---\nยินดีต้อนรับเข้าสู่ SERVER!\nกรุณาสร้างชื่อผู้ใช้","ยืนยัน","ออก");
        
}

forward DialogRegister(playerid);
public DialogRegister(playerid)
{
   	new string[128];
   	GetPlayerName(playerid,PlayerName[playerid]);
   	format(string,sizeof(string),"สวัสดีค่ะคุณ %s!กรุณาพิมพ์ Password เพื่อสมัครสมาชิก",PlayerName);
   	Dialog_Show(playerid,ShowOnly,DIALOG_STYLE_INPUT,"สมัครสมาชิก",string,"สมัครสมาชิก","ออก");
}

forward DialogLogin(playerid);
public DialogLogin(playerid)
{
   	new string[128];
   	GetPlayerName(playerid,PlayerName[playerid]);
   	format(string,sizeof(string),"สวัสดีค่ะคุณ %s! ยินดีต้อนรับ", PlayerName);
   	Dialog_Show(playerid,ShowOnly,DIALOG_STYLE_INPUT,"เข้าสู่ระบบ",string,"เข้าสู่ระบบ","ออก");
}

forward QuQueryFinished(extraid,threadid);
public QuQueryFinished(extraid,threadid)
{
	if(!IsPlayerConnected(extraid))
		return 0;

	new	rows;
	switch(threadid)
	{
	    case THREAD_LOAD_DATA :
	    {
			cache_get_row_count(rows);

			if(!rows)
			{
				SendClientMessage(extraid, 0xFF0000AA, "SERVER:{FFFFFF} Password ไม่ถูกต้อง");
			    SetTimerEx("login", 500, 0, "d", extraid);
	   			return 0;
			}
			SetPlayerName(extraid, EnterName);
			LoadPlayer(extraid);

			printf("%s : Logged in.", EnterName);
			CancelSelectTextDraw(extraid);
            for(new i = 0; i != 8; i++)
			{
				TextDrawHideForPlayer(extraid, Login[i]);
			}
		}
	}
	return 1;
}

forward SavePlayer(playerid);
public SavePlayer(playerid)
{
	new query[2048];
	GetPlayerPos(playerid, playerData[playerid][pPos_X], playerData[playerid][pPos_Y], playerData[playerid][pPos_Z]);
	GetPlayerFacingAngle(playerid, playerData[playerid][pPos_A]);

	playerData[playerid][pSkin] = GetPlayerSkin(playerid);
	playerData[playerid][pInterior] = GetPlayerInterior(playerid);
	playerData[playerid][pWorld] = GetPlayerVirtualWorld(playerid);

	mysql_format(g_SQL, query, sizeof(query), "UPDATE `players` SET `playerMoney` = '%d', `playerItemFree` = '%d', `playerInterior` = '%d', `playerWorld` = '%d', `playerSkin` = '%d', `playerAdministrator` = '%d',`playerPosX` = '%3f', `playerPosY` = '%3f', `playerPosZ` = '%f', `playerPosA` = '%3f' WHERE `ID` = '%d'",
	playerData[playerid][pMoney],
	playerData[playerid][pItemFree],
	playerData[playerid][pInterior],
	playerData[playerid][pWorld],	
	playerData[playerid][pSkin],
	playerData[playerid][pAdministrator],	
	playerData[playerid][pPos_X],
	playerData[playerid][pPos_Y],
	playerData[playerid][pPos_Z],
	playerData[playerid][pPos_A],	
	playerData[playerid][ID]);
	mysql_tquery(g_SQL, query); 
	return 1;
}

forward MySQLCreateAccount(newplayersname[], newpassword[]);
public MySQLCreateAccount(newplayersname[], newpassword[])
{
	new query[128];
	new sqlplyname[64];
	new sqlpassword[64];
	mysql_escape_string(newplayersname, sqlplyname);
	mysql_escape_string(newpassword, sqlpassword);
	format(query, sizeof(query), "INSERT INTO players (Name, Password)VALUES ('%s','%s')", sqlplyname, sqlpassword);
	mysql_query(g_SQL,query);
	new newplayersid = MySQLCheckAccount(newplayersname);
	if (newplayersid != 0)
	{
		return newplayersid;
	}
	return 0;
}

forward MySQLCheckAccount(sqlplayersname[]);
public MySQLCheckAccount(sqlplayersname[])
{
	new query[128];
	mysql_escape_string(sqlplayersname, EnterName);
	format(query, sizeof(query), "SELECT ID FROM players WHERE LOWER(Name) = LOWER('%s') LIMIT 1", EnterName);
	mysql_query(g_SQL,query);
	if(cache_num_rows() == 1)
	{
		new intid;
		cache_get_value_index_int(0, 0, intid);
		return intid;
	}
	return 0;
}

forward AccountCheck(playerid);
public AccountCheck(playerid)
{
    switch(random(3))
	{
		    case 0:
		    {
				InterpolateCameraPos(playerid, 1639.867675, -945.077270, 92.998382, 1628.310058, -1947.937622, 84.616470, 15000);
                InterpolateCameraLookAt(playerid, 1641.407226, -940.486938, 91.750015, 1626.668212, -1952.572875, 83.711647, 15000);
		    }
		    case 1:
		    {
				InterpolateCameraPos(playerid, 1004.378723, -2040.026123, 99.410041, 1656.265625, -2135.106201, 63.948608, 10000);
                InterpolateCameraLookAt(playerid, 1009.363159, -2040.188110, 99.050979, 1652.205688, -2137.943115, 63.263275, 10000);
		    }
		    case 2:
		    {
				InterpolateCameraPos(playerid, 976.317260, -1927.020263, 54.905170, 324.879760, -1862.667846, 51.463054, 15000);
                InterpolateCameraLookAt(playerid, 976.441406, -1922.632080, 52.511749, 328.557952, -1859.427490, 50.477676, 15000);
		    }
		    
	}
    return 1;
}

forward LoadPlayer(playerid);
public LoadPlayer(playerid)
{
	cache_get_value_name_int(0, "playerMoney", playerData[playerid][pMoney]);
	cache_get_value_name_int(0, "playerItemFree", playerData[playerid][pItemFree]);
	cache_get_value_name_int(0, "playerGender", playerData[playerid][pGender]);
	cache_get_value_name(0, "playerBirthday", playerData[playerid][pBirthday], 24);
	cache_get_value_name_int(0, "playerTutorial", playerData[playerid][pTutorial]);	
	cache_get_value_name_int(0, "playerInterior", playerData[playerid][pInterior]);
	cache_get_value_name_int(0, "playerWorld", playerData[playerid][pWorld]);
	cache_get_value_name_int(0, "playerSkin", playerData[playerid][pSkin]);	
	cache_get_value_name_int(0, "playerAdministrator", playerData[playerid][pAdministrator]);
	cache_get_value_name_float(0, "playerPosX", playerData[playerid][pPos_X]);
	cache_get_value_name_float(0, "playerPosY", playerData[playerid][pPos_Y]);
	cache_get_value_name_float(0, "playerPosZ", playerData[playerid][pPos_Z]);
	cache_get_value_name_float(0, "playerPosA", playerData[playerid][pPos_A]);	
	playerData[playerid][LoggenIn] = true;
    SpawnPlayer(playerid);
	return 1;
}

forward PlayerLoad(playerid);
public PlayerLoad(playerid)
{
	playerData[playerid][pMoney] = 0;
	playerData[playerid][pItemFree] = 0;	
 	playerData[playerid][pTutorial] = 0;
	playerData[playerid][pGender] = 0;
	playerData[playerid][pBirthday][0] = EOS;
 	playerData[playerid][pInterior] = 0;
	playerData[playerid][pWorld] = 0;	
	playerData[playerid][pSkin] = 0;	
	playerData[playerid][pAdministrator] = 0;			
	return 1;
}

forward FreeItem(playerid);
public FreeItem(playerid)
{
	if(playerData[playerid][pItemFree] == 0)
	{
		playerData[playerid][pItemFree] = 1;

		playerData[playerid][pSkin] = 74;
		SetPlayerSkin(playerid, playerData[playerid][pSkin]);
		SavePlayer(playerid);

		GivePlayerMoneyEx(playerid, 2000);
		SendClientMessage(playerid, -1, "{FFF000}(ของขวัญสำหรับเด็กใหม่) : {FFFFFF}คุณได้รับเงินในการเริ่มต้นชีวิต 2000 บาท");
	}
	return 1;
}

forward OnPlayerRegister(playerid, password[]);
public OnPlayerRegister(playerid,password[])
{
	if(IsPlayerConnected(playerid))
	{
		GetPlayerName(playerid, PlayerName[playerid]);
		new newaccountsqlid = MySQLCreateAccount(PlayerName[playerid], password);
		if (newaccountsqlid != 0)
		{
			playerData[playerid][ID] = newaccountsqlid;
			SavePlayer(playerid);
			SendClientMessage(playerid, 0xFFFF00AA, "{FF3030}[SERVER]:{FFE7BA}คุณได้ลงทะเบียนเรียบร้อยแล้ว... กรุณากรอก Password เพื่อเข้าเล่น");
			gPlayerAccount[playerid] = 1;
			ShowDialog_Tutorial(playerid);
			SetTimerEx("DialogLogin", 500, 0, "d", playerid);
			return 1;
		}
		else
		{
			SendClientMessage(playerid, 0xFFFFFFFF, "{FF3030}[SERVER]:{FFE7BA}มีปัญหาบางอย่างในการสร้าง Account เราขอตัดท่านออกจาก SERVER");
			Kick(playerid);
			return 0;
		}
	}
	return 1;
}

LoadTextdrawLogin()
{
	Login[0] = TextDrawCreate(321.000000, 140.000000, "_");
	TextDrawFont(Login[0], 1);
	TextDrawLetterSize(Login[0], 0.516665, 18.050010);
	TextDrawTextSize(Login[0], 298.500000, 120.500000);
	TextDrawSetOutline(Login[0], 1);
	TextDrawSetShadow(Login[0], 0);
	TextDrawAlignment(Login[0], 2);
	TextDrawColor(Login[0], -1);
	TextDrawBackgroundColor(Login[0], 255);
	TextDrawBoxColor(Login[0], 115);
	TextDrawUseBox(Login[0], 1);
	TextDrawSetProportional(Login[0], 1);
	TextDrawSetSelectable(Login[0], 0);

	Login[1] = TextDrawCreate(321.000000, 195.000000, "LOGIN");
	TextDrawFont(Login[1], 2);
	TextDrawLetterSize(Login[1], 0.258332, 2.049998);
	TextDrawTextSize(Login[1], 16.500000, 90.500000);
	TextDrawSetOutline(Login[1], 1);
	TextDrawSetShadow(Login[1], 0);
	TextDrawAlignment(Login[1], 2);
	TextDrawColor(Login[1], -1);
	TextDrawBackgroundColor(Login[1], 255);
	TextDrawBoxColor(Login[1], 1728027135);
	TextDrawUseBox(Login[1], 1);
	TextDrawSetProportional(Login[1], 1);
	TextDrawSetSelectable(Login[1], 1);

	Login[2] = TextDrawCreate(321.000000, 222.000000, "REGISTER");
	TextDrawFont(Login[2], 2);
	TextDrawLetterSize(Login[2], 0.258332, 2.049998);
	TextDrawTextSize(Login[2], 16.500000, 90.500000);
	TextDrawSetOutline(Login[2], 1);
	TextDrawSetShadow(Login[2], 0);
	TextDrawAlignment(Login[2], 2);
	TextDrawColor(Login[2], -1);
	TextDrawBackgroundColor(Login[2], 255);
	TextDrawBoxColor(Login[2], 1728027135);
	TextDrawUseBox(Login[2], 1);
	TextDrawSetProportional(Login[2], 1);
	TextDrawSetSelectable(Login[2], 1);

	Login[3] = TextDrawCreate(290.000000, 147.000000, "Holiday City");
	TextDrawFont(Login[3], 3);
	TextDrawLetterSize(Login[3], 0.279166, 1.750000);
	TextDrawTextSize(Login[3], 400.000000, 17.000000);
	TextDrawSetOutline(Login[3], 1);
	TextDrawSetShadow(Login[3], 0);
	TextDrawAlignment(Login[3], 1);
	TextDrawColor(Login[3], -1);
	TextDrawBackgroundColor(Login[3], 255);
	TextDrawBoxColor(Login[3], 50);
	TextDrawUseBox(Login[3], 0);
	TextDrawSetProportional(Login[3], 1);
	TextDrawSetSelectable(Login[3], 0);

	Login[4] = TextDrawCreate(299.000000, 164.000000, "Roleplay");
	TextDrawFont(Login[4], 3);
	TextDrawLetterSize(Login[4], 0.279166, 1.750000);
	TextDrawTextSize(Login[4], 400.000000, 17.000000);
	TextDrawSetOutline(Login[4], 1);
	TextDrawSetShadow(Login[4], 0);
	TextDrawAlignment(Login[4], 1);
	TextDrawColor(Login[4], 1728027135);
	TextDrawBackgroundColor(Login[4], 255);
	TextDrawBoxColor(Login[4], 50);
	TextDrawUseBox(Login[4], 0);
	TextDrawSetProportional(Login[4], 1);
	TextDrawSetSelectable(Login[4], 0);

	Login[5] = TextDrawCreate(321.000000, 140.000000, "_");
	TextDrawFont(Login[5], 1);
	TextDrawLetterSize(Login[5], 0.516665, -0.199986);
	TextDrawTextSize(Login[5], 298.500000, 120.500000);
	TextDrawSetOutline(Login[5], 1);
	TextDrawSetShadow(Login[5], 0);
	TextDrawAlignment(Login[5], 2);
	TextDrawColor(Login[5], -1);
	TextDrawBackgroundColor(Login[5], 255);
	TextDrawBoxColor(Login[5], 1728027135);
	TextDrawUseBox(Login[5], 1);
	TextDrawSetProportional(Login[5], 1);
	TextDrawSetSelectable(Login[5], 0);

	Login[6] = TextDrawCreate(321.000000, 304.500000, "_");
	TextDrawFont(Login[6], 1);
	TextDrawLetterSize(Login[6], 0.516665, -0.199986);
	TextDrawTextSize(Login[6], 298.500000, 120.500000);
	TextDrawSetOutline(Login[6], 1);
	TextDrawSetShadow(Login[6], 0);
	TextDrawAlignment(Login[6], 2);
	TextDrawColor(Login[6], -1);
	TextDrawBackgroundColor(Login[6], 255);
	TextDrawBoxColor(Login[6], 1728027135);
	TextDrawUseBox(Login[6], 1);
	TextDrawSetProportional(Login[6], 1);
	TextDrawSetSelectable(Login[6], 0);

	Login[7] = TextDrawCreate(279.000000, 287.000000, "HOLIDAY_CITY_2019-2021");
	TextDrawFont(Login[7], 2);
	TextDrawLetterSize(Login[7], 0.166666, 1.450000);
	TextDrawTextSize(Login[7], 400.000000, 17.000000);
	TextDrawSetOutline(Login[7], 1);
	TextDrawSetShadow(Login[7], 0);
	TextDrawAlignment(Login[7], 1);
	TextDrawColor(Login[7], -1);
	TextDrawBackgroundColor(Login[7], 255);
	TextDrawBoxColor(Login[7], 50);
	TextDrawUseBox(Login[7], 0);
	TextDrawSetProportional(Login[7], 1);
	TextDrawSetSelectable(Login[7], 0);

	return 1;
}

stock ShowTextDrawLogin(playerid)
{
	for(new i = 0; i != 8;i++)
	{
		TextDrawShowForPlayer(playerid,Login[i]);
	}
}

stock SetPlayerPosEx(playerid,Float:X,Float:Y,Float:Z, Int, vWorld)
{
    TogglePlayerControllable(playerid, 0);
	SetPlayerPos(playerid, X, Y, Z+2);
    SetPlayerInterior(playerid, Int);
	SetTimerEx("TimeUnfreeze", 2000, 0, "d", playerid);
	SetPlayerVirtualWorld(playerid, vWorld);
	SetTimerEx("Move_Player", 200, false, "dfff", playerid, X, Y, Z);
}

forward TimeUnfreeze(playerid);
public TimeUnfreeze(playerid)
{
	TogglePlayerControllable(playerid, 1);
	return 1;
}

forward Move_Player(playerid, Float:X, Float:Y, Float:Z);
public Move_Player(playerid, Float:X, Float:Y, Float:Z)
{
	SetPlayerPos(playerid, X, Y, Z);
	return 1;
}