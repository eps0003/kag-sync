shared class ToggleEntity : Entity
{
    private u16 id = 0;
    private bool toggle = false;

    ToggleEntity()
    {
        id = getUniqueId();
    }

	ToggleEntity(u16 id)
	{
		this.id = id;
	}

    u16 getID()
    {
        return id;
    }

    u16 getType()
    {
        return EntityType::Toggle;
    }

    CPlayer@ getOwner()
    {
        return null;
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
