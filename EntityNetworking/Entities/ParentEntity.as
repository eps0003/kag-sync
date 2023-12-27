shared class ParentEntity : Entity
{
	private u16 id = 0;
	private u16 toggleId = 0;

	ParentEntity(ToggleEntity@ toggle)
	{
		id = generateUniqueId();
		toggleId = toggle.getID();
	}

	ParentEntity(u16 id)
	{
		this.id = id;
	}

	u16 getID()
	{
		return id;
	}

	u16 getType()
	{
		return EntityType::Parent;
	}

	CPlayer@ getOwner()
	{
		return null;
	}

	void Update()
	{
		if (isServer() && getGameTime() % getTicksASecond() == 0)
		{
			ToggleEntity@ toggle = cast<ToggleEntity>(Network::getManager().get(toggleId));
			if (toggle !is null)
			{
				toggle.Toggle();
			}
		}
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u16(toggleId);
	}

	bool deserialize(CBitStream@ bs)
	{
		return bs.saferead_u16(toggleId);
	}
}
