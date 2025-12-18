//  ----------------------------------------------------------------------------
//  sj_browser_at_t2
//  ----------------------------------------------------------------------------
/*
    ActionTaken conversation event script for VFX Browser to set the type.
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
    SetLocalInt(oPC, SJ_VAR_BROWSER_T, 2);
}
