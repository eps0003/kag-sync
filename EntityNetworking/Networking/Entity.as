shared interface Entity
{
	u16 getType();

	void Serialize(CBitStream@ bs);
	bool deserialize(CBitStream@ bs);

	void Update();
}
