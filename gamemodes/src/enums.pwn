//--------------------------------[ENUMS.PWN]--------------------------------

enum PlayerData 
{
	ID,
	Password[129],
	pMoney,
	pItemFree,
	pTutorial,
	pGender,
	pBirthday[24],	
	bool:LoggenIn,
	pWorld,
	pInterior,		
	pSkin,
	pAdministrator,
	Float: pPos_X,
	Float: pPos_Y,
	Float: pPos_Z,
	Float: pPos_A,	
};
new playerData[MAX_PLAYERS][PlayerData];
