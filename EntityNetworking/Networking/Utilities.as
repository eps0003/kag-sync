shared bool saferead_player(CBitStream@ bs, CPlayer@ &out player)
{
	u16 id;
	if (!bs.saferead_netid(id)) return false;

	@player = getPlayerByNetworkId(id);
	return player !is null || id == 0;
}

shared bool isSameBitStream(CBitStream a, CBitStream b)
{
	if (a.getBitsUsed() != b.getBitsUsed())
	{
		return false;
	}

	a.ResetBitIndex();
	b.ResetBitIndex();

	while (!a.isBufferEnd())
	{
		if (a.read_bool() != b.read_bool())
		{
			return false;
		}
	}

	return true;
}
