//  ----------------------------------------------------------------------------
//  sj_browser_at_o1
//  ----------------------------------------------------------------------------
/*
    ActionTaken conversation event script for VFX Browser to force a full cache
    of all relevant data.
*/
//  ----------------------------------------------------------------------------
/*
    Version 1.00 - 27 Nov 2004 - Sunjammer
    - created
*/
//  ----------------------------------------------------------------------------
#include "sj_browser_i"

void main()
{
    object oPC = GetPCSpeaker();
    SJ_Browser_ForcedCache(oPC);
    SetLocalInt(oPC, SJ_VAR_BROWSER_CACHED, TRUE);
}
