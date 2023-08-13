#include "Networking.as"

NetworkManager@ manager;

void onInit(CRules@ this)
{
    this.addCommandID("client sync");
    this.addCommandID("server sync");
    this.addCommandID("remove");

    onRestart(this);
}

void onRestart(CRules@ this)
{
    this.set("network manager", null);
    @manager = Network::getManager();
}

void onTick(CRules@ this)
{
    if (getPlayerCount() == 0) return;

    Entity@[] entities = manager.getAll();

    for (uint i = 0; i < entities.size(); i++)
    {
        Entity@ entity = entities[i];

        CBitStream bs;
        bs.write_u16(entity.getType());
        bs.write_u16(entity.getID());
        entity.Serialize(bs);

        if (isServer())
        {
            this.SendCommand(this.getCommandID("server sync"), bs, true);
        }
        else if (entity.getOwner() is getLocalPlayer())
        {
            this.SendCommand(this.getCommandID("client sync"), bs, false);
        }
    }
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
    if (cmd == this.getCommandID("server sync") && !isServer())
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

            manager.Add(entity);
        }

        entity.deserialize(params);
    }
    else if (cmd == this.getCommandID("client sync") && !isClient())
    {
        u16 type;
        if (!params.saferead_u16(type)) return;

        u16 id;
        if (!params.saferead_u16(id)) return;

        Entity@ entity = manager.get(id);
        if (entity is null) return;

        if (entity.getOwner() !is getNet().getActiveCommandPlayer()) return;

        entity.deserialize(params);
    }
    else if (cmd == this.getCommandID("remove") && !isServer())
    {
        u16 id;
        if (!params.saferead_u16(id)) return;

        manager.Remove(id);
    }
}
