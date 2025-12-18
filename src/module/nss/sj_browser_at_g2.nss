//  ----------------------------------------------------------------------------
//  sj_browser_at_g2
//  ----------------------------------------------------------------------------
/*
    ActionTaken conversation event script for VFX Browser to set the group.
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
    SetLocalInt(oPC, SJ_VAR_BROWSER_G, 2);
}
