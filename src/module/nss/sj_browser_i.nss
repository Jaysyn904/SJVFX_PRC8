//  ----------------------------------------------------------------------------
//  sj_browser_i
//  ----------------------------------------------------------------------------
/*
    VFX Browser Library

    The VFX Browser allows a PC to select a group of VFX effects or AOE effects
    and view them in turn by navigating backwards and forwards through the list.
    The PC can select a pre-defined filter or can define their own filter to
    locate the effect(s) they are interested in.

    For each effect the browser will attempt to apply it to the dummy or at the
    dummy's location while displaying the number and the label. Please note that
    while the label is often the same as the VFX_* or AOE_* constant this is not
    always the case: the constant may differ, only be available in an include or
    may not exist at all. In such cases however you can still use the number.
*/
//  ----------------------------------------------------------------------------
/*
    Version 1.04 - 06 Feb 2004 - Sunjammer
    - added SJ_Browser_DisplayAgain()
    - added SJ_Browser_GetIsUnsupported()
    - added filter by (magic) number option
    - fix for VFX_COM_UNLOAD_MODEL which unloaded the dummy's model preventing
      subsequent effects being displayed for some users

    Version 1.03 - 01 Dec 2004 - Sunjammer
    - improved handling when only one match

    Version 1.02 - 27 Nov 2004 - Sunjammer
    - added listening pattern for custom filters
    - change from arrays to cached 2DA

    Version 1.01 - 08 Sep 2004 - Sunjammer
    - minor tweaking and optimising

    Version 1.00 - 18 Aug 2004 - Sunjammer
    - created
*/
//  ----------------------------------------------------------------------------
#include "sj_utility_i"


//  ----------------------------------------------------------------------------
//  CONSTANTS
//  ----------------------------------------------------------------------------

// General error code
const int SJ_BROWSER_ERROR = -1;

// Custom filter listening pattern
const int SJ_BROWSER_LISTENING_PATTERN = 800;

// Controls the VFX row number from which to start the init check.
const int SJ_BROWSER_AOE_CHECK_FROM  = 44;
const int SJ_BROWSER_VFX_CHECK_FROM  = 511;

// Controls the duration of temporary VFXs.
const float SJ_BROWSER_VFX_DURATION  = 5.0;

// 2DA filenames
const string SJ_2DA_VFX = "visualeffects";
const string SJ_2DA_AOE = "vfx_persistent";

// Object blueprints
const string SJ_RES_INVISIBLE_OBJECT = "plc_invisobj";
const string SJ_RES_BROWSER_DUMMY    = "sj_dummy";

// Object tags
const string SJ_TAG_BROWSER_MENU     = "sj_browser_menu";
const string SJ_TAG_BROWSER_NEXT     = "sj_browser_next";
const string SJ_TAG_BROWSER_PREV     = "sj_browser_prev";
const string SJ_TAG_BROWSER_AGAIN    = "sj_browser_again";

// System variable names
const string SJ_VAR_BROWSER_F        = "sj_browser_f";
const string SJ_VAR_BROWSER_G        = "sj_browser_g";
const string SJ_VAR_BROWSER_T        = "sj_browser_t";
const string SJ_VAR_BROWSER_CACHED   = "sj_browser_cached";
const string SJ_VAR_BROWSER_COUNT    = "sj_browser_count";
const string SJ_VAR_BROWSER_FILTER   = "sj_browser_filter";
const string SJ_VAR_BROWSER_INDEX    = "sj_browser_index";
const string SJ_VAR_BROWSER_MATCH    = "sj_browser_match";
const string SJ_VAR_BROWSER_SOURCE   = "sj_browser_source";

// Text strings
const string SJ_TXT_BROWSER_NO_MATCH    = "No matches could be found. Please use the control to select another category.";
const string SJ_TXT_BROWSER_NO_SOURCE   = "Please use the control and select a category of VFXs to browse.";
const string SJ_TXT_BROWSER_NO_EFFECT   = "The number you specified exceeds the number of effects available. Please use Restart to start over.";


//  ----------------------------------------------------------------------------
//  PROTOTYPES
//  ----------------------------------------------------------------------------

// Generates the appropriate VFX.
void SJ_Browser_DisplayEffect(object oPC, string sSource, int nVFX);

// Displays the VFX Browers menu convresation.
void SJ_Browser_DisplayMenu(object oPC);

// Displays the next VFX.
void SJ_Browser_DisplayNext(object oPC);

// Displays the prevous VFX.
void SJ_Browser_DisplayPrev(object oPC);

// Displays the most recent VFX again.
void SJ_Browser_DisplayAgain(object oPC);

// Forces the first two columns of both 2DAs to be cached.
void SJ_Browser_ForcedCache(object oPC);

// Forces sColumn in s2DA to be cached.
//void SJ_Browser_ForcedCacheColumn(object oPC, string s2DA, string sColumn);
void SJ_Browser_ForcedCacheColumn(object oPC, string s2DA, string sColumn, int bValidityCheck = FALSE);

// Returns TRUE if the VFX in nRow of sSource matches the filter critera.
int SJ_Browser_GetIsMatch(string sSource, string sFilter, int nRow);

// Returns TRUE if the VFX represents a TileMagic effect.
int SJ_Browser_GetIsTileMagic(int nVFX);

// Returns TRUE if the VFX represents an unsupported effect
int SJ_Browser_GetIsUnsupported(string sSource, int nVFX);

// Returns a value sufficient to offset a TileMagic effects internal height.
float SJ_Browser_GetNormalisedHeight(int nVFX);

// Sets the filter according to user's selection.
void SJ_Browser_SetFilter(object oPC);

// Resets brower controls for a new search;
void SJ_Browser_ResetBrowser(object oPC);


//  ----------------------------------------------------------------------------
//  FUNCTIONS
//  ----------------------------------------------------------------------------

void SJ_Browser_DisplayEffect(object oPC, string sSource, int nVFX)
{
    effect eVFX;
    int nType;

    // assign appropriate column names for source
    string sColumn1 = (sSource == SJ_2DA_VFX) ? "Label" : "LABEL";
    string sColumn2 = (sSource == SJ_2DA_VFX) ? "Type_FD" : "SHAPE";

    // get VFX descriptor and type
    string sLabel = SJ_Get2DAString(sSource, sColumn1, nVFX);
    string sType = SJ_Get2DAString(sSource, sColumn2, nVFX);

    // work around for the evil unsupported well/cage effects
    if(SJ_Browser_GetIsUnsupported(sSource, nVFX))
    {
        SendMessageToPC(oPC, IntToString(nVFX) + ": " + sLabel + " - cannot be displayed.");
        return;
    }

    // set up according to effect type
    if(sType == "B")
    {
        // beam
        eVFX = EffectBeam(nVFX, GetObjectByTag(SJ_TAG_BROWSER_MENU), BODY_NODE_CHEST);
        nType = DURATION_TYPE_TEMPORARY;
    }
    else if(sType == "D")
    {
        eVFX = EffectVisualEffect(nVFX);
        nType = DURATION_TYPE_TEMPORARY;
    }
    else if(sType == "F" || sType == "P")
    {
        eVFX = EffectVisualEffect(nVFX);
        nType = DURATION_TYPE_INSTANT;
    }
    else if(sType == "C" || sType == "R")
    {
        eVFX = EffectAreaOfEffect(nVFX, "sj_null", "sj_null", "sj_null");
        nType = DURATION_TYPE_TEMPORARY;
    }

    // get the target
    object oTarget = GetObjectByTag(SJ_RES_BROWSER_DUMMY);

    // create the visual effect
    if(SJ_Browser_GetIsTileMagic(nVFX))
    {
        // use the target as a starting point and adjust height
        vector vTarget = GetPosition(oTarget);
        vTarget.z += SJ_Browser_GetNormalisedHeight(nVFX) + 0.01;

        // create and destroy an invisible object
        location lInvis = Location(GetArea(oTarget), vTarget, GetFacing(oTarget));
        object oInvis = CreateObject(OBJECT_TYPE_PLACEABLE, SJ_RES_INVISIBLE_OBJECT, lInvis);
        DestroyObject(oInvis, SJ_BROWSER_VFX_DURATION);

        // apply tilemagic effect to invisible object
        ApplyEffectToObject(nType, eVFX, oInvis, SJ_BROWSER_VFX_DURATION);

    }
    else if(nType == DURATION_TYPE_TEMPORARY)
    {
        // apply duration effect to target
        ApplyEffectToObject(nType, eVFX, oTarget, SJ_BROWSER_VFX_DURATION);
    }
    else
    {
        // apply instant/fire and forget effect to target
        ApplyEffectToObject(nType, eVFX, oTarget);
    }

    // inform the user
    SendMessageToPC(oPC, IntToString(nVFX) + ": " + sLabel);
}


void SJ_Browser_DisplayMenu(object oPC)
{
    object oMenu = OBJECT_SELF;

    SetListening(oMenu, TRUE);
    SetListenPattern(oMenu, "**", SJ_BROWSER_LISTENING_PATTERN);

    // launch the control conversation
    BeginConversation("sj_browser", oPC);
}


void SJ_Browser_DisplayNext(object oPC)
{
    int bMatch;
    int bLooped;

    // get current source (array/2DA)
    string sSource = GetLocalString(oPC, SJ_VAR_BROWSER_SOURCE);
    string sFilter = GetLocalString(oPC, SJ_VAR_BROWSER_FILTER);

    if(sSource == "" || sFilter == "")
    {
        // abort if no selection
        SendMessageToPC(oPC, SJ_TXT_BROWSER_NO_SOURCE);
        return;
    }

    // get the source specific count and current index
    int nCount = GetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + sSource);
    int nIndex = GetLocalInt(oPC, SJ_VAR_BROWSER_INDEX);
    int nStart = nIndex;

    // iterate through each entry in turn seeking a match
    while(bMatch == FALSE)
    {
        // start looking for the next one
        nIndex++;

        // jump to first effect if we have past the last
        if(nIndex > nCount)
        {
            nIndex = -1;
            bLooped = TRUE;
        }

        // abort if we have reached the point we started from
        // NOTE: this comes after the loop check when navigating forwards
        if(bLooped && nIndex > nStart)
        {
            SendMessageToPC(oPC, SJ_TXT_BROWSER_NO_MATCH);
            return;
        }

        // check it for a match
        bMatch = SJ_Browser_GetIsMatch(sSource, sFilter, nIndex);
    }

    // update the index
    SetLocalInt(oPC, SJ_VAR_BROWSER_INDEX, nIndex);

    // display the effect and feedback
    SJ_Browser_DisplayEffect(oPC, sSource, nIndex);
}


void SJ_Browser_DisplayPrev(object oPC)
{
    int bMatch;
    int bLooped;

    // get current source (array/2DA)
    string sSource = GetLocalString(oPC, SJ_VAR_BROWSER_SOURCE);
    string sFilter = GetLocalString(oPC, SJ_VAR_BROWSER_FILTER);

    if(sSource == "" || sFilter == "")
    {
        // abort if no selection
        SendMessageToPC(oPC, SJ_TXT_BROWSER_NO_SOURCE);
        return;
    }

    // get the source specific count and current index
    int nCount = GetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + sSource);
    int nIndex = GetLocalInt(oPC, SJ_VAR_BROWSER_INDEX);
    int nStart = (nIndex < 0) ? 0 : nIndex;

    // iterate through each entry in turn seeking a match
    while(bMatch == FALSE)
    {
        // start looking for the next one
        nIndex--;

        // abort if we have looped past the point we started from
        // NOTE: this comes before the loop check when navigating backwards
        if(bLooped && nIndex < nStart)
        {
            SendMessageToPC(oPC, SJ_TXT_BROWSER_NO_MATCH);
            return;
        }

        // jump to last effect if we have past the first
        if(nIndex < 0)
        {
            nIndex = nCount - 1;
            bLooped = TRUE;
        }

        // check it for a match
        bMatch = SJ_Browser_GetIsMatch(sSource, sFilter, nIndex);
    }

    // update the index
    SetLocalInt(oPC, SJ_VAR_BROWSER_INDEX, nIndex);

    // display the effect and feedback
    SJ_Browser_DisplayEffect(oPC, sSource, nIndex);
}


void SJ_Browser_DisplayAgain(object oPC)
{
    // get current source (array/2DA) and index
    string sSource = GetLocalString(oPC, SJ_VAR_BROWSER_SOURCE);
    string sFilter = GetLocalString(oPC, SJ_VAR_BROWSER_FILTER);

    if(sSource == "" || sFilter == "")
    {
        // abort if no selection
        SendMessageToPC(oPC, SJ_TXT_BROWSER_NO_SOURCE);
        return;
    }

    // get current effect index
    int nIndex = GetLocalInt(oPC, SJ_VAR_BROWSER_INDEX);

    if(nIndex == -1)
    {
        // if no index then go next
        // NOTE: this only occurs if next/prev hasn't been used since a reset
        SJ_Browser_DisplayNext(oPC);
        return;
    }

    // force the browser menu control to display the effect
    // NOTE: only because this looks better for projectile effects
    object oControl = GetObjectByTag(SJ_TAG_BROWSER_MENU);
    AssignCommand(oControl, SJ_Browser_DisplayEffect(oPC, sSource, nIndex));
}

void SJ_Browser_ForcedCache(object oPC)
{
    // AOE: cache SHAPE for counting validity
    AssignCommand(OBJECT_SELF,
        SJ_Browser_ForcedCacheColumn(oPC, SJ_2DA_AOE, "SHAPE", TRUE));
 
    // VFX: cache Type_FD for counting validity  
    AssignCommand(OBJECT_SELF,
        SJ_Browser_ForcedCacheColumn(oPC, SJ_2DA_VFX, "Type_FD", TRUE));
}


/* void SJ_Browser_ForcedCache(object oPC)
{
    // cache each of the 4 columns
    // NOTE: use AssignCommand to avoid a TMI
    AssignCommand(OBJECT_SELF, SJ_Browser_ForcedCacheColumn(oPC, SJ_2DA_AOE, "LABEL"));
    AssignCommand(OBJECT_SELF, SJ_Browser_ForcedCacheColumn(oPC, SJ_2DA_AOE, "SHAPE"));
    AssignCommand(OBJECT_SELF, SJ_Browser_ForcedCacheColumn(oPC, SJ_2DA_VFX, "Label"));
    AssignCommand(OBJECT_SELF, SJ_Browser_ForcedCacheColumn(oPC, SJ_2DA_VFX, "Type_FD"));
} */

void SJ_Browser_ForcedCacheColumn(object oPC, string s2DA, string sColumn, int bValidityCheck = FALSE)
{
    int nRow;
    string sCell;
    int nValidCount = 0;
    int nMaxRow = (s2DA == SJ_2DA_VFX) ? 1335 : 10000;  // Cap VFX at 1335 for PRC8
 
    if(bValidityCheck)
    {
        // Count ALL rows with valid data in validity column
        string sValidityCol = (s2DA == SJ_2DA_VFX) ? "Type_FD" : "SHAPE";
        
        for(nRow = 0; nRow <= nMaxRow; nRow++)
        {
            string sValidityCell = Get2DAString(s2DA, sValidityCol, nRow);
            
            if(sValidityCell != "")
            {
                nValidCount = nRow + 1;  // Track highest valid row (1-based)
            }
        }
        
        nRow = nValidCount;  // Use this as our count
    }
    else
    {
        // Regular caching - stop at blank in specified column
        nRow = -1;
        while(TRUE)
        {
            nRow++;
            sCell = Get2DAString(s2DA, sColumn, nRow);
            
            if(sCell == "")
            {
                break;
            }
        }
    }
 
    if(GetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + s2DA) == 0)
    {
        SetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + s2DA, nRow);
 
        string sSource = (s2DA == SJ_2DA_AOE) ? "AOE" : "VFX";
        SendMessageToPC(oPC, sSource + " Count: " + IntToString(nRow));
    }
}

/* void SJ_Browser_ForcedCacheColumn(object oPC, string s2DA, string sColumn)
{
    string sCell;

    // NOTE: start at -1 as we pre-increment
    // NOTE: this ensures the final count is correct
    int nRow = -1;

    do
    {
        // iterate through each row until a blank is encountered
        sCell = SJ_Get2DAString(s2DA, sColumn, ++nRow);
    }
    while(sCell != "");

    if(GetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + s2DA) == 0)
    {
        // store the count if not done before
        SetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + s2DA, nRow);

        // inform PC of count if not done before
        string sSource = (s2DA == SJ_2DA_AOE) ? "AOE" : "VFX";
        SendMessageToPC(oPC, sSource + " Count: " + IntToString(nRow));
    }
}
 */

int SJ_Browser_GetIsMatch(string sSource, string sFilter, int nRow)
{
    string sType;

    // assign appropriate column names for source
    string sColumn1 = (sSource == SJ_2DA_VFX) ? "Label" : "LABEL";
    string sColumn2 = (sSource == SJ_2DA_VFX) ? "Type_FD" : "SHAPE";

    // set the column the filter relates to
    // check length as second column is always only 1 character
    int nFilterOn = (GetStringLength(sFilter) > 1) ? 1 : 2;

    // get primary data
    // NOTE: looping so cache data
    string sLabel = SJ_Get2DAString(sSource, sColumn1, nRow);

    // check exclusions
    if(sLabel == "DELETED"
    || sLabel == "PADDING"
    || sLabel == "RESERVED"
    || SJ_GetHasSubString(GetStringUpperCase(sLabel), "XXX"))
    {
        // excluded
        return FALSE;
    }

    // get the additional data if required
    if(nFilterOn == 2)
    {
        // NOTE: looping so cache data
        sType = SJ_Get2DAString(sSource, sColumn2, nRow);
    }

    // filter
    if((nFilterOn == 1 && SJ_GetHasSubString(sLabel, sFilter))
    || (nFilterOn == 2 && SJ_GetHasSubString(sType, sFilter)))
    {
        // match
        return TRUE;
    }

    // no match
    return FALSE;
}


int SJ_Browser_GetIsTileMagic(int nVFX)
{
    // default
    int bRet = FALSE;

    switch(nVFX)
    {
        // parse nVFX for special cases
        case 347: case 348: case 349: case 350: case 401:
        case 402: case 404: case 405: case 406: case 426:
        case 427: case 428: case 429: case 430: case 431:
        case 432: case 433: case 434: case 435: case 436:
        case 440: case 441: case 442: case 443: case 449:
        case 450: case 437: case 438: case 439: case 451:
        case 452: case 453: case 454: case 455: case 457:
        case 458: case 461: case 506: case 511:
            bRet = TRUE;
            break;
    }

    // retrun result
    return bRet;
}


int SJ_Browser_GetIsUnsupported(string sSource, int nVFX)
{
    if(sSource == SJ_2DA_VFX)
    {
        // exceptions for visualeffects.2da
        switch(nVFX)
        {
            case 120: return TRUE;  // unload model
            case 358: return TRUE;  // unremovable well
            case 508: return TRUE;  // unremovable cage
            case 509: return TRUE;  // unremovable cage
        }
    }
    else
    {
        // exceptions for vfx_persistent.2da
        // (none)
    }

    return FALSE;
}


float SJ_Browser_GetNormalisedHeight(int nVFX)
{
    // default
    float fRet = 0.0;

    switch(nVFX)
    {
        // parse nVFX for duplicates
        case 348: nVFX = 347; break;
        case 430: nVFX = 429; break;
        case 431: nVFX = 428; break;
        case 441: nVFX = 404; break;
        case 453: nVFX = 347; break;
        case 456: nVFX = 432; break;
    }


    switch(nVFX)
    {
        // parse nVFX for special cases
        case 349: fRet = 1.00; break;
        case 350: fRet = 1.00; break;
        case 401: fRet = 1.00; break;
        case 437: fRet = 1.00; break;
        case 461: fRet = 2.00; break;
        case 506: fRet = 2.40; break;
    }

    // return corrected height
    return fRet;
}


void SJ_Browser_SetFilter(object oPC)
{
    string sFilter;
    object oModule = GetModule();

    // get selection (type, group, filter)
    int nT = GetLocalInt(oPC, SJ_VAR_BROWSER_T);
    int nG = GetLocalInt(oPC, SJ_VAR_BROWSER_G);
    int nF = GetLocalInt(oPC, SJ_VAR_BROWSER_F);


    // generate an id based on selections
    int nFilter = (nT * 100) + (nG * 10) + nF;
    if(GetLocalString(oPC, SJ_VAR_BROWSER_SOURCE) == SJ_2DA_AOE) nFilter += 1000;


    // nFilter = STGF
    switch(nFilter)
    {
        case 111: sFilter = "ACID";     break;
        case 112: sFilter = "COLD";     break;
        case 113: sFilter = "ELEC";     break;
        case 114: sFilter = "FIRE";     break;
        case 115: sFilter = "HOLY";     break;
        case 116: sFilter = "NEGA";     break;
        case 117: sFilter = "SONI";     break;

        case 121: sFilter = "VFX_BEAM"; break;
        case 122: sFilter = "VFX_COM";  break;
        case 123: sFilter = "VFX_DUR";  break;
        case 124: sFilter = "VFX_FNF";  break;
        case 125: sFilter = "VFX_IMP";  break;
        case 126: sFilter = "SCENE";    break;

        case 131: sFilter = GetLocalString(oModule, SJ_VAR_BROWSER_MATCH); break;

        case 201: sFilter = "B";        break;
        case 202: sFilter = "D";        break;
        case 203: sFilter = "F";        break;
        case 204: sFilter = "P";        break;


        // -----------------------------------

        case 1111: sFilter = "VFX_PER"; break;
        case 1112: sFilter = "VFX_MOB"; break;
        case 1113: sFilter = "CUSTOM";  break;

        case 1121: sFilter = GetLocalString(oModule, SJ_VAR_BROWSER_MATCH); break;

        case 1201: sFilter = "C";       break;
        case 1202: sFilter = "R";       break;
    }

    // special case for "by number" search
    // TODO: make this more efficient by jumping to *_DisplayEffect or the like
    //       since we know the index it seems silly to use it to find a filter
    //       that can be used to find the index.
    if(nT == 3)
    {
        // NOTE: the match is on the module, source is on the PC
        string sSource = GetLocalString(oPC, SJ_VAR_BROWSER_SOURCE);
        int nMatch = abs(StringToInt(GetLocalString(oModule, SJ_VAR_BROWSER_MATCH)));

        // check if it is out of bounds (force the count if necessary)
        int nCount = GetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + sSource);

        if(nCount == 0)
        {
            // no count has been performed: force count so match can be checked
            SJ_Browser_ResetBrowser(oPC);
            nCount = GetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + sSource);
        }

        if(nMatch > nCount - 1)
        {
            // specified row number is out of bounds: advise user
            SendMessageToPC(oPC, SJ_TXT_BROWSER_NO_EFFECT);
        }

        // get the filter from the 2DA
        sFilter = SJ_Get2DAString(sSource, "Label", nMatch);
    }

    // clean up
    DeleteLocalInt(oPC, SJ_VAR_BROWSER_T);
    DeleteLocalInt(oPC, SJ_VAR_BROWSER_G);
    DeleteLocalInt(oPC, SJ_VAR_BROWSER_F);

    // set filter
    SetLocalString(oPC, SJ_VAR_BROWSER_FILTER, sFilter);
}


void SJ_Browser_ResetBrowser(object oPC)
{
    int nRow;
    string sLabel;

    // AOE count
    if(GetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + SJ_2DA_AOE) == 0)
    {
        nRow = SJ_BROWSER_AOE_CHECK_FROM;

        do
        {
            sLabel = Get2DAString(SJ_2DA_AOE, "LABEL", ++nRow);
        }
        while(sLabel != "");

        SetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + SJ_2DA_AOE, nRow);
        SendMessageToPC(oPC, "AOE Count: " + IntToString(nRow));
    }

    // VFX count
    if(GetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + SJ_2DA_VFX) == 0)
    {
        nRow = SJ_BROWSER_VFX_CHECK_FROM;

        do
        {
            sLabel = Get2DAString(SJ_2DA_VFX, "Label", ++nRow);
        }
        while(sLabel != "");

        SetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + SJ_2DA_VFX, nRow);
        SendMessageToPC(oPC, "VFX Count: " + IntToString(nRow));
    }

    SetLocalInt(oPC, SJ_VAR_BROWSER_INDEX, -1);
}


/* void SJ_Browser_ResetBrowser(object oPC)
{
    int nRow;
    string sLabel;

    if(GetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + SJ_2DA_AOE) == 0
    || GetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + SJ_2DA_VFX) == 0)
    {
        // count number of AOE
        nRow = SJ_BROWSER_AOE_CHECK_FROM;

        // itereate through each row from the last known to exist
        do
        {
            // get the next until we find a blank one
            sLabel = SJ_Get2DAString(SJ_2DA_AOE, "LABEL", ++nRow);
        }
        while(sLabel != "");

        SetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + SJ_2DA_AOE, nRow);
        SendMessageToPC(oPC, "AOE Count: " + IntToString(nRow));

        // count number of VFX
        nRow = SJ_BROWSER_VFX_CHECK_FROM;

        // itereate through each row from the last known to exist
        do
        {
            // get the next until we find a blank one
            sLabel = SJ_Get2DAString(SJ_2DA_VFX, "Label", ++nRow);
        }
        while(sLabel != "");

        SetLocalInt(oPC, SJ_VAR_BROWSER_COUNT + SJ_2DA_VFX, nRow);
        SendMessageToPC(oPC, "VFX Count: " + IntToString(nRow));
    }

    // reset index
    SetLocalInt(oPC, SJ_VAR_BROWSER_INDEX, -1);
}
 */

// void main(){}
