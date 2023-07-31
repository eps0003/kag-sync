#include "Entity.as"
#include "NetworkManager.as"

#define SERVER_ONLY;

Entity@ entity;
NetworkManager@ manager;

shared u16 getUniqueId()
{
	return getRules().add_u16("_id", 1);
}

void onInit(CRules@ this)
{
    onRestart(this);
}

void onRestart(CRules@ this)
{
    @entity = Entity();
    @manager = Network::getManager();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{

}

void onTick(CRules@ this)
{
    if (getGameTime() % getTicksASecond() == 0)
    {
        entity.Toggle();
    }

    Entity@[] entities = manager.getAll();

    for (uint i = 0; i < entities.size(); i++)
    {
        Entity@ entity = entities[i];

        CBitStream bs;
        bs.write_u16(entity.getID());
        entity.Serialize(bs);

        this.SendCommand(this.getCommandID("sync"), bs, true);
    }
}
