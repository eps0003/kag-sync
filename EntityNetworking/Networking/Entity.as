shared interface Serializable
{
	void Serialize(CBitStream@ bs);
	bool deserialize(CBitStream@ bs);
}

shared interface Entity : Serializable
{
	u16 getID();
	u16 getType();
	CPlayer@ getOwner();

	void Update();
}
