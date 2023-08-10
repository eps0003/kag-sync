shared interface Entity
{
    u16 getID();
    u16 getType();

    void Serialize(CBitStream@ bs);
    bool deserialize(CBitStream@ bs);
}

shared u16 getUniqueId()
{
	return getRules().add_u16("_id", 1);
}
