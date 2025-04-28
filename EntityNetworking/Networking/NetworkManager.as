shared class NetworkManager
{
	private Entity@[] entities;
	private u16[] ids;
	private dictionary entityMap;

	u16 add(Entity@ entity)
	{
		u16 id = generateUniqueId();
		_Add(entity, id);
		return id;
	}

	void _Add(Entity@ entity, u16 id)
	{
		if (exists(id))
		{
			error("Attempted to add an entity with an existing ID: " + id);
			return;
		}

		entities.push_back(entity);
		ids.push_back(id);
		entityMap.set("" + id, @entity);

		print("Added entity: " + id);
	}

	void Remove(u16 id)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			if (ids[i] == id)
			{
				entities.removeAt(i);
				ids.removeAt(i);
				entityMap.delete("" + id);

				print("Removed entity: " + id);

				if (isServer())
				{
					CBitStream bs;
					bs.write_u16(id);
					getRules().SendCommand(getRules().getCommandID("remove"), bs, true);
				}

				return;
			}
		}

		error("Attempted to remove an entity that does not exist: " + id);
	}

	void RemoveAll()
	{
		entities.clear();
		ids.clear();
		entityMap.deleteAll();

		print("Removed all entities");
	}

	bool exists(u16 id)
	{
		return entityMap.exists("" + id);
	}

	Entity@ get(u16 id)
	{
		Entity@ entity;
		entityMap.get("" + id, @entity);
		return entity;
	}

	Entity@[] getAll()
	{
		return entities;
	}

	u16[] getIds()
	{
		return ids;
	}
}

namespace Network
{
	shared NetworkManager@ getManager()
	{
		NetworkManager@ manager;
		if (!getRules().get("network manager", @manager))
		{
			@manager = NetworkManager();
			getRules().set("network manager", @manager);
		}
		return manager;
	}
}
