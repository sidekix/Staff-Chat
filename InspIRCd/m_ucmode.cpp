/* **
 * m_ucmode.cpp
 * 
 * Module adds snomasks u, U, v and V allows opers to view any and ALL mode changes 
 * that are done by users to users and channels.
 *
 * This is kind of a update / re-write of my old m_usermode.cpp and m_chanmode.cpp modules for
 * InspIRCd 1.2, I figured I would redo them for 2.x but then decided why not mash it all into
 * one?
 * 
 * +---------+--------------+--------------------------------------------------------+
 * | SNOMask | Local|Remote | Function                                               |
 * +---------+--------------+--------------------------------------------------------+
 * | u       | Local        | Displays local users mode changes.                     |
 * | U       | Remote       | Displays remote user mode changes.                     |
 * | v       | Local        | Displays local user channel modes changes.             |
 * | V       | Remote       | Displays remote user channel modes changes.            |
 * +---------+--------------+--------------------------------------------------------|
 *
 * Module configuration;
 * By default this will eanble both sets of snomasks uU (User Mode Changes) and vV (Channel Modes Changes),
 * however this can be changed by using the following config tags somewhere in your InspIRCd configuration.
 *
 * <ucmodes umode_enabled="yes|no" cmode_enabled="yes|no">
 *
 * author: j. newing (synmuffin)
 * email: jnewing@gmail.com
 * url: http://epicgeeks.net
 *
 */ 
#include "inspircd.h"

class UCModeModule : public Module
{
 private:
    bool umode, cmode;
       
 public:
    UCModeModule()
    {
        // read the config
        OnRehash(NULL);
        
        if (umode)
        {
            ServerInstance->SNO->EnableSnomask('u', "USERMODE_LOCAL");
            ServerInstance->SNO->EnableSnomask('U', "USERMODE_REMOTE");
        }
        
        if (cmode)
        {
            ServerInstance->SNO->EnableSnomask('v', "CHANMODE_LOCAL");
            ServerInstance->SNO->EnableSnomask('V', "CHANMODE_REMOTE");
        }
		
		Implementation eventlist[] = { I_OnMode };
		ServerInstance->Modules->Attach(eventlist, this, 1);
    }
    
    ~UCModeModule() { }
    
    void OnMode(User* user, void* dest, int target_type, const std::vector<std::string> &text, const std::vector<TranslateType> &translate)
    {
        std::string params = irc::stringjoiner(" ", text, 0, text.size() - 1).GetJoined();
        
        if (target_type == TYPE_USER && umode)
        {
            if (IS_LOCAL(user))
                ServerInstance->SNO->WriteToSnoMask('u', "%s sets mode %s", user->nick.c_str(), params.c_str());
            else
                ServerInstance->SNO->WriteToSnoMask('U', "%s sets mode %s", user->nick.c_str(), params.c_str());
        }
            
        if (target_type == TYPE_CHANNEL && cmode)
        {
            Channel* chan = (Channel*)dest;
            
            if (IS_LOCAL(user))
                ServerInstance->SNO->WriteToSnoMask('v', "%s sets mode %s on %s", user->nick.c_str(), params.c_str(), chan->name.c_str());
            else
                ServerInstance->SNO->WriteToSnoMask('V', "%s set modes %s on %s", user->nick.c_str(), params.c_str(), chan->name.c_str());
        }
        
    }
    
    void OnRehash(User* user)
    {
        ConfigTag* tags = ServerInstance->Config->ConfValue("ucmodes");
		umode = tags->getBool("umode_enabled", true);
		cmode = tags->getBool("cmode_enabled", true);
    }
    
	Version GetVersion()
	{
		return Version("Adds snomasks u and U with notices of users changing modes - epicgeeks.net - synmuffin", VF_COMMON);
	}
    
};

MODULE_INIT(UCModeModule)

