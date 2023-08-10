shared class ToggleEntity : Entity
{
    private u16 id = 0;
    private bool toggle = false;

    ToggleEntity()
    {
        id = getUniqueId();
        Network::getManager().Add(this);
    }

    ~ToggleEntity()
    {
        Network::getManager().Remove(id);
    }

	ToggleEntity(u16 id)
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
        bs.write_bool(toggle);
    }

    bool deserialize(CBitStream@ bs)
    {
        return bs.saferead_bool(toggle);
    }

    void Toggle()
    {
        toggle = !toggle;
    }

    bool getToggled()
    {
        return toggle;
    }
}
