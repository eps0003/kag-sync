#include "Networking.as"
#include "ToggleEntity.as"

NetworkManager@ manager;
ToggleEntity@ entity;

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
    if (isServer())
    {
        if (getGameTime() == 1)
        {
            @entity = ToggleEntity();
        }

        if (getGameTime() % getTicksASecond() == 0)
        {
            entity.Toggle();
        }

        Entity@[] entities = manager.getAll();

        for (uint i = 0; i < entities.size(); i++)
        {
            Entity@ entity = entities[i];

            CBitStream bs;
            bs.write_u16(entity.getType());
            bs.write_u16(entity.getID());
            entity.Serialize(bs);

            this.SendCommand(this.getCommandID("sync"), bs, true);
        }
    }

    if (isClient())
    {
        ToggleEntity@ entity = cast<ToggleEntity>(manager.get(1));
        if (entity !is null)
        {
            print(""+entity.getToggled());
        }
    }
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
    if (cmd == this.getCommandID("sync") && !isServer())
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
    else if (cmd == this.getCommandID("remove") && !isServer())
    {
        u16 id;
        if (!params.saferead_u16(id)) return;

        manager.Remove(id);
    }
}

shared Entity@ createEntity(u16 type, u16 id)
{
	switch (type)
	{
	case EntityType::ToggleEntity:
		return ToggleEntity(id);
	}
	return null;
}

shared enum EntityType
{
	ToggleEntity
}
