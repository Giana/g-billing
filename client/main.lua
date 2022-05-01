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

local function engageConfirmBillMenu(billAmount, recipient)
    local recCharInfo = recipient.PlayerData.charinfo
    local menu = {
        {
            header = 'Are you sure you want to send this bill?',
            isMenuHeader = true,
            txt = 'Amount: $' .. comma_value(billAmount) .. ' billed to ' .. recCharInfo.firstname .. ' ' .. recCharInfo.lastname .. ''
        },
        {
            header = 'No, I changed my mind!',
            params = {
                event = exports['qb-menu']:closeMenu()
            }
        },
        {
            header = 'Yes, send this bill on behalf of the "' .. QBCore.Functions.GetPlayerData().job.name .. '" account.',
            params = {
                isServer = true,
                event = 'billing:server:sendBill',
                args = {
                    billAmount = billAmount,
                    recipient = recipient
                }
            }
        },
    }

    exports['qb-menu']:openMenu(menu)
end

local function engageSendBillMenu()
    local senderData = QBCore.Functions.GetPlayerData()
    local menu = {
        {
            header = 'Do you want to send a bill?',
            isMenuHeader = true,
            txt = 'Account: "' .. senderData.job.name .. '"'
        },
        {
            header = '• Send a Bill',
            params = {
                event = 'billing:client:createBill'
            }
        },
        {
            header = '← Return',
            params = {
                event = 'billing:client:engageChooseBillViewMenu'
            }
        },
        {
            header = '✖ Cancel',
            params = {
                event = exports['qb-menu']:closeMenu()
            }
        },
    }

    exports['qb-menu']:openMenu(menu)
end

-- Commands --

RegisterCommand(Config.BillingCommand, function()
    TriggerEvent('billing:client:engageChooseBillViewMenu')
end)

-- Events --

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('billing:server:RequestCommands')
end)

RegisterNetEvent('billing:client:RequestCommands', function(isAllowed)
    if isAllowed then
        TriggerServerEvent('chat:addSuggestion', '/' .. Config.BillingCommand, {})
    end
end)

RegisterNetEvent('billing:client:canSendBill', function()
    QBCore.Functions.TriggerCallback('billing:server:canSendBill', function(canSendBill)
        if canSendBill then
            engageSendBillMenu()
        else
            QBCore.Functions.Notify('You must be on duty and authorized to bill for your occupation!', 'error')
        end
    end)
end)

RegisterNetEvent('billing:client:notifyOfPaidBill', function()
    QBCore.Functions.Notify('This bill is already paid!', 'error')
end)

RegisterNetEvent('billing:client:createBill', function()
    local recipientID = nil
    local billAmount = nil

    local input = exports['qb-input']:ShowInput({
        header = "New Bill",
        submitText = "Confirm",
        inputs = {
            {
                text = "Recipient Server ID (#)",
                name = "id",
                type = "number",
                isRequired = true
            },
            {
                text = "Amount ($)",
                name = "amount",
                type = "number",
                isRequired = true
            }
        },
    })
    recipientID = input.id
    billAmount = input.amount

    if not recipientID then
        QBCore.Functions.Notify('Error getting recipient ID', 'error')
        return
    end

    if not billAmount then
        QBCore.Functions.Notify('Error getting bill amount', 'error')
        return
    end

    QBCore.Functions.TriggerCallback('billing:server:getPlayerFromId', function(validRecipient)
        if validRecipient then
            engageConfirmBillMenu(billAmount, validRecipient)
        else
            QBCore.Functions.Notify('Error getting player from given ID', 'error')
        end
    end, recipientID)
end)

RegisterNetEvent('billing:client:engageChooseBillViewMenu', function()
    local menu = {
        {
            header = 'Options',
            isMenuHeader = true
        },
        {
            header = '• View Your Bills',
            params = {
                event = 'billing:client:engageChooseYourBillsViewMenu'
            }
        },
        {
            header = '• View Sent Bills',
            params = {
                event = 'billing:client:engageChooseSentBillsViewMenu'
            }
        },
        {
            header = '• Send New Bill',
            params = {
                event = 'billing:client:canSendBill'
            }
        },
        {
            header = '✖ Cancel',
            params = {
                event = exports['qb-menu']:closeMenu()
            }
        },
    }

    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent('billing:client:engageChooseSentBillsViewMenu', function()
    local menu = {
        {
            header = 'Sent Bills',
            isMenuHeader = true
        },
        {
            header = '• View Pending',
            params = {
                isServer = true,
                event = 'billing:server:getPendingBilled'
            }
        },
        {
            header = '• View Paid',
            params = {
                isServer = true,
                event = 'billing:server:getPaidBilled'
            }
        },
        {
            header = '← Return',
            params = {
                event = 'billing:client:engageChooseBillViewMenu'
            }
        },
        {
            header = '✖ Cancel',
            params = {
                event = exports['qb-menu']:closeMenu()
            }
        },
    }

    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent('billing:client:engageChooseYourBillsViewMenu', function()
    local menu = {
        {
            header = 'Your Bills',
            isMenuHeader = true
        },
        {
            header = '• View Current Due',
            params = {
                isServer = true,
                event = 'billing:server:getBillsToPay'
            }
        },
        {
            header = '• View Past Paid',
            params = {
                isServer = true,
                event = 'billing:server:getPaidBills'
            }
        },
        {
            header = '← Return',
            params = {
                event = 'billing:client:engageChooseBillViewMenu'
            }
        },
        {
            header = '✖ Cancel',
            params = {
                event = exports['qb-menu']:closeMenu()
            }
        },
    }

    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent('billing:client:openConfirmPayBillMenu', function(data)
    local bill = data.bill
    local billsMenu = {
        {
            header = 'Are you sure you want to pay this bill for $' .. comma_value(bill.amount) .. '?',
            isMenuHeader = true,
            txt = 'Bill #' .. bill.id .. '<br>Date: ' .. bill.bill_date .. '<br>Due to: ' .. bill.sender_name .. ' "' .. bill.sender_account .. '"'
        },
        {
            header = 'No, take me back!',
            params = {
                isServer = true,
                event = 'billing:server:getBillsToPay'
            }
        },
        {
            header = 'Yes, I want to pay it!',
            params = {
                isServer = true,
                event = 'billing:server:payBill',
                args = {
                    bill = bill
                }
            }
        }
    }

    exports['qb-menu']:openMenu(billsMenu)
end)

RegisterNetEvent('billing:client:openConfirmCancelBillMenu', function(data)
    local bill = data.bill
    local billsMenu = {
        {
            header = 'Are you sure you want to cancel this bill for $' .. comma_value(bill.amount) .. '?',
            isMenuHeader = true,
            txt = 'Date: ' .. bill.bill_date .. '<br>Due to: "' .. bill.sender_account .. '"<br>Recipient: ' .. bill.recipient_name .. ' (' .. bill.recipient_citizenid .. ')'
        },
        {
            header = 'No, take me back!',
            params = {
                isServer = true,
                event = 'billing:server:getPendingBilled'
            }
        },
        {
            header = 'Yes, cancel this bill!',
            params = {
                isServer = true,
                event = 'billing:server:deleteBill',
                args = {
                    bill = bill
                }
            }
        }
    }

    exports['qb-menu']:openMenu(billsMenu)
end)

RegisterNetEvent('billing:client:openPendingBilledMenu', function(bills)
    local ordered_keys = {}
    local totalDue = 0

    for k, v in pairs(bills) do
        table.insert(ordered_keys, k)
        totalDue = totalDue + v.amount
    end

    table.sort(ordered_keys)

    local billsMenu = {
        {
            header = 'Bills Owed',
            isMenuHeader = true,
            txt = 'Total Due: $' .. comma_value(totalDue) .. ''
        }
    }

    for i = #ordered_keys, 1, -1 do
        local v = bills[i]
        billsMenu[#billsMenu + 1] = {
            header = '#' .. v.id .. ' - $' .. comma_value(v.amount) .. '',
            txt = 'Date: ' .. v.bill_date .. '<br>Due to: "' .. v.sender_account .. '"<br>Recipient: ' .. v.recipient_name .. ' (' .. v.recipient_citizenid .. ')',
            params = {
                event = 'billing:client:openConfirmCancelBillMenu',
                args = {
                    bill = v
                }
            }
        }
    end
    billsMenu[#billsMenu + 1] = {
        header = '← Return',
        params = {
            event = 'billing:client:engageChooseSentBillsViewMenu'
        }
    }
    billsMenu[#billsMenu + 1] = {
        header = '✖ Cancel',
        params = {
            event = 'qb-menu:client:closeMenu'
        }
    }

    exports['qb-menu']:openMenu(billsMenu)
end)

RegisterNetEvent('billing:client:openPaidBilledMenu', function(bills)
    local ordered_keys = {}
    local totalPaid = 0

    for k, v in pairs(bills) do
        table.insert(ordered_keys, k)
        totalPaid = totalPaid + v.amount
    end

    table.sort(ordered_keys)

    local billsMenu = {
        {
            header = 'Bills Paid',
            isMenuHeader = true,
            txt = 'Total Paid: $' .. comma_value(totalPaid) .. ''
        }
    }

    for i = #ordered_keys, 1, -1 do
        local v = bills[i]
        billsMenu[#billsMenu + 1] = {
            header = '#' .. v.id .. ' - $' .. comma_value(v.amount) .. '',
            txt = 'Date: ' .. v.bill_date .. '<br>Due to: "' .. v.sender_account .. '"<br>Recipient: ' .. v.recipient_name .. ' (' .. v.recipient_citizenid .. ')<br>Paid: ' .. v.status_date .. '',
            params = {
                event = 'billing:client:notifyOfPaidBill'
            }
        }
    end
    billsMenu[#billsMenu + 1] = {
        header = '← Return',
        params = {
            event = 'billing:client:engageChooseSentBillsViewMenu'
        }
    }
    billsMenu[#billsMenu + 1] = {
        header = '✖ Cancel',
        params = {
            event = 'qb-menu:client:closeMenu'
        }
    }

    exports['qb-menu']:openMenu(billsMenu)
end)

RegisterNetEvent('billing:client:openBillsToPayMenu', function(bills)
    local ordered_keys = {}
    local totalDue = 0

    for k, v in pairs(bills) do
        table.insert(ordered_keys, k)
        totalDue = totalDue + v.amount
    end

    table.sort(ordered_keys)

    local billsMenu = {
        {
            header = 'Owed Bills',
            isMenuHeader = true,
            txt = 'Total Due: $' .. comma_value(totalDue) .. ''
        }
    }

    for i = #ordered_keys, 1, -1 do
        local v = bills[i]
        billsMenu[#billsMenu + 1] = {
            header = '#' .. v.id .. ' - $' .. comma_value(v.amount) .. '',
            txt = 'Date: ' .. v.bill_date .. '<br>Due to: ' .. v.sender_name .. ' "' .. v.sender_account .. '"',
            params = {
                event = 'billing:client:openConfirmPayBillMenu',
                args = {
                    bill = v
                }
            }
        }
    end
    billsMenu[#billsMenu + 1] = {
        header = '← Return',
        params = {
            event = 'billing:client:engageChooseYourBillsViewMenu'
        }
    }
    billsMenu[#billsMenu + 1] = {
        header = '✖ Cancel',
        params = {
            event = 'qb-menu:client:closeMenu'
        }
    }

    exports['qb-menu']:openMenu(billsMenu)
end)

RegisterNetEvent('billing:client:openPaidBillsMenu', function(bills)
    local ordered_keys = {}
    local totalPaid = 0

    for k, v in pairs(bills) do
        table.insert(ordered_keys, k)
        totalPaid = totalPaid + v.amount
    end

    table.sort(ordered_keys)

    local billsMenu = {
        {
            header = 'Paid Bills',
            isMenuHeader = true,
            txt = 'Total Paid: $' .. comma_value(totalPaid) .. ''
        }
    }

    for i = #ordered_keys, 1, -1 do
        local v = bills[i]
        billsMenu[#billsMenu + 1] = {
            header = '#' .. v.id .. ' - $' .. comma_value(v.amount) .. '',
            txt = 'Date: ' .. v.bill_date .. '<br>Due to: ' .. v.sender_name .. ' "' .. v.sender_account .. '"<br>Paid: ' .. v.status_date .. '',
            params = {
                event = 'billing:client:notifyOfPaidBill'
            }
        }
    end
    billsMenu[#billsMenu + 1] = {
        header = '← Return',
        params = {
            event = 'billing:client:engageChooseYourBillsViewMenu'
        }
    }
    billsMenu[#billsMenu + 1] = {
        header = '✖ Cancel',
        params = {
            event = 'qb-menu:client:closeMenu'
        }
    }

    exports['qb-menu']:openMenu(billsMenu)
end)