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

	void Update()
	{
		if (player.isMyPlayer())
		{
			mousePos = getControls().getMouseScreenPos();
		}
		else if (player.getBlob().isKeyPressed(key_action1))
		{
			print(player.getUsername() + ": " + mousePos.toString());
		}
	}

	void Serialize(CBitStream@ bs)
	{
		if (isServer())
		{
			bs.write_u16(player.getNetworkID());
			bs.write_Vec2f(mousePos);
		}
		else if (player.isMyPlayer())
		{
			bs.write_Vec2f(mousePos);
		}
	}

	bool deserialize(CBitStream@ bs)
	{
		if (isServer())
		{
			if (player !is getNet().getActiveCommandPlayer()) return false;

			if (!bs.saferead_Vec2f(mousePos)) return false;
		}
		else
		{
			if (!saferead_player(bs, @player)) return false;

			if (player.isMyPlayer()) return true;

			if (!bs.saferead_Vec2f(mousePos)) return false;
		}

		return true;
	}
}
