shared interface Serializable
{
	u16 getType();

	void Serialize(CBitStream@ bs);
	bool deserialize(CBitStream@ bs);
}
