
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

Dialog:DIALOG_GENDER(playerid, response, listitem, inputtext[])
{
    new string[256];
	if(!response)
	{
        playerData[playerid][pGender] = 2;
        SendClientMessage(playerid, COLOR_GREEN, "คุณได้เลือกเพศ 'หญิง'");
	    format(string, sizeof(string), "{FFFFFF}ใส่วันเดือนปีเกิด {00ffff}ตัวอย่าง: 1/1/1991");
	    Dialog_Show(playerid, DIALOG_DATE, DIALOG_STYLE_INPUT, "[วัน/เดือน/ปี]",string, "ไปต่อ", "");
	}
	else
	{
 		playerData[playerid][pGender] = 1;
        SendClientMessage(playerid, COLOR_GREEN, "คุณได้เลือกเพศ 'ชาย'");
	    format(string, sizeof(string), "{FFFFFF}ใส่วันเดือนปีเกิด {00ffff}ตัวอย่าง: 1/1/1991");
	    Dialog_Show(playerid, DIALOG_DATE, DIALOG_STYLE_INPUT, "[วัน/เดือน/ปี]",string, "ไปต่อ", "");
	}
	
	return 1;
}
Dialog:DIALOG_DATE(playerid, response, listitem, inputtext[])
{
    new string[256];
    if (response)
    {
		new
			iDay,
			iMonth,
			iYear;

		static const
			arrMonthDays[] = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

		if (sscanf(inputtext, "p</>ddd", iDay, iMonth, iYear)) {
		    format(string, sizeof(string), "{FFFFFF}ใส่วันเดือนปีเกิด {00ffff}ตัวอย่าง: 1/1/1991");
		    Dialog_Show(playerid, DIALOG_DATE, DIALOG_STYLE_INPUT, "[วัน/เดือน/ปี]",string, "ไปต่อ", "");
		}
		else if (iYear < 1900 || iYear > 2019) {
		    format(string, sizeof(string), "{FFFFFF}ใส่วันเดือนปีเกิด {00ffff}ตัวอย่าง: 1/1/1991");
		    Dialog_Show(playerid, DIALOG_DATE, DIALOG_STYLE_INPUT, "[วัน/เดือน/ปี]",string, "ไปต่อ", "");
		}
		else if (iMonth < 1 || iMonth > 12) {
		    format(string, sizeof(string), "{FFFFFF}ใส่วันเดือนปีเกิด {00ffff}ตัวอย่าง: 1/1/1991");
		    Dialog_Show(playerid, DIALOG_DATE, DIALOG_STYLE_INPUT, "[วัน/เดือน/ปี]",string, "ไปต่อ", "");
		}
		else if (iDay < 1 || iDay > arrMonthDays[iMonth - 1]) {
		    format(string, sizeof(string), "{FFFFFF}ใส่วันเดือนปีเกิด {00ffff}ตัวอย่าง: 1/1/1991");
		    Dialog_Show(playerid, DIALOG_DATE, DIALOG_STYLE_INPUT, "[วัน/เดือน/ปี]",string, "ไปต่อ", "");
		}
		else {
			format(playerData[playerid][pBirthday], 24, inputtext);
		    format(string, sizeof(string), "{FFFFFF}สนามบิน\nสถานีรถไฟ\nสวนสาธารณะ");
		    Dialog_Show(playerid, DIALOG_SPAWN, DIALOG_STYLE_LIST, "[เลือกจุดเกิด]",string, "ไปต่อ", "");
		}
	}
	return 1;
}
Dialog:DIALOG_SPAWN(playerid, response, listitem, inputtext[])
{
    if (response)
    {
		switch(listitem)
		{
			case 0:
			{
				if(playerData[playerid][pGender] == 1)
				{
					ShowModelSelectionMenu(playerid, "Character", MODEL_SELECTION_CLOTHES, g_aMaleSkins, sizeof(g_aMaleSkins), -16.0, 0.0, -55.0);
				}
				else if(playerData[playerid][pGender] == 2)
				{
					ShowModelSelectionMenu(playerid, "Character", MODEL_SELECTION_CLOTHES, g_aFemaleSkins, sizeof(g_aFemaleSkins), -16.0, 0.0, -55.0);
				}
				
				playerData[playerid][pTutorial] = 1;
				SpawnPlayer(playerid);
				SetPlayerPosEx(playerid, 1642.2086,-2335.4966,-2.6797, 0, 0);
				UpdatePlayerRegister(playerid);
				FreeItem(playerid);
				SavePlayer(playerid);
			}
			case 1:
			{
				if(playerData[playerid][pGender] == 1)
				{
					ShowModelSelectionMenu(playerid, "Character", MODEL_SELECTION_CLOTHES, g_aMaleSkins, sizeof(g_aMaleSkins), -16.0, 0.0, -55.0);
				}
				else if(playerData[playerid][pGender] == 2)
				{
					ShowModelSelectionMenu(playerid, "Character", MODEL_SELECTION_CLOTHES, g_aFemaleSkins, sizeof(g_aFemaleSkins), -16.0, 0.0, -55.0);
				}
				
				playerData[playerid][pTutorial] = 1;
				SpawnPlayer(playerid);
				SetPlayerPosEx(playerid, 1752.4957,-1894.1294,13.5574, 0, 0);
				UpdatePlayerRegister(playerid);
				FreeItem(playerid);
				SavePlayer(playerid);
			}
			case 2:
			{
				if(playerData[playerid][pGender] == 1)
				{
					ShowModelSelectionMenu(playerid, "Character", MODEL_SELECTION_CLOTHES, g_aMaleSkins, sizeof(g_aMaleSkins), -16.0, 0.0, -55.0);
				}
				else if(playerData[playerid][pGender] == 2)
				{
					ShowModelSelectionMenu(playerid, "Character", MODEL_SELECTION_CLOTHES, g_aFemaleSkins, sizeof(g_aFemaleSkins), -16.0, 0.0, -55.0);
				}
				
				playerData[playerid][pTutorial] = 1;
				SpawnPlayer(playerid);
				SetPlayerPosEx(playerid, 1103.2970,-1643.0002,13.6213, 0, 0);
				UpdatePlayerRegister(playerid);
				FreeItem(playerid);
				SavePlayer(playerid);
			}
		}
    }
    return 1;
}
