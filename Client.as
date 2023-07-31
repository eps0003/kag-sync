#include "Entity.as"
#include "NetworkManager.as"

#define CLIENT_ONLY;

NetworkManager@ manager;

void onInit(CRules@ this)
{
    onRestart(this);
}

void onRestart(CRules@ this)
{
    @manager = Network::getManager();
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
    if (cmd == this.getCommandID("sync"))
    {
        u16 id;
        if (!params.saferead_u16(id)) return;

        Entity@ entity = manager.get(id);
        if (entity is null)
        {
            @entity = Entity(id);
        }

        entity.deserialize(params);
    }
    else if (cmd == this.getCommandID("remove"))
    {
        u16 id;
        if (!params.saferead_u16(id)) return;

        manager.Remove(id);
    }
}
