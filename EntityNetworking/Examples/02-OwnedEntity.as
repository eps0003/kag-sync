#include "Networking.as"

NetworkManager@ manager;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@manager = Network::getManager();

	if (isServer())
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player is null) continue;

			manager.Add(PlayerEntity(player));
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (isServer())
	{
		manager.Add(PlayerEntity(player));
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	if (isServer())
	{
		manager.Remove(player.get_u16("entity_id"));
	}
}
