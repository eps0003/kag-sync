#include "Networking.as"

NetworkManager@ manager;

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
			ToggleEntity@ toggle = ToggleEntity();
			Entity@ parent = ParentEntity(toggle);

			manager.Add(toggle);
			manager.Add(parent);
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
