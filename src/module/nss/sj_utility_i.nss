//  ----------------------------------------------------------------------------
//  sj_utility_i
//  ----------------------------------------------------------------------------
/*
    Utility Library
*/
//  ----------------------------------------------------------------------------
/*
    Version 0.00 - 17 Aug 2004 - Sunjammer
    - cut-down version for use with VFX Browser
*/
//  ----------------------------------------------------------------------------
#include "sj_debug_i"


//  ----------------------------------------------------------------------------
//  CONSTANTS
//  ----------------------------------------------------------------------------

// datapoint blueprint and tag
const string SJ_RES_DATAPOINT   = "sj_datapoint";
const string SJ_TAG_DATAPOINT   = "dp_";


//  ----------------------------------------------------------------------------
//  PROTOTYPES
//  ----------------------------------------------------------------------------

// Returns TRUE if at least one instance sSubString exists in sString.
int SJ_GetHasSubString(string sString, string sSubString);

// Creates a waypoint at the start location to act as a temporary DataBase.
// Requires a unique tag created by adding SJ_TAG_DATAPOINT and sName. The tag
// cannot exceed 32 chars.
//  - sName:        unique identifier
//  * Returns:      waypoint object
//  * OnError:      returns OBJECT_INVALID
object SJ_CreateDatapoint(string sName);

// Destroys the datapoint (specially formatted/located waypoint) with sName.
//  - sName:        unique identifier
void SJ_DestroyDatapoint(string sName);

// Returns the datapoint (specially formatted/located waypoint) with sName.
//  - sName:        unique identifier
//  * Returns:      waypoint object
//  * OnError:      returns OBJECT_INVALID
object SJ_GetDatapoint(string sName);

// Returns TRUE if the datapoint (specially formatted/located waypoint) with
// sName exists.
//  - sName:        unique identifier
//  * Returns:      waypoint object
int SJ_GetIsDatapointValid(string sName);

// Gets a value from a 2DA file on the server and returns it as a string. The
// data being read can be cached to improve performance.  Large files can be
// cached using the "by column" option to improve performance.
//  - s2DA:         name of 2da file, 16 chars max
//  - sColumn:      name of column in the 2da
//  - nRow:         index of row in the 2da
//  - bCache:       TRUE (to cache the data) or FALSE
//  - bByColumn:    TRUE (to use a datapoint for each column) or FALSE
//  * OnError:      an empty string if file, row, or column not found
string SJ_Get2DAString(string s2DA, string sColumn, int nRow, int bCache=TRUE, int bByColumn=TRUE);


//  ----------------------------------------------------------------------------
//  FUNCTIONS
//  ----------------------------------------------------------------------------

int SJ_GetHasSubString(string sString, string sSubString)
{
    // index of 0 or higher means it has been found
    return (FindSubString(sString, sSubString) > -1);
}


string SJ_RemoveSubString(string sString, string sSubString)
{
    // format = left + substring + right
    // where left and/or right can be null

    int nPosition = FindSubString(sString, sSubString);

    if(nPosition > -1)
    {
        // get left stringlet
        string sLeft = GetStringLeft(sString, nPosition);

        // calculate remaining characters, get right stringlet
        int nCount = GetStringLength(sString) - GetStringLength(sLeft + sSubString);
        string sRight = GetStringRight(sString, nCount);

        // return left + right
        return sLeft + sRight;
    }
    else
    {
        // substring not found: return string
        return sString;
    }
}

object SJ_CreateDatapoint(string sName)
{
    string sDebug;
    string sTag = SJ_TAG_DATAPOINT + sName;

    // checks
    if(sName == "")
    {
        // check: name is null
        sDebug = "SJ_CreateDatapoint: failled as name was null.";
    }
    else if(GetStringLength(sTag) > 32)
    {
        // check: tag is too long
        sDebug = "SJ_CreateDatapoint: failled as tag (" + sTag + ") exceeded 32 characters.";
    }
    else if(GetIsObjectValid(GetWaypointByTag(sTag)))
    {
        // datapoint exists
        sDebug = "SJ_CreateDatapoint: failled as datpoint (" + sName + ") already exists.";
    }

    // create?
    if(sDebug == "")
    {
        // passed all checks: create datapoint
        location lDP = GetStartingLocation();
        return CreateObject(OBJECT_TYPE_WAYPOINT, SJ_RES_DATAPOINT, lDP, FALSE, sTag);
    }
    else
    {
        // log an error
        SJ_Debug(SJ_DEBUG_PREFIX_ERROR + sDebug, TRUE);
        return OBJECT_INVALID;
    }
}


void SJ_DestroyDatapoint(string sName)
{
    string sTag = SJ_TAG_DATAPOINT + sName;
    object oDP = GetWaypointByTag(sTag);

    if(GetIsObjectValid(oDP) == FALSE)
    {
        // log an error
        string sDebug = "SJ_DestroyDatapoint: failled as datapoint (" + sName + ") was invalid.";
        SJ_Debug(SJ_DEBUG_PREFIX_ERROR + sDebug, TRUE);
        return;
    }

    // datapoint is valid: destroy it
    DestroyObject(oDP);
}


object SJ_GetDatapoint(string sName)
{
    string sTag = SJ_TAG_DATAPOINT + sName;
    object oDP = GetWaypointByTag(sTag);

    if(GetIsObjectValid(oDP) == FALSE)
    {
        // log an error
        string sDebug = "SJ_GetDatapoint: failled as datapoint (" + sName + ") was invalid.";
        SJ_Debug(SJ_DEBUG_PREFIX_ERROR + sDebug, TRUE);
        return OBJECT_INVALID;
    }

    // datapoint is valid: return it
    return oDP;
}


int SJ_GetIsDatapointValid(string sName)
{
    string sTag = SJ_TAG_DATAPOINT + sName;
    object oDP = GetWaypointByTag(sTag);

    // check if a valid datapoint with sName exists
    return GetIsObjectValid(oDP);
}


string SJ_Get2DAString(string s2DA, string sColumn, int nRow, int bCache=TRUE, int bByColumn=TRUE)
{
    object oDP;
    string sRet, sVar;

    // use 2DA + column for large files
    string sName = (bByColumn) ? s2DA + sColumn : s2DA;

    if(bCache)
    {
        // get or create datapoint to hold 2DA
        if(SJ_GetIsDatapointValid(sName))
            oDP = SJ_GetDatapoint(sName);
        else
            oDP = SJ_CreateDatapoint(sName);

        // format: s2DA_sColumn_nRow
        sVar = s2DA + "_" + sColumn + "_" + IntToString(nRow);
        sRet = GetLocalString(oDP, sVar);

        if(sRet == "")
        {
            // read data, covert nulls to avoid unnecessary reads
            sRet = Get2DAString(s2DA, sColumn, nRow);
            if(sRet == "") sRet = "****";

            // cache data
            SetLocalString(oDP, sVar, sRet);
        }

        // revert nulls
        if(sRet == "****") sRet = "";
    }
    else
    {
        // read data
        sRet = Get2DAString(s2DA, sColumn, nRow);
    }

    return sRet;
}


//void main(){}
