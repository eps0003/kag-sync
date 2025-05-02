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

		Serializable@ object = createObject(type);
		if (object is null)
		{
			error("Attempted to create object with an invalid type");
			return;
		}

		if (!object.deserialize(params))
		{
			error("Failed to deserialize object (id: " + id + ", type: " + type + ")");
			return;
		}

		manager._Add(object, id);
	}
	else if (cmd == this.getCommandID("network server sync") && !isServer())
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		Serializable@ object = manager.get(id);
		if (object is null) return;

		if (!object.deserialize(params))
		{
			error("Failed to deserialize object (id: " + id + ")");
		}
	}
	else if (cmd == this.getCommandID("network client sync") && isServer())
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		Serializable@ object = manager.get(id);
		if (object is null) return;

		if (!object.deserialize(params))
		{
			error("Failed to deserialize object (id: " + id + ")");
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
