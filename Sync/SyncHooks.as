#include "Sync.as"

CSync@ sync;

void onInit(CRules@ this)
{
	@sync = getSync();

	this.addCommandID("network create");
	this.addCommandID("network client sync");
	this.addCommandID("network server sync");
	this.addCommandID("network remove");
	this.addCommandID("network remove all");
}

void onTick(CRules@ this)
{
	sync._SyncTick();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	sync._SyncNewPlayer(player);
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

		sync._Add(object, id);
	}
	else if (cmd == this.getCommandID("network server sync") && !isServer())
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		Serializable@ object = sync.get(id);
		if (object is null) return;

		if (!object.deserialize(params))
		{
			error("Failed to deserialize object (id: " + id + ")");
		}
	}
	else if (cmd == this.getCommandID("network client sync") && !isClient())
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		Serializable@ object = sync.get(id);
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

		sync._Remove(id);
	}
	else if (cmd == this.getCommandID("network remove all") && !isServer())
	{
		sync._RemoveAll();
	}
}
