//  ----------------------------------------------------------------------------
//  sj_browser_sc_o1
//  ----------------------------------------------------------------------------
/*
    StartingConditional conversation event script for VFX Browser to check if
    the Force Full Cache option has been used.
*/
//  ----------------------------------------------------------------------------
/*
    Version 1.00 - 29 Nov 2004 - Sunjammer
    - created
*/
//  ----------------------------------------------------------------------------
#include "sj_browser_i"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    return GetLocalInt(oPC, SJ_VAR_BROWSER_CACHED) == FALSE;
}
