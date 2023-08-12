shared interface Entity
{
    u16 getID();
    u16 getType();
    CPlayer@ getOwner();

    void Serialize(CBitStream@ bs);
    bool deserialize(CBitStream@ bs);
}
