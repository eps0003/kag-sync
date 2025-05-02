#include "Networking.as"

NetworkManager@ manager;

void onInit(CRules@ this)
{
	this.addCommandID("network create");
	this.addCommandID("network client sync");
	this.addCommandID("network server sync");
	this.addCommandID("network remove");
	this.addCommandID("network remove all");

	@manager = Network::getManager();
}

void onTick(CRules@ this)
{
	manager._SyncTick();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	manager._SyncNewPlayer(player);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("network create") && !isServer())
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
			error("Failed to deserialize entity (id: " + id + ", type: " + type + ")");
			return;
		}

		manager._Add(entity, id);
	}
	else if (cmd == this.getCommandID("network server sync") && !isServer())
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		Entity@ entity = manager.get(id);
		if (entity is null) return;

		if (!entity.deserialize(params))
		{
			error("Failed to deserialize entity (id: " + id + ")");
		}
	}
	else if (cmd == this.getCommandID("network client sync") && isServer())
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		Entity@ entity = manager.get(id);
		if (entity is null) return;

		if (!entity.deserialize(params))
		{
			error("Failed to deserialize entity (id: " + id + ")");
		}
	}
	else if (cmd == this.getCommandID("network remove") && !isServer())
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		manager._Remove(id);
	}
	else if (cmd == this.getCommandID("network remove all") && !isServer())
	{
		manager._RemoveAll();
	}
}
