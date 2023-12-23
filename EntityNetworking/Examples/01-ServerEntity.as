#include "Networking.as"

NetworkManager@ manager;
ToggleEntity@ entity;

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
            @entity = ToggleEntity();
            manager.Add(entity);
        }

        if (getGameTime() % getTicksASecond() == 0)
        {
            entity.Toggle();
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
