shared class TemplateEntity : Entity
{
	u16 getType()
	{
		return 0;
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

	}

	bool deserialize(CBitStream@ bs)
	{
		return true;
	}
}
