//  ----------------------------------------------------------------------------
//  sj_browser_at_f1
//  ----------------------------------------------------------------------------
/*
    ActionTaken conversation event script for VFX Browser to set the filter.
*/
//  ----------------------------------------------------------------------------
/*
    Version 1.00 - 18 Aug 2004 - Sunjammer
    - created
*/
//  ----------------------------------------------------------------------------
#include "sj_browser_i"

void main()
{
    object oPC = GetPCSpeaker();
    SetLocalInt(oPC, SJ_VAR_BROWSER_F, 1);

    SJ_Browser_SetFilter(oPC);
}

