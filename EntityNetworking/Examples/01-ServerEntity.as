#include "Networking.as"

NetworkManager@ manager;

ToggleEntity@ entity;
u16 entityId = 0;

void onInit(CRules@ this)
{
	this.addCommandID("entity_id");

	@manager = Network::getManager();

	if (isServer())
	{
		@entity = ToggleEntity();
		entityId = manager.add(entity);
	}
}

void onTick(CRules@ this)
{
	if (isServer() && getGameTime() % getTicksASecond() == 0)
	{
		entity.Toggle();
	}
}

void onRender(CRules@ this)
{
	if (entity !is null)
	{
		GUI::DrawText("Toggled: " + entity.getToggled(), Vec2f(10, 10), color_white);
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
		if (!params.saferead_u16(entityId)) return;

		@entity = cast<ToggleEntity>(manager.get(entityId));
	}
}
