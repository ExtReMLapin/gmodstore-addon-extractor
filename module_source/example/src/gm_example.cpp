#include "GarrysMod/Lua/Interface.h"
#ifdef _WIN32
#include <Windows.h>
#endif
#include <stdio.h>

#include <sys/types.h>
#include <sys/stat.h>

#include <stdlib.h>
#include <zip.h>


char *APIKEY = NULL;
using namespace GarrysMod::Lua;

/*typedef void(*func)(const char* msg, ...);

#ifdef __linux__ 
//linux code goes here
#elif _WIN32
static func msg = (func)GetProcAddress(GetModuleHandle("tier0.dll"), "Msg");
static func error = (func)GetProcAddress(GetModuleHandle("tier0.dll"), "Error");
#endif*/


// too lazy to hook the linux code, so i'll use this 

static void msg(lua_State* state, const char* str, int r = 255, int g = 255, int b = 255) {
	LUA->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
	LUA->GetField(-1, "Color");
	LUA->PushNumber(r);
	LUA->PushNumber(g);
	LUA->PushNumber(b);
	LUA->Call(3, 1);
	int ref = LUA->ReferenceCreate();
	LUA->GetField(-1, "MsgC");
	LUA->ReferencePush(ref);
	LUA->PushString(str);
	LUA->Call(2, 0);
	LUA->Pop();
	LUA->ReferenceFree(ref);
}

bool checkAPIKey(const char* key)
{
	int i = 0;
	while (key[i])
	{
		if ((isalpha(key[i]) && islower(key[i])) || isdigit(key[i]))
			i++;
		else
			return (false);
	}
	if (i != 32)
		return (false);
	return (true);
}

int dirExists(const char *path)
{
	struct stat info;

	if (stat(path, &info) != 0)
		return 0;
	else if (info.st_mode & S_IFDIR)
		return 1;
	else
		return 0;
}

int LuaFunc_SetAPI(lua_State* state)
{
	if (LUA->IsType(1, Type::STRING))
	{
		const char* tmpkey = LUA->GetString(1);
		if (checkAPIKey(tmpkey))
		{
			LUA->PushBool(true);
			APIKEY = strcpy((char*)malloc(sizeof(char)*(strlen(tmpkey) + 1)), tmpkey);
		}
		else
		{
			LUA->PushBool(false);
			LUA->ThrowError("GMODSTORE MODULE : The key is incorrect\n");
		}
	}
	else
	{
		LUA->PushBool(false);
		LUA->ThrowError("GMODSTORE MODULE : The key has to be a string\n");
	}
	return 1;
}

int LuaFunc_GetAPI(lua_State* state)
{
	if (APIKEY != NULL)
		LUA->PushString(APIKEY);
	else
		LUA->PushNil();
	return 1;
}

int LuaFunc_ExtractZip(lua_State* state)
{
	char buff[20];
	char tmp_path_in[128];
	char tmp_path_out[128];
	if (LUA->IsType(1, Type::NUMBER))
	{
		const int ID = (const int)LUA->GetNumber(1);
		sprintf(tmp_path_in, "./garrysmod/data/gmodstore_tmp_zips/%i.zip.dat", ID);
		sprintf(tmp_path_out, "./garrysmod/data/gmodstore_tmp_zips/%i_tmp/", ID);

		FILE *file;
		if (!(file = fopen(tmp_path_in, "r")))
		{
			LUA->PushBool(false);
			LUA->ThrowError("GMODSTORE MODULE : cannot access the input file");
			return 1;
		}

		if (!(dirExists(tmp_path_out)))
		{
			LUA->PushBool(false);
			LUA->ThrowError("GMODSTORE MODULE : cannot access the output folder");
			return 1;
		}
		msg(state, "Start extracting an addon ... ", 50, 255, 50);
		if (zip_extract(tmp_path_in, tmp_path_out, NULL, NULL) < 0)
		{
			msg(state, "failed :(\n", 255,50,50);
			LUA->PushBool(false);
			LUA->ThrowError("GMODSTORE MODULE : cannot access the output folder");
		}
		else
		{
			msg(state, "done !\n", 50,255,50);
			LUA->PushBool(true);
		}
		return 1;
	}
	else
	{
		LUA->PushBool(false);
		LUA->ThrowError("GMODSTORE MODULE : expected a number in gmodstore.extractZIP\n");
		return 1;
	}
	//ExtractToDirectory
}


void parseAPIKeyFromCommandLine(lua_State *state)
{
	char* cmdline = GetCommandLine();
	char* adr = NULL;
	if ((adr = strstr(cmdline, "-gmodstorekey")) != NULL) // manual parsing i guess
	{
		msg(state, "[GMODSTORE MODULE] Found gmodstorekey parameters, trying to find the key now ... ");
		adr += 13;
		while (isspace(*adr)) // skipping blank spaces
			*adr++;
		char* newkey = (char*)malloc(sizeof(char) * 33);
		int i = 0;
		while (i < 32 && adr[i])
		{
			newkey[i] = adr[i];
			i++;
		}
		newkey[i] = '\0';
		if (checkAPIKey(newkey))
		{
			msg(state, "applied it.\n");
			APIKEY = newkey;
		}
		else
		{
			msg(state, "found it but it's invalid\n");
			msg(state, newkey);
			msg(state, "\n");
			free(newkey);
		}
	}
	else
		msg(state, "[GMODSTORE MODULE] Could not find gmodstore key in commandline please use gmodstore.SetAPIKey(key)\n");
}

//
// Called when you module is opened
//


#define LUA_TABLE_SET_CFUNC(name, func) \
	LUA->PushString( name ); \
	LUA->PushCFunction( func ); \
	LUA->SetTable( -3 ); \

GMOD_MODULE_OPEN()
{
	parseAPIKeyFromCommandLine(state);

	//
	// Set Global[ "TextFunction" ] = MyExampleFunction
	//
	LUA->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);	// Push global table

	LUA->PushString("gmodstore");
	LUA->CreateTable();
	LUA_TABLE_SET_CFUNC("setAPIKey", LuaFunc_SetAPI);
	LUA_TABLE_SET_CFUNC("getAPIKey", LuaFunc_GetAPI);
	LUA_TABLE_SET_CFUNC("extractZIP", LuaFunc_ExtractZip);

	LUA->SetTable(-3);	// Set the table 

	return 0;
}

//
// Called when your module is closed
//
GMOD_MODULE_CLOSE()
{
	return 0;
}
