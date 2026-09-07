# CCD Black Market

CCD Black Market is a buy-only black market resource for FiveM. It uses CCD-Library for framework, inventory, targeting, item validation, money handling, and inventory notifications.

## Features

- Clean NUI black market storefront
- Buy-only catalogue
- Item categories and search
- Configurable item prices, purchase amounts, currency, descriptions, icons, and stock
- Stock is shared server-side and resets to the configured amount when the resource restarts
- Multiple configurable dealer locations
- Configurable dealer ped model, scenario, heading, and interaction distance
- Third-eye interaction through `qb-target`, `ox_target`, or the CCD-Library target bridge
- Automatic inventory item image detection
- Fallback icons when an inventory image cannot be found
- Checks whether an item exists before allowing a purchase
- Uses CCD-Library bridges instead of hard-coded framework and inventory calls
- QB inventory item-added notification support through CCD-Library
- Server-side validation for item, price, stock, money, and inventory space

## Dependencies

Required resources:

1. `CCD-Library`

`CCD-Library` is required because it provides the framework, inventory, target, item-existence, item-image, and notification bridges used by this script.

## Installation

1. Place `CCD-Library` and `CCD_BlackMarket` inside your server resources folder. They can be placed in the same `[codecraft]` category folder.
2. Make sure you ensure both scripts, CCD-Library HAS to be ensure before any of our other script(s)
3. Make sure the required framework, inventory, target, `oxmysql`, and `ox_lib` resources are installed and started.
4. Configure `CCD-Library/config.lua` for your server:

```lua
Config.CoreObj = 'qbcore'
Config.Inventory = 'qb-inventory'
Config.Target = 'qb-target'
Config.Debug = false
```

4. Edit `CCD_BlackMarket/config.lua` to configure the dealers, UI, and catalogue.
5. Add the resources to `server.cfg` in dependency order for example:

```cfg
ensure oxmysql
ensure ox_lib
ensure qb-core
ensure qb-inventory
ensure qb-target
ensure CCD-Library
ensure CCD_BlackMarket
```

Use the resource names that match your server. For example, replace `qb-core`, `qb-inventory`, or `qb-target` if you use another supported resource.

## Configuration

### Dealer locations and ped

Edit `Config.Ped` to change the dealer model and behavior. Add or remove `vector4` entries in `Config.Locations` to control where dealers spawn.

```lua
Config.Ped = {
    model = 'g_m_m_chigoon_01',
    scenario = 'WORLD_HUMAN_AA_SMOKE',
    frozen = true,
    invincible = true,
    blockEvents = true,
}

Config.Locations = {
    vector4(1240.72, -3178.54, 7.10, 91.73),
}
```

### Interaction

```lua
Config.Interaction = {
    label = 'Browse Black Market',
    icon = 'fa-solid fa-mask',
    distance = 2.0,
}
```

### Adding items

Add items to `Config.Items`. The `item` value must match the item name used by your inventory.

```lua
{
    item = 'advancedlockpick',
    label = 'Advanced Lockpick',
    category = 'Tools',
    description = 'A higher quality lockpick.',
    price = 750,
    currency = 'cash',
    amount = 1,
    stock = 8,
    icon = 'fa-solid fa-screwdriver-wrench',
},
```

Every item added to `Config.Items` is checked automatically when the market opens. If the item exists in the active inventory and its image is available, the UI automatically loads the inventory image. No image URL needs to be added to the black market item entry.

If no image is found, the configured Font Awesome icon is used instead. Item names with spaces are also checked using their original, underscored, and dashed forms.

### Inventory image paths

CCD-Library currently checks common image locations for QB, OX, PS, LJ, QS, Core, Codem, and Tgiann inventories. Custom inventory locations can be added in `CCD-Library/config.lua` under `Config.InventoryImagePaths`:

```lua
Config.InventoryImagePaths['my-inventory'] = {
    'html/images/%s.png',
    'html/images/%s.webp',
}
```

The inventory resource must be started, and the image filename must match the inventory item name.

## Stock behavior

`stock` controls how many units of an item can be purchased before it becomes unavailable. Stock is kept in memory on the server and resets to the configured value whenever `CCD_BlackMarket` restarts.

For example:

```lua
stock = 25,
```

allows 25 purchases of that catalogue entry, based on its configured `amount`. The server validates stock and purchase details, so changing UI data does not bypass the limits.

## Framework and inventory support

The black market does not call normal QBCore functions directly. It uses CCD-Library so the script can be adapted across supported framework and inventory combinations.

Configure the active integrations in `CCD-Library/config.lua`:

```lua
Config.CoreObj = 'qbcore'       -- qbcore, qbx_core, ESX, or auto
Config.Inventory = 'qb-inventory' -- ox_inventory, qb-inventory, ps-inventory, esx_inventory, or auto
Config.Target = 'qb-target'     -- qb-target, ox_target, or auto
```

The exact exports and item image folder layout must be supported by the selected bridge. Custom image paths can be added through `Config.InventoryImagePaths` as described above.

## Debugging

Keep debug output disabled for normal use:

```lua
-- CCD-Library/config.lua
Config.Debug = false

-- CCD_BlackMarket/config.lua
Config.Debug = false
```

Set either value to `true` temporarily when troubleshooting. Restart `CCD-Library` before `CCD_BlackMarket` after changing library configuration.

## Support

For support, updates, and development help, join the CodeCraft Developments Discord:

[Join the CodeCraft Developments Discord](https://discord.gg/SrYDjdWJXX)

