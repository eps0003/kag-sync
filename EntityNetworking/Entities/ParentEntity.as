shared class ParentEntity : Entity
{
	private u16 toggleId = 0;

	ParentEntity(u16 toggleId)
	{
		this.toggleId = toggleId;
	}

	u16 getType()
	{
		return EntityType::Parent;
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
		if (isServer())
		{
			bs.write_u16(toggleId);
		}
	}

	bool deserialize(CBitStream@ bs)
	{
		if (!isServer())
		{
			return bs.saferead_u16(toggleId);
		}

		return false;
	}
}
