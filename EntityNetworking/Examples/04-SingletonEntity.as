#include "Networking.as"

const u16 ENTITY_ID = 1;

void AddSingletons()
{
	Network::getManager().add(ToggleEntity());
}

ToggleEntity@ getEntity()
{
	return cast<ToggleEntity>(Network::getManager().get(ENTITY_ID));
}

void onInit(CRules@ this)
{
	if (isServer())
	{
		AddSingletons();
	}
}

void onTick(CRules@ this)
{
	if (isServer() && getGameTime() % getTicksASecond() == 0)
	{
		getEntity().Toggle();
	}
}

void onRender(CRules@ this)
{
	ToggleEntity@ entity = getEntity();
	if (entity !is null)
	{
		GUI::DrawText("Toggled: " + entity.getToggled(), Vec2f(10, 10), color_white);
	}
}
