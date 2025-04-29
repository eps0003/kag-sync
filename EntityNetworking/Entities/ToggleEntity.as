shared class ToggleEntity : Entity
{
	private bool toggle = false;

	u16 getType()
	{
		return EntityType::Toggle;
	}

	void Update()
	{

	}

	void Serialize(CBitStream@ bs)
	{
		if (isServer())
		{
			bs.write_bool(toggle);
		}
	}

	bool deserialize(CBitStream@ bs)
	{
		if (!isServer())
		{
			return bs.saferead_bool(toggle);
		}

		return false;
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
