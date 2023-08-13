shared u16 generateUniqueId()
{
	// 0 is reserved for uninitialized entities
	// Does not account for ID collisions when it wraps around
	// Surely by then, older entities will no longer exist

	u16 id = getRules().get_u16("_id");
	id = id == 65535 ? 1 : id + 1;
	getRules().set_u16("_id", id);
	return id;
}

shared bool saferead_player(CBitStream@ bs, CPlayer@ &out player)
{
	u16 id;
	if (!bs.saferead_netid(id)) return false;

	@player = getPlayerByNetworkId(id);
	return player !is null;
}
