shared class NetworkManager
{
    private Entity@[] entities;
    private dictionary entityMap;

    void Add(Entity@ entity)
    {
		u16 id = entity.getID();

		if (exists(id))
		{
			error("Attempted to add an entity with an existing ID: " + id);
			return;
		}

		entities.push_back(entity);
		entityMap.set("" + id, @entity);

		print("Added entity: " + id);
    }

	void Remove(u16 id)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			if (entities[i].getID() == id)
			{
				entities.removeAt(i);
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
