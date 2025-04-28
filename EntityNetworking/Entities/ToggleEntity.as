shared class ToggleEntity : Entity
{
	private bool toggle = false;

	u16 getType()
	{
		return EntityType::Toggle;
	}

	CPlayer@ getOwner()
	{
		return null;
	}

	void Update()
	{

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
