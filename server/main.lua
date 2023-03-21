QBCore = exports['qb-core']:GetCoreObject()

-- Functions --

local function comma_value(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

function isAllowedToBill(player)
    local playerJob = player.PlayerData.job
    for k, v in pairs(Config.PermittedJobs) do
        if v == playerJob.name then
            if not playerJob.onduty and Config.OnDutyToBillEnabled then
                return false
            end
            return true
        end
    end
    return false
end

function getPendingBilled(source)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local result = MySQL.query.await('SELECT * FROM bills WHERE sender_citizenid = ? AND status = ?', {
        player.PlayerData.citizenid,
        'Unpaid'
    })
    return result
end

function getPaidBilled(source)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local result = MySQL.query.await('SELECT * FROM bills WHERE sender_citizenid = ? AND status = ?', {
        player.PlayerData.citizenid,
        'Paid'
    })
    return result
end

function getBillsToPay(source)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local result = MySQL.query.await('SELECT * FROM bills WHERE recipient_citizenid = ? AND status = ?', {
        player.PlayerData.citizenid,
        'Unpaid'
    })
    return result
end

function getPaidBills(source)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local result = MySQL.query.await('SELECT * FROM bills WHERE recipient_citizenid = ? AND status = ?', {
        player.PlayerData.citizenid,
        'Paid'
    })
    return result
end

-- Events --

RegisterNetEvent('billing:server:RequestCommands')
AddEventHandler('billing:server:RequestCommands', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if isAllowedToBill(player) then
        TriggerClientEvent('billing:client:RequestCommands', src, true)
    end
end)

RegisterNetEvent('billing:server:sendBill')
AddEventHandler('billing:server:sendBill', function(data)
    local src = source
    local sender = QBCore.Functions.GetPlayer(src)
    local billAmount = data.billAmount
    local recipient = data.recipient
    local recipientFullName = (recipient.PlayerData.charinfo.firstname .. ' ' .. recipient.PlayerData.charinfo.lastname)
    local senderFullName = (sender.PlayerData.charinfo.firstname .. ' ' .. sender.PlayerData.charinfo.lastname)
    local senderAccount = sender.PlayerData.job.name
    if isAllowedToBill(sender) then
        local datetime = os.date('%Y-%m-%d %H:%M:%S')
        local sql = 'INSERT INTO bills (bill_date, amount, sender_account, sender_name, sender_citizenid, recipient_name, recipient_citizenid, status, status_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
        MySQL.insert(sql, {
            datetime,
            billAmount,
            senderAccount,
            senderFullName,
            sender.PlayerData.citizenid,
            recipientFullName,
            recipient.PlayerData.citizenid,
            'Unpaid',
            datetime
        }, function(result)
            if result > 0 then
                TriggerClientEvent('QBCore:Notify', src, Lang:t('success.bill_sent', { amount = comma_value(billAmount), recipient = recipientFullName }), 'success')
                TriggerClientEvent('QBCore:Notify', recipient.PlayerData.source, Lang:t('info.bill_received', { amount = comma_value(billAmount), sender = senderFullName, account = senderAccount }), 'success')
            else
                TriggerClientEvent('QBCore:Notify', src, Lang:t('error.sending_bill'), 'error')
            end
        end)
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_permitted'), 'error')
    end
end)

RegisterNetEvent('billing:server:getPendingBilled')
AddEventHandler('billing:server:getPendingBilled', function()
    local src = source
    local bills = getPendingBilled(src)
    if bills and bills[1] then
        TriggerClientEvent('billing:client:openPendingBilledMenu', src, bills)
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.retrieving_bills'), 'error')
    end
end)

RegisterNetEvent('billing:server:getPaidBilled')
AddEventHandler('billing:server:getPaidBilled', function()
    local src = source
    local bills = getPaidBilled(src)
    if bills and bills[1] then
        TriggerClientEvent('billing:client:openPaidBilledMenu', src, bills)
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.retrieving_bills'), 'error')
    end
end)

RegisterNetEvent('billing:server:getBillsToPay')
AddEventHandler('billing:server:getBillsToPay', function()
    local src = source
    local bills = getBillsToPay(src)
    if bills and bills[1] then
        TriggerClientEvent('billing:client:openBillsToPayMenu', src, bills)
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.retrieving_bills'), 'error')
    end
end)

RegisterNetEvent('billing:server:getPaidBills')
AddEventHandler('billing:server:getPaidBills', function()
    local src = source
    local bills = getPaidBills(src)
    if bills and bills[1] then
        TriggerClientEvent('billing:client:openPaidBillsMenu', src, bills)
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.retrieving_bills'), 'error')
    end
end)

RegisterNetEvent('billing:server:payBill')
AddEventHandler('billing:server:payBill', function(data)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local bill = data.bill
    if player.Functions.GetMoney('bank') >= bill.amount then
        player.Functions.RemoveMoney('bank', bill.amount, Lang:t('other.bill_pay_desc'))
        exports['qb-management']:AddMoney(bill.sender_account, bill.amount)
        local sender = QBCore.Functions.GetPlayerByCitizenId(bill.sender_citizenid)
        local datetime = os.date('%Y-%m-%d %H:%M:%S')
        if sender then
            TriggerClientEvent('QBCore:Notify', sender.PlayerData.source, Lang:t('info.bill_paid_sender', { billId = bill.id, amount = comma_value(bill.amount), recipient = bill.recipient_name }), 'success')
        end
        TriggerClientEvent('QBCore:Notify', src, Lang:t('success.bill_paid_recipient', { billId = bill.id, amount = comma_value(bill.amount), senderName = bill.sender_name, account = bill.sender_account }), 'success')
        MySQL.update('UPDATE bills SET status = ?, status_date = ? WHERE id = ? AND bill_date = ? AND amount = ? AND sender_account = ? AND recipient_citizenid = ? AND status = ?', {
            'Paid',
            datetime,
            bill.id,
            bill.bill_date,
            bill.amount,
            bill.sender_account,
            bill.recipient_citizenid,
            'Unpaid'
        })
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('error.not_enough_money'), 'error')
    end
end)

RegisterNetEvent('billing:server:deleteBill')
AddEventHandler('billing:server:deleteBill', function(data)
    local src = source
    local bill = data.bill
    local recipient = QBCore.Functions.GetPlayerByCitizenId(bill.recipient_citizenid)
    MySQL.query('DELETE FROM bills WHERE id = ? AND bill_date = ? AND amount = ? AND sender_account = ? AND recipient_citizenid = ? AND status = ?', {
        bill.id,
        bill.bill_date,
        bill.amount,
        bill.sender_account,
        bill.recipient_citizenid,
        bill.status
    })
    if recipient then
        TriggerClientEvent('QBCore:Notify', recipient.PlayerData.source, Lang:t('info.bill_canceled_recipient', { billId = bill.id, amount = comma_value(bill.amount), senderName = bill.sender_name, account = bill.sender_account }), 'success')
    end
    TriggerClientEvent('QBCore:Notify', src, Lang:t('success.bill_canceled_sender'), 'success')
end)

-- Callbacks --

QBCore.Functions.CreateCallback('billing:server:canSendBill', function(source, cb)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if isAllowedToBill(player) then
        cb(true)
    end
    cb(false)
end)

QBCore.Functions.CreateCallback('billing:server:hasBillsToPay', function(source, cb)
    local src = source
    local result = getBillsToPay(src)
    if result and result[1] then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('billing:server:getPlayerFromId', function(source, cb, playerId)
    local player = QBCore.Functions.GetPlayer(tonumber(playerId))
    cb(player)
end)