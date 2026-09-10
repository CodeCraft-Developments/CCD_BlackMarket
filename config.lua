Config = Config or {}

-- Framework, inventory, and targeting are handled by CCD-Library.
Config.Debug = false -- set to true to enable CCD_BlackMarket client debug output

Config.UI = {
    title = 'BLACK MARKET',
    subtitle = 'Private supply channel // inventory refreshes on restart',
    currencySymbol = '$',
}

Config.Interaction = {
    label = 'Browse Black Market',
    icon = 'fa-solid fa-mask',
    distance = 2.0,
}

Config.Ped = {
    model = 'g_m_m_chigoon_01',
    scenario = 'WORLD_HUMAN_AA_SMOKE',
    frozen = true,
    invincible = true,
    blockEvents = true,
}

-- Four dealer locations. Change the model above or add/remove locations as needed.
Config.Locations = {
    vector4(-3047.31, 585.42, 7.91, 199.84),
    vector4(1240.72, -3178.54, 7.10, 91.73),
    vector4(-1171.42, -1572.08, 4.66, 214.58),
    vector4(1703.84, 4920.71, 42.06, 323.11),
}

-- Buy-only catalogue. The server validates every item and price from this table.
Config.Items = {
    {
        item = 'lockpick',
        label = 'Lockpick',
        category = 'Tools',
        description = 'Useful for opening secured locks.',
        price = 250,
        currency = 'cash',
        amount = 1,
        stock = 15,
        icon = 'fa-solid fa-key',
    },
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
    {
        item = 'plastic bag',
        label = 'Plastic Bag',
        category = 'Supplies',
        description = 'A discreet plain plastic bag.',
        price = 100,
        currency = 'cash',
        amount = 1,
        stock = 25,
        icon = 'fa-solid fa-bag-shopping',
    },
}
