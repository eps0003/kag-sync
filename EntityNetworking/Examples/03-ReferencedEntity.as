#include "Networking.as"

NetworkManager@ manager;
u16 toggleId = 0;

void onInit(CRules@ this)
{
	this.addCommandID("toggle_id");

	@manager = Network::getManager();

	if (isServer())
	{
		ToggleEntity@ toggle = ToggleEntity();
		toggleId = manager.add(toggle);

		Entity@ parent = ParentEntity(toggleId);
		manager.add(parent);

		CBitStream bs;
		bs.write_u16(toggleId);
		this.SendCommand(this.getCommandID("toggle_id"), bs, true);
	}
}

void onTick(CRules@ this)
{
	if (isClient())
	{
		ToggleEntity@ toggle = cast<ToggleEntity>(manager.get(toggleId));
		if (toggle !is null)
		{
			print(""+toggle.getToggled());
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (isServer())
	{
		CBitStream bs;
		bs.write_u16(toggleId);
		this.SendCommand(this.getCommandID("toggle_id"), bs, player);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("toggle_id") && !isServer())
	{
		params.saferead_u16(toggleId);
	}
}
