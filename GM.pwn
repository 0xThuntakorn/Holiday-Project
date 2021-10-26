#include <a_samp>
#include <a_mysql>
#include <streamer>
#include <easyDialog>
#include <Pawn.CMD>
#include <sscanf2>

#undef	 MAX_PLAYERS
#define	 MAX_PLAYERS			100

#define  YSI_NO_OPTIMISATION_MESSAGE
#define  YSI_NO_CACHE_MESSAGE
#define  YSI_NO_MODE_CACHE
#define  YSI_NO_HEAP_MALLOC
#define  YSI_NO_VERSION_CHECK

#include <YSI_Data\y_iterate>
#include <YSI_Coding\y_timers>


//--> เชื่อม Database
#define  MYSQL_HOSTNAME		"127.0.0.1"
#define  MYSQL_USERNAME		"root"
#define  MYSQL_PASSWORD		""
#define  MYSQL_DATABASE		"AlexDev"

new PlayerSaveTime[MAX_PLAYERS];

new Text:Login[8];

new gPlayerAccount[MAX_PLAYERS];
new gPlayerLogged[MAX_PLAYERS];
new EnterName[MAX_PLAYER_NAME];

#define THREAD_LOAD_DATA (1)

//--> MySQL R41-4
new MySQL: Database,PlayerName[MAX_PLAYERS][30];
native WP_Hash(buffer[], len, const str[]); 

//--> ตัวแปร
enum PlayerData 
{
	ID,
	Password[129],
	Money,
	ItemFree
};
new playerData[MAX_PLAYERS][PlayerData];

main()
{
     print("Gamemode-Clean BY Enter Samp");
}

public OnGameModeInit()
{
    //--> MySQL R41-4
	new MySQLOpt: option_id = mysql_init_options();
	mysql_set_option(option_id, AUTO_RECONNECT, true); 
	Database = mysql_connect(MYSQL_HOSTNAME, MYSQL_USERNAME, MYSQL_PASSWORD, MYSQL_DATABASE, option_id);
	if (Database == MYSQL_INVALID_HANDLE || mysql_errno(Database) != 0)
	{
		print("MYSQL ERROR : SERVER OFF");
		SendRconCommand("exit"); 
		return 1;
	}
	SetGameModeText("Enter Samp 1.0.0");
	print("MySQL connection is successful.");
	
	//--> ระบบเชฟข้อมูลทุกวิ
	SetTimer("AutoSave", 1000, 1);
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
    SavePlayer(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	//--> เปลี่ยนจุดเกิด
	SetPlayerPos(playerid,1642.2371,-2335.0247,13.5469 );
	SetPlayerFacingAngle(playerid, 359.5183 );
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
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
			SendClientMessage(playerid, 0xFFFF00AA, "{FF3030}[SERVER]:{FFE7BA}คุณได้ลงทะเบียนเรียบร้อยแล้ว... กรุณากรอก Password เพื่อเข้าเล่น");
			gPlayerAccount[playerid] = 1;
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

CMD:Money(playerid, params[])
{
	GivePlayerMoneyEx(playerid, 5295);
	return 1;
}
public OnPlayerUpdate(playerid)
{
	if (GetPlayerMoney(playerid) != playerData[playerid][Money])
	{
	    ResetPlayerMoney(playerid);
	    GivePlayerMoney(playerid, playerData[playerid][Money]);
	}
	return 1;
}

GivePlayerMoneyEx(playerid, value)
{
	playerData[playerid][Money] += value;
	GivePlayerMoney(playerid, value);
	return 1;
}

Dialog:DIALOG_ENTER_USER(playerid, response, listitem, inputtext[])
{
	if(!response) 
	{ 
		ShowTextDrawLogin(playerid); 
		return 1; 
	}
	if(!strlen(inputtext)) 
	{ 
		login(playerid); 
		return 1; 
	}
	OnPlayerCheckLogin(playerid,inputtext);
	return 1;
}

Dialog:DIALOG_REGISTER_USER(playerid, response, listitem, inputtext[])
{
	if(!response) 
	{ 
		ShowTextDrawLogin(playerid); 
		return 1; 
	}
	if(!strlen(inputtext)) 
	{  
		register(playerid); 
		return 1; 
	}
	OnPlayerCheckRegister(playerid,inputtext);
	return 1;
}

Dialog:DIALOG_PASSWORD_USER(playerid, response, listitem, inputtext[])
{
	if(!response) 
	{ 
		ShowTextDrawLogin(playerid); 
		return 1; 
	}
	if(!strlen(inputtext)) 
	{  
		login(playerid); 
		return 1; 
	}
	OnPlayerCheckPassLogin(playerid,inputtext);
	return 1;
}

Dialog:DIALOG_CREATE_PASSWORD(playerid, response, listitem, inputtext[])
{
	if(!response) 
	{ 
		ShowTextDrawLogin(playerid); 
		return 1; 
	}
	if(!strlen(inputtext)) 
	{  
		register(playerid); 
		return 1; 
	}
	OnPlayerCheckPassRegister(playerid,inputtext);
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

public OnPlayerRequestClass(playerid, classid)
{
	AccountCheck(playerid);
	SelectTextDraw(playerid,0xFF0000FF);
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

forward OnPlayerLogin(playerid,password[]);
public OnPlayerLogin(playerid,password[])
{
	new	query[256];
	format(query,sizeof(query), "SELECT * FROM `players` WHERE `Name` = '%s' AND `Password` = '%s'", EnterName, password);
	mysql_tquery(Database,query, "QuQueryFinished", "dd", playerid, THREAD_LOAD_DATA);
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

			printf("%s: Logged in.", playerData[extraid][ID]);
			CancelSelectTextDraw(extraid);
            for(new i = 0; i != 10; i++)
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
	mysql_format(Database, query, sizeof(query), "UPDATE `players` SET `playerMoney` = '%d', `playerItemFree` = '%d' WHERE `ID` = '%d'",
	playerData[playerid][Money],
	playerData[playerid][ItemFree],
	playerData[playerid][ID]);
	mysql_tquery(Database, query); 
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
	mysql_query(Database,query);
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
	mysql_query(Database,query);
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
	cache_get_value_name_int(0, "playerMoney", playerData[playerid][Money]);
	cache_get_value_name_int(0, "playerItemFree", playerData[playerid][ItemFree]);
    SpawnPlayer(playerid);
	return 1;
}

forward AutoSave();
public AutoSave()
{
	foreach(new i: Player)
	{
		if(IsPlayerConnected(i))
		{
		    if(PlayerSaveTime[i] == 1)
			{
	    		SavePlayer(i);
			}
		}
	}
    return 1;
}