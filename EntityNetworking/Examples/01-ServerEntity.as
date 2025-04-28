#include "Networking.as"

NetworkManager@ manager;
u16 entityId = 0;

void onInit(CRules@ this)
{
	this.addCommandID("entity_id");

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
			ToggleEntity@ entity = ToggleEntity();
			entityId = manager.add(entity);
		}

		if (getGameTime() % getTicksASecond() == 0)
		{
			ToggleEntity@ entity = cast<ToggleEntity>(manager.get(entityId));
			if (entity !is null)
			{
				entity.Toggle();
			}
		}
	}

	if (isClient())
	{
		ToggleEntity@ entity = cast<ToggleEntity>(manager.get(entityId));
		if (entity !is null)
		{
			print(""+entity.getToggled());
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (isServer())
	{
		CBitStream bs;
		bs.write_u16(entityId);
		this.SendCommand(this.getCommandID("entity_id"), bs, player);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("entity_id") && !isServer())
	{
		params.saferead_u16(entityId);
	}
}
