//  ----------------------------------------------------------------------------
//  sj_browser_at_a1
//  ----------------------------------------------------------------------------
/*
    ActionTaken conversation event script for VFX Browser to set and reset the
    browser.  This includes counting the VFX and AOE effects if not done so and
    resetting the index.
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
    SJ_Browser_ResetBrowser(oPC);
}
