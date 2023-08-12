#include "Networking.as"

NetworkManager@ manager;

void onInit(CRules@ this)
{
    onRestart(this);
}

void onRestart(CRules@ this)
{
    @manager = Network::getManager();
}

void onTick(CRules@ this)
{
    Entity@[] entities = manager.getAll();

    for (uint i = 0; i < entities.size(); i++)
    {
        Entity@ entity = entities[i];

        if (isServer() || entity.getOwner() is getLocalPlayer())
        {
            CBitStream bs;
            bs.write_bool(isServer());
            bs.write_u16(entity.getType());
            bs.write_u16(entity.getID());
            entity.Serialize(bs);

            this.SendCommand(this.getCommandID("sync"), bs, isServer());
        }
    }
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
    if (cmd == this.getCommandID("sync"))
    {
        bool server;
        if (!params.saferead_bool(server)) return;

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

            entity.deserialize(params);
            manager.Add(entity);
        }
        else if (server != isServer())
        {
            entity.deserialize(params);
        }
    }
    else if (cmd == this.getCommandID("remove") && !isServer())
    {
        u16 id;
        if (!params.saferead_u16(id)) return;

        manager.Remove(id);
    }
}
