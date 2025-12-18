//  ----------------------------------------------------------------------------
//  sj_browser_at_s1
//  ----------------------------------------------------------------------------
/*
    ActionTaken conversation event script for VFX Browser to set the source.
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
    SetLocalString(oPC, SJ_VAR_BROWSER_SOURCE, SJ_2DA_VFX);
}
