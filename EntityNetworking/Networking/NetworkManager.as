shared class NetworkManager
{
	private u16 uniqueId = 0;
	private Serializable@[] objects;
	private u16[] ids;
	private dictionary objectMap;
	private dictionary bsMap;

	private u16 generateUniqueId()
	{
		// u16 maximum value
		u16 maxId = 65535;

		// Prevent infinite loop by identifying when all possible IDs are in use
		if (objects.size() >= maxId)
		{
			error("Exhausted all possible object IDs! Have you forgotten to remove objects when they no longer need to be synced?");
			return 0;
		}

		do
		{
			// 0 is reserved for uninitialized objects
			uniqueId = uniqueId == maxId ? 1 : uniqueId + 1;
		}
		while (exists(uniqueId));

		return uniqueId;
	}

	// Add an object on the server
	u16 add(Serializable@ object)
	{
		if (!isServer())
		{
			error("Attempted to add an object with a generated ID on the client");
			printTrace();
			return 0;
		}

		if (exists(object))
		{
			error("Attempted to add the same object multiple times");
			printTrace();
			return 0;
		}

		u16 id = generateUniqueId();

		if (id == 0)
		{
			error("Attempted to add an object with an ID of 0");
			printTrace();
			return 0;
		}

		if (exists(id))
		{
			error("Attempted to add an object with an existing ID");
			printTrace();
			return 0;
		}

		objects.push_back(object);
		ids.push_back(id);
		objectMap.set("" + id, @object);

		print("Added object (id: " + id + ", type: " + object.getType() + ")");

		CBitStream objectBs;
		object.Serialize(objectBs);
		bsMap.set("" + id, objectBs);

		if (getPlayerCount() > 0)
		{
			CBitStream bs;
			bs.write_u16(object.getType());
			bs.write_u16(id);
			bs.writeBitStream(objectBs);

			getRules().SendCommand(getRules().getCommandID("network create"), bs, true);
		}

		return id;
	}

	// Add an object on the client
	void _Add(Serializable@ object, u16 id)
	{
		if (isServer())
		{
			error("Attempted to add an object on the server using a client-specific method");
			printTrace();
			return;
		}

		if (id == 0)
		{
			error("Attempted to add an object with an ID of 0");
			printTrace();
			return;
		}

		if (exists(id))
		{
			error("Attempted to add an object with an existing ID");
			printTrace();
			return;
		}

		if (exists(object))
		{
			error("Attempted to add the same object multiple times");
			printTrace();
			return;
		}

		objects.push_back(object);
		ids.push_back(id);
		objectMap.set("" + id, @object);

		print("Added object (id: " + id + ", type: " + object.getType() + ")");
	}

	// Remove an object on the server
	void Remove(Serializable@ object)
	{
		if (!isServer())
		{
			error("Attempted to remove an object on the client");
			printTrace();
			return;
		}

		for (uint i = 0; i < objects.size(); i++)
		{
			if (objects[i] is object)
			{
				u16 id = ids[i];
				u16 type = objects[i].getType();

				objects.removeAt(i);
				ids.removeAt(i);
				objectMap.delete("" + id);
				bsMap.delete("" + id);

				print("Removed object (id: " + id + ", type: " + type + ")");

				if (getPlayerCount() > 0)
				{
					CBitStream bs;
					bs.write_u16(id);
					getRules().SendCommand(getRules().getCommandID("network remove"), bs, true);
				}

				return;
			}
		}

		error("Attempted to remove an unregistered object");
		printTrace();
	}

	// Remove an object on the server
	void Remove(u16 id)
	{
		if (!isServer())
		{
			error("Attempted to remove an object on the client");
			printTrace();
			return;
		}

		for (uint i = 0; i < objects.size(); i++)
		{
			if (ids[i] == id)
			{
				u16 type = objects[i].getType();

				objects.removeAt(i);
				ids.removeAt(i);
				objectMap.delete("" + id);
				bsMap.delete("" + id);

				print("Removed object (id: " + id + ", type: " + type + ")");

				if (getPlayerCount() > 0)
				{
					CBitStream bs;
					bs.write_u16(id);
					getRules().SendCommand(getRules().getCommandID("network remove"), bs, true);
				}

				return;
			}
		}

		error("Attempted to remove an object with an unknown ID");
		printTrace();
	}

	// Remove a object on the client
	void _Remove(u16 id)
	{
		if (isServer())
		{
			error("Attempted to remove an object on the server using a client-specific method");
			printTrace();
			return;
		}

		for (uint i = 0; i < objects.size(); i++)
		{
			if (ids[i] == id)
			{
				u16 type = objects[i].getType();

				objects.removeAt(i);
				ids.removeAt(i);
				objectMap.delete("" + id);
				bsMap.delete("" + id);

				print("Removed object (id: " + id + ", type: " + type + ")");

				return;
			}
		}

		error("Attempted to remove an object with an unknown ID");
		printTrace();
	}

	// Remove all objects on the server
	void RemoveAll()
	{
		if (!isServer())
		{
			error("Attempted to remove all objects on the client");
			printTrace();
			return;
		}

		if (objects.empty()) return;

		objects.clear();
		ids.clear();
		objectMap.deleteAll();
		bsMap.deleteAll();

		print("Removed all objects");

		if (getPlayerCount() > 0)
		{
			CBitStream bs;
			getRules().SendCommand(getRules().getCommandID("network remove all"), bs, true);
		}
	}

	// Remove all objects on the client
	void _RemoveAll()
	{
		if (isServer())
		{
			error("Attempted to remove all objects on the server using a client-specific method");
			printTrace();
			return;
		}

		if (objects.empty()) return;

		objects.clear();
		ids.clear();
		objectMap.deleteAll();
		bsMap.deleteAll();

		print("Removed all objects");
	}

	bool exists(u16 id)
	{
		return objectMap.exists("" + id);
	}

	bool exists(Serializable@ object)
	{
		for (uint i = 0; i < objects.size(); i++)
		{
			if (objects[i] is object)
			{
				return true;
			}
		}

		return false;
	}

	Serializable@ get(u16 id)
	{
		Serializable@ object;
		objectMap.get("" + id, @object);
		return object;
	}

	void _SyncTick()
	{
		for (uint i = 0; i < objects.size(); i++)
		{
			Serializable@ object = objects[i];
			u16 id = ids[i];

			CBitStream objectBs;
			object.Serialize(objectBs);

			if (objectBs.getBitsUsed() == 0)
			{
				continue;
			}

			CBitStream@ lastObjectBs;

			if (bsMap.get("" + id, @lastObjectBs) && isSameBitStream(objectBs, lastObjectBs))
			{
				continue;
			}

			CBitStream bs;
			bs.write_u16(id);
			bs.writeBitStream(objectBs);

			bsMap.set("" + id, objectBs);

			if (isServer())
			{
				if (getPlayerCount() > 0)
				{
					getRules().SendCommand(getRules().getCommandID("network server sync"), bs, true);
				}
			}
			else
			{
				getRules().SendCommand(getRules().getCommandID("network client sync"), bs, false);
			}
		}
	}

	void _SyncNewPlayer(CPlayer@ player)
	{
		for (uint i = 0; i < objects.size(); i++)
		{
			Serializable@ object = objects[i];
			u16 id = ids[i];

			CBitStream objectBs;
			object.Serialize(objectBs);

			CBitStream bs;
			bs.write_u16(object.getType());
			bs.write_u16(id);
			bs.writeBitStream(objectBs);

			getRules().SendCommand(getRules().getCommandID("network create"), bs, player);
		}
	}

	private bool isSameBitStream(CBitStream a, CBitStream b)
	{
		if (a.getBitsUsed() != b.getBitsUsed())
		{
			return false;
		}

		a.ResetBitIndex();
		b.ResetBitIndex();

		for (uint i = 0; i < a.getBitsUsed(); i++)
		{
			if (a.read_bool() != b.read_bool())
			{
				return false;
			}
		}

		return true;
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
