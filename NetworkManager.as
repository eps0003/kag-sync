shared class NetworkManager
{
    private Entity@[] entities;

    void Add(Entity@ entity)
    {
		if (exists(entity.getID()))
		{
			error("Attempted to add an entity with an existing ID");
			return;
		}

		entities.push_back(entity);
		print("Added entity: " + entity.getID());
    }

	void Remove(u16 id)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			if (entities[i].getID() == id)
			{
				entities.removeAt(i);
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

		error("Attempted to remove an entity that doesn't exist");
	}

	void RemoveAll()
	{
		entities.clear();
		print("Removed all entities");
	}

	bool exists(u16 id)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			if (entities[i].getID() == id)
			{
				return true;
			}
		}

		return false;
	}

	Entity@ get(u16 id)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			if (entities[i].getID() == id)
			{
				return entities[i];
			}
		}

		return null;
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
