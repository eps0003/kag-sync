shared class PlayerEntity : Entity
{
	private CPlayer@ player;
	private Vec2f mousePos = Vec2f_zero;

	PlayerEntity(CPlayer@ player)
	{
		@this.player = player;
	}

	u16 getType()
	{
		return EntityType::Player;
	}

	CPlayer@ getOwner()
	{
		return player;
	}

	void Update()
	{

	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u16(player !is null ? player.getNetworkID() : 0);

		Vec2f mousePos = isServer() ? this.mousePos : getControls().getMouseScreenPos();
		bs.write_Vec2f(mousePos);
	}

	bool deserialize(CBitStream@ bs)
	{
		if (!saferead_player(bs, @player)) return false;

		if (!player.isMyPlayer())
		{
			if (!bs.saferead_Vec2f(mousePos)) return false;

			print(player.getUsername() + ": " + mousePos.toString());
		}

		return true;
	}
}
