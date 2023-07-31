shared class Entity
{
    private u16 id = 0;
    private bool toggle = false;

    Entity()
    {
        id = getUniqueId();
        Network::getManager().Add(this);
    }

    ~Entity()
    {
        Network::getManager().Remove(id);
    }

	Entity(u16 id)
	{
		this.id = id;
        Network::getManager().Add(this);
	}

    u16 getID()
    {
        return id;
    }

    u16 getType()
    {
        return 0;
    }

    void Serialize(CBitStream@ bs)
    {

    }

    bool deserialize(CBitStream@ bs)
    {
        return true;
    }

    void Toggle()
    {
        toggle = !toggle;

        print("server: "+isServer()+"; toggle: "+toggle);

        if (isServer())
        {
            CRules@ rules = getRules();

            CBitStream bs;
            bs.write_u16(id);
            bs.write_bool(toggle);
            rules.SendCommand(rules.getCommandID("toggle"), bs, true);
        }

    }
}
