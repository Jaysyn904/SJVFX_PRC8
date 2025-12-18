//  ----------------------------------------------------------------------------
//  sj_browser_sc_c1
//  ----------------------------------------------------------------------------
/*
    StartingConditional conversation event script for VFX Browser to read and
    display the custom filter spoken by the PC.  Returns TRUE if string is not
    null.
*/
//  ----------------------------------------------------------------------------
/*
    Version 1.00 - 28 Nov 2004 - Sunjammer
    - created
*/
//  ----------------------------------------------------------------------------
#include "sj_browser_i"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    // set custom token to reflect match
    // NOTE: use module as object cannot identify who spoke aloud
    string sMatch = GetLocalString(GetModule(), SJ_VAR_BROWSER_MATCH);
    SetCustomToken(800, sMatch);

    return sMatch != "";
}
