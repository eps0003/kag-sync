shared interface Entity
{
	void Serialize(CBitStream@ bs);
	bool deserialize(CBitStream@ bs);

	u16 getType();
	CPlayer@ getOwner();

	void Update();
}
