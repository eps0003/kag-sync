#include "Networking.as"

NetworkManager@ manager;

void onInit(CRules@ this)
{
	@manager = Network::getManager();

	if (isServer())
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player is null) continue;

			AddPlayerEntity(player);
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (isServer())
	{
		AddPlayerEntity(player);
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	if (isServer())
	{
		RemovePlayerEntity(player);
	}
}

void AddPlayerEntity(CPlayer@ player)
{
	u16 entityId = manager.add(PlayerEntity(player));

	player.set_u16("entity_id", entityId);
}

void RemovePlayerEntity(CPlayer@ player)
{
	u16 entityId = player.get_u16("entity_id");

	player.set_u16("entity_id", 0);
	manager.Remove(entityId);
}
