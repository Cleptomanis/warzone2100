/*
	This file is part of Warzone 2100.
	Copyright (C) 1999-2004  Eidos Interactive
	Copyright (C) 2005-2020  Warzone 2100 Project

	Warzone 2100 is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	Warzone 2100 is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Warzone 2100; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
*/
/** @file
 *  Control the data loading for game levels
 */

#ifndef __INCLUDED_SRC_LEVELS_H__
#define __INCLUDED_SRC_LEVELS_H__

#include "lib/framework/crc.h"
#include "init.h"
#include "gamedef.h"

#include <list>
#include <string>
#include <array>

/// maximum number of data files
#define LEVEL_MAXFILES	9

/// types of level datasets
enum class LEVEL_TYPE : uint8_t
{
	LDS_COMPLETE,		// all data required for a stand alone level
	LDS_CAMPAIGN,		// the data set for a campaign (no map data)
	LDS_CAMSTART,		// mapdata for the start of a campaign
	LDS_CAMCHANGE,		// data for changing between levels
	LDS_EXPAND,			// extra data for expanding a campaign map
	LDS_BETWEEN,		// pause between missions
	LDS_MKEEP,			// off map mission (extra map data)
	LDS_MCLEAR,			// off map mission (extra map data)
	LDS_EXPAND_LIMBO,   // expand campaign map using droids held in apsLimboDroids
	LDS_MKEEP_LIMBO,    // off map saving any droids (selectedPlayer) at end into apsLimboDroids
	LDS_NONE,			//flags when not got a mission to go back to or when
	//already on one - ****LEAVE AS LAST ONE****
	LDS_MULTI_TYPE_START,           ///< Start number for custom type numbers (as used by a `type` instruction)

	CAMPAIGN = 12,
	SKIRMISH = 14,
	MULTI_SKIRMISH2 = 18,
	MULTI_SKIRMISH3 = 19,
	MULTI_SKIRMISH4 = 20
};

struct LEVEL_DATASET
{
	LEVEL_TYPE type = LEVEL_TYPE::LDS_COMPLETE;				// type of map
	SWORD	players = 0;									// number of players for the map
	SWORD	game = 0;										// index of WRF/WDG that loads the scenario file
	std::string	pName;										// title for the level
	searchPathMode	dataDir = mod_clean;					// title for the level
	std::array<std::string, LEVEL_MAXFILES> apDataFiles;	// the WRF/GAM files for the level
	// in load order
	LEVEL_DATASET *psBaseData = nullptr;					// LEVEL_DATASET that must be loaded for this level to load
	LEVEL_DATASET *psChange = nullptr;						// LEVEL_DATASET used when changing to this level from another

	char *realFileName = nullptr;							///< Filename of the file containing the level, or NULL if the level is built in.
	Sha256 realFileHash;									///< Use levGetFileHash() to read this value. SHA-256 hash of the file containing the level, or 0x00×32 if the level is built in or not yet calculated.
	char *customMountPoint = nullptr;						///< A custom mount point (to be used for "flattened" map packages, or NULL for the default.

public:
	void reset();
};

typedef std::vector<LEVEL_DATASET *> LEVEL_LIST;

LEVEL_LIST enumerateMultiMaps(int camToUse, int numPlayers);

// parse a level description data file
bool levParse(const char *buffer, size_t size, searchPathMode datadir, bool ignoreWrf, char const *realFileName);

bool levParse_JSON(const std::string& mountPoint, const std::string& filename, searchPathMode pathMode, char const *realFileName);


namespace WzMap {
struct LevelDetails; // forward-declare
}
bool levAddWzMap(const WzMap::LevelDetails& levelDetails, searchPathMode pathMode, char const *realFileName);


// shutdown the level system
void levShutDown();

bool levInitialise();

// load up the data for a level
bool levLoadData(char const *name, Sha256 const *hash, char *pSaveName, GAME_TYPE saveType);

// find the level dataset
LEVEL_DATASET *levFindDataSet(char const *name, Sha256 const *hash = nullptr);

Sha256 levGetFileHash(LEVEL_DATASET *level);
Sha256 levGetMapNameHash(char const *name);

// should only be used for special cases
LEVEL_DATASET *levFindDataSetByRealFileName(char const *realFileName, Sha256 const *hash);
bool levRemoveDataSetByRealFileName(char const *realFileName, Sha256 const *hash);
bool levSetFileHashByRealFileName(char const *realFileName, Sha256 const &hash);

// free the currently loaded dataset
bool levReleaseAll(bool forceOnError = false);

// free the data for the current mission
bool levReleaseMissionData();

//get the type of level currently being loaded of GTYPE type
SDWORD getLevelLoadType();

const char *getLevelName();

std::string mapNameWithoutTechlevel(const char *mapName);

#endif // __INCLUDED_SRC_LEVELS_H__
