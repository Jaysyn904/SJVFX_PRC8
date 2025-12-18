//  ----------------------------------------------------------------------------
//  sj_browser_at_t3
//  ----------------------------------------------------------------------------
/*
    ActionTaken conversation event script for VFX Browser to set the type.
*/
//  ----------------------------------------------------------------------------
/*
    Version 1.00 - 06 Feb 2005 - Sunjammer
    - created
*/
//  ----------------------------------------------------------------------------
#include "sj_browser_i"

void main()
{
    object oPC = GetPCSpeaker();
    SetLocalInt(oPC, SJ_VAR_BROWSER_T, 3);
}
