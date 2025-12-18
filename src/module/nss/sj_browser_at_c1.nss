//  ----------------------------------------------------------------------------
//  sj_browser_at_c1
//  ----------------------------------------------------------------------------
/*
    ActionTaken conversation event script for VFX Browser to clear custom
    filter.
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
    // clear any previous matchs
    // NOTE: use module as object cannot identify who spoke aloud
    DeleteLocalString(GetModule(), SJ_VAR_BROWSER_MATCH);
}
