#include "Networking.as"

NetworkManager@ manager;

void onInit(CRules@ this)
{
	this.addCommandID("create");
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
	u16[] ids = manager.getIds();

	for (uint i = 0; i < entities.size(); i++)
	{
		Entity@ entity = entities[i];
		u16 id = ids[i];

		entity.Update();

		CBitStream bs;
		bs.write_u16(id);

		CBitStream entityBs;
		entity.Serialize(entityBs);

		if (entityBs.Length() > 0)
		{
			bs.writeBitStream(entityBs);

			if (isServer())
			{
				this.SendCommand(this.getCommandID("server sync"), bs, true);
			}
			else
			{
				this.SendCommand(this.getCommandID("client sync"), bs, false);
			}
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (!isServer()) return;

	Entity@[] entities = manager.getAll();
	u16[] ids = manager.getIds();

	for (uint i = 0; i < entities.size(); i++)
	{
		Entity@ entity = entities[i];
		u16 id = ids[i];

		CBitStream bs;
		bs.write_u16(entity.getType());
		bs.write_u16(id);

		CBitStream entityBs;
		entity.Serialize(entityBs);

		if (entityBs.Length() > 0)
		{
			bs.writeBitStream(entityBs);

			this.SendCommand(this.getCommandID("create"), bs, player);
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("create") && !isServer())
	{
		u16 type;
		if (!params.saferead_u16(type)) return;

		u16 id;
		if (!params.saferead_u16(id)) return;

		Entity@ entity = createEntity(type);
		if (entity is null)
		{
			error("Attempted to create entity with an invalid type");
			return;
		}

		if (!entity.deserialize(params))
		{
			error("Failed to deserialize entity: " + id);
		}

		manager._Add(entity, id);
	}
	else if (cmd == this.getCommandID("server sync") && !isServer())
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		Entity@ entity = manager.get(id);
		if (entity is null) return;

		if (!entity.deserialize(params))
		{
			error("Failed to deserialize entity: " + id);
		}
	}
	else if (cmd == this.getCommandID("client sync") && isServer())
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		Entity@ entity = manager.get(id);
		if (entity is null) return;

		if (!entity.deserialize(params))
		{
			error("Failed to deserialize entity: " + id);
		}
	}
	else if (cmd == this.getCommandID("remove") && !isServer())
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		manager.Remove(id);
	}
}
