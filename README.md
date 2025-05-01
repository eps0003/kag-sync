# Entity Networking

A [King Arthur's Gold](https://kag2d.com/) mod that demonstrates an entity networking system. This is most useful in [total conversion](https://en.wikipedia.org/wiki/Video_game_modding#Total_conversion) mods.

## Examples

Example scripts are located in the `Examples` directory. Update `Default/Rules.cfg` to enable/disable each example script. Only one example script should be active at once.

### `01-ServerEntity.as`

Demonstrates a server-controlled entity that is synced to the client.

### `02-OwnedEntity.as`

Demonstrates entities owned by each player that sync mouse position to the server and other clients.

### `03-ReferencedEntity.as`

Demonstrates how entities should be referenced by their ID.

### `04-SingletonEntity.as`

Demonstrates instantiating specific entities first so their IDs are known by both the server and clients without needing to sync it.
