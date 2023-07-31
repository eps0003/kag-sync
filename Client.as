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
        u16 type;
        if (!params.saferead_u16(type)) return;

        u16 id;
        if (!params.saferead_u16(id)) return;

        Entity@ entity = manager.get(id);
        if (entity is null)
        {
            @entity = createEntity(type, id);
            if (entity is null)
            {
                error("Attempted to create entity with an invalid type");
                return;
            }
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
