local codecraft_lib = exports['CCD-Library']:import()
local stock = {}

local function resetStock()
    stock = {}
    for index, item in ipairs(Config.Items) do
        stock[index] = math.max(0, math.floor(tonumber(item.stock) or 0))
    end
end

resetStock()

local function sendResult(src, success, message)
    codecraft_lib.Notify(src, message, success and 'success' or 'error', 5000)
    TriggerClientEvent('CCD_BlackMarket:client:purchaseResult', src, success, message, stock)
end

RegisterNetEvent('CCD_BlackMarket:server:requestStock', function()
    TriggerClientEvent('CCD_BlackMarket:client:setStock', source, stock)
end)

RegisterNetEvent('CCD_BlackMarket:server:requestOpen', function()
    local products = {}
    for index, item in ipairs(Config.Items or {}) do
        products[index] = {
            item = item.item,
            label = item.label,
            category = item.category,
            description = item.description,
            price = item.price,
            currency = item.currency,
            amount = item.amount,
            stock = item.stock,
            icon = item.icon,
            image = codecraft_lib.GetItemImage(item.item),
        }
    end
    TriggerClientEvent('CCD_BlackMarket:client:open', source, products)
end)

local function findItem(itemIndex)
    local index = tonumber(itemIndex)
    if not index then return nil end
    return Config.Items[index]
end

RegisterNetEvent('CCD_BlackMarket:server:buyItem', function(itemIndex)
    local source = source
    local index = tonumber(itemIndex)
    local item = findItem(index)
    if not item or not item.item or not item.price or item.price < 0 then
        return
    end

    if not codecraft_lib.DoesItemExist(item.item) then
        sendResult(source, false, ('%s is not available on this server.'):format(item.label or item.item))
        return
    end

    local amount = math.max(1, math.floor(tonumber(item.amount) or 1))
    if (stock[index] or 0) < amount then
        sendResult(source, false, ('%s is out of stock.'):format(item.label or item.item))
        return
    end

    local currency = item.currency or 'cash'
    local total = item.price * amount
    local money = tonumber(codecraft_lib.getMoney(source, currency)) or 0

    if money < total then
        sendResult(source, false, ('You need $%s more.'):format(total - money))
        return
    end

    local removed = codecraft_lib.RemoveMoney(source, currency, total)
    if removed == false then
        sendResult(source, false, 'The purchase could not be completed.')
        return
    end

    local added = codecraft_lib.AddItem(source, item.item, amount, item.metadata, nil)
    if added == false then
        codecraft_lib.AddMoney(source, currency, total)
        sendResult(source, false, 'You do not have enough inventory space.')
        return
    end

    stock[index] = stock[index] - amount
    codecraft_lib.ItemBox(source, item.item, 'add', amount)
    sendResult(source, true, ('Purchased %sx %s for $%s.'):format(amount, item.label or item.item, total))
end)
