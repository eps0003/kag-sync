#include "Entity.as"
#include "NetworkManager.as"
#include "Utilities.as"

#include "ToggleEntity.as"
#include "PlayerEntity.as"

shared Entity@ createEntity(u16 type, u16 id)
{
	switch (type)
	{
	case EntityType::Toggle:
		return ToggleEntity(id);
	case EntityType::Player:
		return PlayerEntity(id);
	}
	return null;
}

shared enum EntityType
{
	Toggle,
	Player
}
