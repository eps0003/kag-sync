shared class TemplateEntity : Entity
{
	private u16 id = 0;

	TemplateEntity()
	{
		id = generateUniqueId();
	}

	TemplateEntity(u16 id)
	{
		this.id = id;
	}

	u16 getID()
	{
		return id;
	}

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
