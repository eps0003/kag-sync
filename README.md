# Sync

A [King Arthur's Gold](https://kag2d.com/) mod for the bidirectional syncing of object state. This is intended for use in [total conversion](https://en.wikipedia.org/wiki/Video_game_modding#Total_conversion) mods.

## Overview

Classes implement the `Serializable` interface and are added to Sync. Sync then automatically manages the syncing of objects between server and client (and vice versa for state that a player should control). The modder only needs to be concerned with addition and removal of objects as well as the serialization and deserialization of object state.

## Features

- New paradigm for keeping data in sync between the server and clients, at least in the context of KAG modding.
- Sends data over the network only when state changes rather than every tick.
- Adds only 16 bits of overhead (the object ID) when syncing the state of each object.
- Intelligently generates a unique ID for added objects by skipping over IDs that are in use.

## Usage

### 1. Add Sync to you Mods folder and `mods.cfg`

In `mods.cfg`, list `Sync` before your mod:

```cfg
# mods.cfg

Sync
YourModHere
```

### 2. Add `SyncHooks.as` to scripts in rules .cfg file

List `SyncHooks.as` first, or at least before any script that deals with object syncing or synced objects:

```cfg
scripts =
    SyncHooks.as;
    ScriptA.as;
    ScriptB.as;
```

### 3. Create `SerializableObjects.as`

It must contain the `shared Serializable@ createObject(u16 type)` function. The enum for object types is recommended but not required.

```angelscript
// SerializableObjects.as

#include "Foo.as"

shared enum ObjectType
{
    Foo,
}

// Used internally to instantiate synced objects on the client
shared Serializable@ createObject(u16 type)
{
    switch (type)
    {
    case ObjectType::Foo:
        // Use the default constructor
        return Foo();
    }
    return null;
}
```

### 4. Implement the `Serializable` interface

The interface defines three methods:

- `u16 getType()` - A unique identifier for the class. It is necessary for identifying which class needs to be instantiated when an object is initially synced to clients.
- `void Serialize(CBitStream@ bs)` - Serialize the state of the object. It is called on both the server and client.
- `bool deserialize(CBitStream@ bs)` - Deserialize the state of the object. It is called on both the server and client.

```angelscript
// Foo.as

#include "Sync.as"
#include "SerializableObjects.as"

// Use the `shared` keyword everywhere so casting objects works correctly
shared class Foo : Serializable
{
    string name;

    // This constructor is used when instantiating on the server
    Foo(string name)
    {
        this.name = name;
    }

    u16 getType()
    {
        // Return a value that is unique to this class
        return ObjectType::Foo;
    }

    // A command is sent if serialized data differs from last tick
    void Serialize(CBitStream@ bs)
    {
        // Serialize state on the server
        if (isServer())
        {
            bs.write_string(name);
        }
    }

    bool deserialize(CBitStream@ bs)
    {
        // Deserialize synced state on the client
        if (!isServer())
        {
            // Use saferead methods to avoid crashes, and return false on failure
            if (!bs.saferead_string(name)) return false;
        }

        return true;
    }
}
```

### 5. Add the object to be synced

This example also demonstrates one way clients can refer to the synced object.

```angelscript
// A script added to the rules .cfg file

#include "Foo.as"

void onInit(CRules@ this)
{
    // Synced objects must be instantiated and added on the server
    if (isServer())
    {
        // Instantiate the object
        Foo@ foo = Foo("Foo");

        // Add the object to be synced which returns an object ID
        u16 id = getSync().add(foo);

        // Sync the object ID to the client
        this.set_u16("foo_id", id);
        this.Sync("foo_id", true);
    }
}

void onRender(CRules@ this)
{
    // Get the object ID that we synced from the server
    u16 id = this.get_u16("foo_id");

    // 0 is a reserved ID which means no object
    if (id == 0) return;

    // Get the object that is being synced from the server
    Foo@ foo = cast<Foo>(getSync().get(id));

    // The client may not have received the object yet
    if (foo is null) return;

    // Draw the synced name at the top left of the screen
    GUI::DrawText(foo.name, Vec2f(10, 10), color_white);
}
```

### 6. Remove the object when it no longer needs to be synced

This frees up the object ID for use by another synced object in the future. If this isn't done, objects won't be garbage collected and will continue to consume memory, and the server could eventually exhaust all available IDs, causing major issues.

```angelscript
// Synced objects must be removed on the server
if (isServer())
{
    // Remove an object using the ID that was returned when adding it
    getSync().Remove(id);

    // Alternatively, remove the object using its handle
    getSync().Remove(foo);
}
```
