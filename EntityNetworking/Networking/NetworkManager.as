shared class NetworkManager
{
	private u16 uniqueId = 0;
	private Entity@[] entities;
	private u16[] ids;
	private dictionary entityMap;
	private dictionary bsMap;

	private u16 generateUniqueId()
	{
		// u16 maximum value
		u16 maxId = 65535;

		// Prevent infinite loop by identifying when all possible IDs are in use
		if (entities.size() >= maxId)
		{
			error("Exhausted all possible entity IDs! Have you forgotten to remove entities when they no longer need to be synced?");
			return 0;
		}

		do
		{
			// 0 is reserved for uninitialized entities
			uniqueId = uniqueId == maxId ? 1 : uniqueId + 1;
		}
		while (exists(uniqueId));

		return uniqueId;
	}

	// Add an entity on the server
	u16 add(Entity@ entity)
	{
		if (!isServer())
		{
			error("Attempted to add an entity with a generated ID on the client");
			printTrace();
			return 0;
		}

		if (exists(entity))
		{
			error("Attempted to add the same entity multiple times");
			printTrace();
			return 0;
		}

		u16 id = generateUniqueId();

		if (id == 0)
		{
			error("Attempted to add an entity with an ID of 0");
			printTrace();
			return 0;
		}

		if (exists(id))
		{
			error("Attempted to add an entity with an existing ID");
			printTrace();
			return 0;
		}

		entities.push_back(entity);
		ids.push_back(id);
		entityMap.set("" + id, @entity);

		print("Added entity (id: " + id + ", type: " + entity.getType() + ")");

		if (getPlayerCount() > 0)
		{
			CBitStream bs;
			bs.write_u16(entity.getType());
			bs.write_u16(id);

			CBitStream entityBs;
			entity.Serialize(entityBs);

			bsMap.set("" + id, entityBs);
			bs.writeBitStream(entityBs);

			getRules().SendCommand(getRules().getCommandID("network create"), bs, true);
		}

		return id;
	}

	// Add an entity on the client
	void _Add(Entity@ entity, u16 id)
	{
		if (isServer())
		{
			error("Attempted to add an entity on the server using a client-specific method");
			printTrace();
			return;
		}

		if (id == 0)
		{
			error("Attempted to add an entity with an ID of 0");
			printTrace();
			return;
		}

		if (exists(id))
		{
			error("Attempted to add an entity with an existing ID");
			printTrace();
			return;
		}

		if (exists(entity))
		{
			error("Attempted to add the same entity multiple times");
			printTrace();
			return;
		}

		entities.push_back(entity);
		ids.push_back(id);
		entityMap.set("" + id, @entity);

		print("Added entity (id: " + id + ", type: " + entity.getType() + ")");
	}

	// Remove an entity on the server
	void Remove(Entity@ entity)
	{
		if (!isServer())
		{
			error("Attempted to remove an entity on the client");
			printTrace();
			return;
		}

		for (uint i = 0; i < entities.size(); i++)
		{
			if (entities[i] is entity)
			{
				u16 id = ids[i];
				u16 type = entities[i].getType();

				entities.removeAt(i);
				ids.removeAt(i);
				entityMap.delete("" + id);
				bsMap.delete("" + id);

				print("Removed entity (id: " + id + ", type: " + type + ")");

				if (getPlayerCount() > 0)
				{
					CBitStream bs;
					bs.write_u16(id);
					getRules().SendCommand(getRules().getCommandID("network remove"), bs, true);
				}

				return;
			}
		}

		error("Attempted to remove an unregistered entity");
		printTrace();
	}

	// Remove an entity on the server
	void Remove(u16 id)
	{
		if (!isServer())
		{
			error("Attempted to remove an entity on the client");
			printTrace();
			return;
		}

		for (uint i = 0; i < entities.size(); i++)
		{
			if (ids[i] == id)
			{
				u16 type = entities[i].getType();

				entities.removeAt(i);
				ids.removeAt(i);
				entityMap.delete("" + id);
				bsMap.delete("" + id);

				print("Removed entity (id: " + id + ", type: " + type + ")");

				if (getPlayerCount() > 0)
				{
					CBitStream bs;
					bs.write_u16(id);
					getRules().SendCommand(getRules().getCommandID("network remove"), bs, true);
				}

				return;
			}
		}

		error("Attempted to remove an entity with an unknown ID");
		printTrace();
	}

	// Remove a entity on the client
	void _Remove(u16 id)
	{
		if (isServer())
		{
			error("Attempted to remove an entity on the server using a client-specific method");
			printTrace();
			return;
		}

		for (uint i = 0; i < entities.size(); i++)
		{
			if (ids[i] == id)
			{
				u16 type = entities[i].getType();

				entities.removeAt(i);
				ids.removeAt(i);
				entityMap.delete("" + id);
				bsMap.delete("" + id);

				print("Removed entity (id: " + id + ", type: " + type + ")");

				return;
			}
		}

		error("Attempted to remove an entity with an unknown ID");
		printTrace();
	}

	// Remove all entities on the server
	void RemoveAll()
	{
		if (!isServer())
		{
			error("Attempted to remove all entities on the client");
			printTrace();
			return;
		}

		if (entities.empty()) return;

		entities.clear();
		ids.clear();
		entityMap.deleteAll();
		bsMap.deleteAll();

		print("Removed all entities");

		if (getPlayerCount() > 0)
		{
			CBitStream bs;
			getRules().SendCommand(getRules().getCommandID("network remove all"), bs, true);
		}
	}

	// Remove all entities on the client
	void _RemoveAll()
	{
		if (isServer())
		{
			error("Attempted to remove all entities on the server using a client-specific method");
			printTrace();
			return;
		}

		if (entities.empty()) return;

		entities.clear();
		ids.clear();
		entityMap.deleteAll();
		bsMap.deleteAll();

		print("Removed all entities");
	}

	bool exists(u16 id)
	{
		return entityMap.exists("" + id);
	}

	bool exists(Entity@ entity)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			if (entities[i] is entity)
			{
				return true;
			}
		}

		return false;
	}

	Entity@ get(u16 id)
	{
		Entity@ entity;
		entityMap.get("" + id, @entity);
		return entity;
	}

	void _SyncTick()
	{
		if (getPlayerCount() == 0) return;

		for (uint i = 0; i < entities.size(); i++)
		{
			Entity@ entity = entities[i];
			u16 id = ids[i];

			entity.Update();

			CBitStream entityBs;
			entity.Serialize(entityBs);

			if (entityBs.getBitsUsed() == 0)
			{
				continue;
			}

			CBitStream@ lastEntityBs;

			if (bsMap.get("" + id, @lastEntityBs) && isSameBitStream(entityBs, lastEntityBs))
			{
				continue;
			}

			CBitStream bs;
			bs.write_u16(id);
			bs.writeBitStream(entityBs);

			bsMap.set("" + id, entityBs);

			if (isServer())
			{
				getRules().SendCommand(getRules().getCommandID("network server sync"), bs, true);
			}
			else
			{
				getRules().SendCommand(getRules().getCommandID("network client sync"), bs, false);
			}
		}
	}

	void _SyncNewPlayer(CPlayer@ player)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			Entity@ entity = entities[i];
			u16 id = ids[i];

			CBitStream entityBs;
			entity.Serialize(entityBs);

			if (entityBs.getBitsUsed() == 0)
			{
				continue;
			}

			CBitStream bs;
			bs.write_u16(entity.getType());
			bs.write_u16(id);
			bs.writeBitStream(entityBs);

			getRules().SendCommand(getRules().getCommandID("network create"), bs, player);
		}
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
