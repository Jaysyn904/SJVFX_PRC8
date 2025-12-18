//  ----------------------------------------------------------------------------
//  nw_g0_conversat
//  ----------------------------------------------------------------------------
/*
    This is the default script that is called if no OnConversation script is
    specified.

    Modified to allow listening placeables by signaling a user event with the
    same number as the listening pattern just matched to the listening object.
*/
//  ----------------------------------------------------------------------------
/*
    Version 1.00 - 27 Nov 2004 - Sunjammer
    - modified
*/
//  ----------------------------------------------------------------------------
#include "inc_eventhook"

void main()
{
    int nPattern = GetListenPatternNumber();

    if(nPattern == -1)
    {
        // begin the default conversation
        BeginConversation();
    }
    else
    {
        // forward the listening pattern to the listening object as an event
        SignalEvent(OBJECT_SELF, EventUserDefined(nPattern));
    }
	
	ExecuteAllScriptsHookedToEvent(OBJECT_SELF, EVENT_VIRTUAL_ONCONVERSATION);
}
