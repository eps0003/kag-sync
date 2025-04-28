#include "Entity.as"
#include "NetworkManager.as"
#include "Utilities.as"

#include "ToggleEntity.as"
#include "PlayerEntity.as"
#include "ParentEntity.as"

shared Entity@ createEntity(u16 type)
{
	switch (type)
	{
	case EntityType::Toggle:
		return ToggleEntity();
	case EntityType::Player:
		return PlayerEntity();
	case EntityType::Parent:
		return ParentEntity();
	}
	return null;
}

shared enum EntityType
{
	Toggle,
	Player,
	Parent
}
