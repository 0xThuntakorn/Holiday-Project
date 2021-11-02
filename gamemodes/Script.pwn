#include <a_samp>
#include <a_mysql>
#include <streamer>
#include <Pawn.CMD>
#include <Pawn.Raknet>
#define cec_auto
#include <cec>
#include <easyDialog>
#include <sscanf2>
#include <eSelection>

#undef	 MAX_PLAYERS
#define	 MAX_PLAYERS			100

#define  YSI_NO_OPTIMISATION_MESSAGE
#define  YSI_NO_CACHE_MESSAGE
#define  YSI_NO_MODE_CACHE
#define  YSI_NO_HEAP_MALLOC
#define  YSI_NO_VERSION_CHECK

#include <YSI_Data\y_iterate>
#include <YSI_Coding\y_timers>

DEFINE_HOOK_REPLACEMENT(OnPlayer, OP_);

#define THREAD_LOAD_DATA (1)

#define MODEL_SELECTION_CLOTHES (3)

#include "configuration.inc"

//--> Server

//--> Utillty
#include "src/utility/colour.pwn"
#include "src/utility/utils.pwn"

//--> General
#include "src/variables.pwn"
#include "src/define.pwn"
#include "src/enums.pwn"
#include "src/function.pwn"
#include "src/public.pwn"
#include "src/dialog.pwn"
#include "src/callback.pwn"

//--> Commands
#include "src/Commands/Admin_Command.pwn"
#include "src/Commands/Player_Command.pwn"

main()
{
	print("--------------------------------");
	print("- [Gamemode] Holiday Project");
	print("- Developer By Enter Developer");
	print("--------------------------------");
}