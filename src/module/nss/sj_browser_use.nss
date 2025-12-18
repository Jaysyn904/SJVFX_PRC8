//  ----------------------------------------------------------------------------
//  sj_browser_use
//  ----------------------------------------------------------------------------
/*
    OnUsed Event Script for the VFX Browser controls.
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
    object oPC = GetLastUsedBy();
    string sTag = GetTag(OBJECT_SELF);

    // parse the tag and call appropriate function
    if(sTag == SJ_TAG_BROWSER_MENU) SJ_Browser_DisplayMenu(oPC);
    else if(sTag == SJ_TAG_BROWSER_NEXT) SJ_Browser_DisplayNext(oPC);
    else if(sTag == SJ_TAG_BROWSER_PREV) SJ_Browser_DisplayPrev(oPC);
    else if(sTag == SJ_TAG_BROWSER_AGAIN) SJ_Browser_DisplayAgain(oPC);
}
