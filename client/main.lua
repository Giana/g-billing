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
            header = Lang:t('menu.confirm_send'),
            isMenuHeader = true,
            txt = Lang:t('menu.amount_billed_to', { amount = billAmount, firstName = recCharInfo.firstname, lastName = recCharInfo.lastname })
        },
        {
            header = Lang:t('menu.no_changed_mind'),
            params = {
                event = exports['qb-menu']:closeMenu()
            }
        },
        {
            header = Lang:t('menu.send_bill_for_account', { account = QBCore.Functions.GetPlayerData().job.name }),
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
            header = Lang:t('menu.ask_send'),
            isMenuHeader = true,
            txt = Lang:t('menu.account_name', { account = senderData.job.name })
        },
        {
            header = Lang:t('menu.send_bill_bullet'),
            params = {
                event = 'billing:client:createBill'
            }
        },
        {
            header = Lang:t('menu.return_bullet'),
            params = {
                event = 'billing:client:engageChooseBillViewMenu'
            }
        },
        {
            header = Lang:t('menu.cancel_bullet'),
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
            QBCore.Functions.Notify(Lang:t('error.must_be_on_duty'), 'error')
        end
    end)
end)

RegisterNetEvent('billing:client:notifyOfPaidBill', function()
    QBCore.Functions.Notify(Lang:t('error.already_paid'), 'error')
end)

RegisterNetEvent('billing:client:createBill', function()
    local recipientID = nil
    local billAmount = nil

    local input = exports['qb-input']:ShowInput({
        header = Lang:t('menu.new_bill'),
        submitText = Lang:t('menu.confirm'),
        inputs = {
            {
                text = Lang:t('menu.recipient_id'),
                name = 'id',
                type = 'number',
                isRequired = true
            },
            {
                text = Lang:t('menu.amount'),
                name = 'amount',
                type = 'number',
                isRequired = true
            }
        },
    })
    recipientID = input.id
    billAmount = input.amount
    if not recipientID then
        QBCore.Functions.Notify(Lang:t('error.getting_id'), 'error')
        return
    end
    if not billAmount then
        QBCore.Functions.Notify(Lang:t('error.getting_amount'), 'error')
        return
    end
    QBCore.Functions.TriggerCallback('billing:server:getPlayerFromId', function(validRecipient)
        if validRecipient then
            engageConfirmBillMenu(billAmount, validRecipient)
        else
            QBCore.Functions.Notify(Lang:t('error.getting_player'), 'error')
        end
    end, recipientID)
end)

RegisterNetEvent('billing:client:engageChooseBillViewMenu', function()
    local menu = {
        {
            header = Lang:t('menu.options'),
            isMenuHeader = true
        },
        {
            header = Lang:t('menu.view_your_bills_bullet'),
            params = {
                event = 'billing:client:engageChooseYourBillsViewMenu'
            }
        },
        {
            header = Lang:t('menu.view_sent_bills_bullet'),
            params = {
                event = 'billing:client:engageChooseSentBillsViewMenu'
            }
        },
        {
            header = Lang:t('menu.send_bill_bullet'),
            params = {
                event = 'billing:client:canSendBill'
            }
        },
        {
            header = Lang:t('menu.cancel_bullet'),
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
            header = Lang:t('menu.sent_bills'),
            isMenuHeader = true
        },
        {
            header = Lang:t('menu.view_pending_bullet'),
            params = {
                isServer = true,
                event = 'billing:server:getPendingBilled'
            }
        },
        {
            header = Lang:t('menu.view_paid_bullet'),
            params = {
                isServer = true,
                event = 'billing:server:getPaidBilled'
            }
        },
        {
            header = Lang:t('menu.return_bullet'),
            params = {
                event = 'billing:client:engageChooseBillViewMenu'
            }
        },
        {
            header = Lang:t('menu.cancel_bullet'),
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
            header = Lang:t('menu.your_bills'),
            isMenuHeader = true
        },
        {
            header = Lang:t('menu.view_current_due_bullet'),
            params = {
                isServer = true,
                event = 'billing:server:getBillsToPay'
            }
        },
        {
            header = Lang:t('menu.view_past_paid_bullet'),
            params = {
                isServer = true,
                event = 'billing:server:getPaidBills'
            }
        },
        {
            header = Lang:t('menu.return_bullet'),
            params = {
                event = 'billing:client:engageChooseBillViewMenu'
            }
        },
        {
            header = Lang:t('menu.cancel_bullet'),
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
            header = Lang:t('menu.confirm_pay', { amount = comma_value(bill.amount) }),
            isMenuHeader = true,
            txt = Lang:t('menu.confirm_bill_info', { billId = bill.id, date = bill.bill_date, senderName = bill.sender_name, account = bill.sender_account })
        },
        {
            header = Lang:t('menu.no_back'),
            params = {
                isServer = true,
                event = 'billing:server:getBillsToPay'
            }
        },
        {
            header = Lang:t('menu.yes_pay'),
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
            header = Lang:t('menu.confirm_cancel', { amount = comma_value(bill.amount) }),
            isMenuHeader = true,
            txt = Lang:t('menu.cancel_bill_info', { date = bill.bill_date, account = bill.sender_account, recipientName = bill.recipient_name, recipientCid = bill.recipient_citizenid })
        },
        {
            header = Lang:t('menu.no_back'),
            params = {
                isServer = true,
                event = 'billing:server:getPendingBilled'
            }
        },
        {
            header = Lang:t('menu.yes_cancel'),
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
            header = Lang:t('menu.bills_owed'),
            isMenuHeader = true,
            txt = Lang:t('menu.total_owed', { amount = comma_value(totalDue) })
        }
    }
    for i = #ordered_keys, 1, -1 do
        local v = bills[i]
        billsMenu[#billsMenu + 1] = {
            header = Lang:t('menu.id_amount', { id = v.id, amount = comma_value(v.amount) }),
            txt = Lang:t('menu.cancel_bill_info', { date = v.bill_date, account = v.sender_account, recipientName = v.recipient_name, recipientCid = v.recipient_citizenid }),
            params = {
                event = 'billing:client:openConfirmCancelBillMenu',
                args = {
                    bill = v
                }
            }
        }
    end
    billsMenu[#billsMenu + 1] = {
        header = Lang:t('menu.return_bullet'),
        params = {
            event = 'billing:client:engageChooseSentBillsViewMenu'
        }
    }
    billsMenu[#billsMenu + 1] = {
        header = Lang:t('menu.cancel_bullet'),
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
            header = Lang:t('menu.bills_paid'),
            isMenuHeader = true,
            txt = Lang:t('menu.total_paid', { amount = comma_value(totalPaid) })
        }
    }
    for i = #ordered_keys, 1, -1 do
        local v = bills[i]
        billsMenu[#billsMenu + 1] = {
            header = Lang:t('menu.id_amount', { id = v.id, amount = comma_value(v.amount) }),
            txt = Lang:t('menu.paid_billed_info', { date = v.bill_date, account = v.sender_account, recipientName = v.recipient_name, recipientCid = v.recipient_citizenid, datePaid = v.status_date }),
            params = {
                event = 'billing:client:notifyOfPaidBill'
            }
        }
    end
    billsMenu[#billsMenu + 1] = {
        header = Lang:t('menu.return_bullet'),
        params = {
            event = 'billing:client:engageChooseSentBillsViewMenu'
        }
    }
    billsMenu[#billsMenu + 1] = {
        header = Lang:t('menu.cancel_bullet'),
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
            header = Lang:t('menu.owed_bills'),
            isMenuHeader = true,
            txt = Lang:t('menu.total_due', { amount = comma_value(totalDue) })
        }
    }
    for i = #ordered_keys, 1, -1 do
        local v = bills[i]
        billsMenu[#billsMenu + 1] = {
            header = Lang:t('menu.id_amount', { id = v.id, amount = comma_value(v.amount) }),
            txt = Lang:t('menu.unpaid_bill_info', { date = v.bill_date, senderName = v.sender_name, account = v.sender_account }),
            params = {
                event = 'billing:client:openConfirmPayBillMenu',
                args = {
                    bill = v
                }
            }
        }
    end
    billsMenu[#billsMenu + 1] = {
        header = Lang:t('menu.return_bullet'),
        params = {
            event = 'billing:client:engageChooseYourBillsViewMenu'
        }
    }
    billsMenu[#billsMenu + 1] = {
        header = Lang:t('menu.cancel_bullet'),
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
            header = Lang:t('menu.paid_bills'),
            isMenuHeader = true,
            txt = Lang:t('menu.total_paid', { amount = comma_value(totalPaid) })
        }
    }
    for i = #ordered_keys, 1, -1 do
        local v = bills[i]
        billsMenu[#billsMenu + 1] = {
            header = Lang:t('menu.id_amount', { id = v.id, amount = comma_value(v.amount) }),
            txt = Lang:t('menu.paid_bills_info', { date = v.bill_date, senderName = v.sender_name, account = v.sender_account, datePaid = v.status_date }),
            params = {
                event = 'billing:client:notifyOfPaidBill'
            }
        }
    end
    billsMenu[#billsMenu + 1] = {
        header = Lang:t('menu.return_bullet'),
        params = {
            event = 'billing:client:engageChooseYourBillsViewMenu'
        }
    }
    billsMenu[#billsMenu + 1] = {
        header = Lang:t('menu.cancel_bullet'),
        params = {
            event = 'qb-menu:client:closeMenu'
        }
    }
    exports['qb-menu']:openMenu(billsMenu)
end)