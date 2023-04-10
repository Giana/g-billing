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
                event = 'g-billing:client:engageChooseBillViewMenu'
            }
        },
        {
            header = Lang:t('menu.send_bill_for_account', { account = QBCore.Functions.GetPlayerData().job.name }),
            params = {
                isServer = true,
                event = 'g-billing:server:sendBill',
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
            header = Lang:t('menu.send_a_bill_id_bullet'),
            params = {
                event = 'g-billing:client:createBill',
                args = {
                    billingClosestPlayer = false
                }
            }
        }
    }
    if Config.AllowNearbyBilling then
        menu[#menu + 1] = {
            header = Lang:t('menu.send_a_bill_closest_bullet'),
            params = {
                event = 'g-billing:client:createBill',
                args = {
                    billingClosestPlayer = true
                }
            }
        }
    end
    menu[#menu + 1] = {
        header = Lang:t('menu.return_bullet'),
        params = {
            event = 'g-billing:client:engageChooseBillViewMenu'
        }
    }
    menu[#menu + 1] = {
        header = Lang:t('menu.cancel_bullet'),
        params = {
            event = exports['qb-menu']:closeMenu()
        }
    }
    exports['qb-menu']:openMenu(menu)
end

local function getClosestPlayer()
    local closestPlayers = QBCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(PlayerPedId())
    for i = 1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

-- Commands --

RegisterCommand(Config.BillingCommand, function()
    TriggerEvent('g-billing:client:engageChooseBillViewMenu')
end)

-- Events --

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerEvent('g-billing:client:RequestCommands')
end)

RegisterNetEvent('g-billing:client:RequestCommands', function()
    TriggerEvent('chat:addSuggestion', '/' .. Config.BillingCommand, Lang:t('other.chat_desc'))
end)

RegisterNetEvent('g-billing:client:canSendBill', function()
    QBCore.Functions.TriggerCallback('g-billing:server:canSendBill', function(canSendBill)
        if canSendBill then
            engageSendBillMenu()
        else
            QBCore.Functions.Notify(Lang:t('error.must_be_on_duty'), 'error')
        end
    end)
end)

RegisterNetEvent('g-billing:client:notifyOfPaidBill', function()
    QBCore.Functions.Notify(Lang:t('error.already_paid'), 'error')
    TriggerServerEvent('g-billing:server:getPaidBills')
end)

RegisterNetEvent('g-billing:client:notifyOfPaidBilled', function()
    QBCore.Functions.Notify(Lang:t('error.already_paid'), 'error')
    TriggerServerEvent('g-billing:server:getPaidBilled')
end)

RegisterNetEvent('g-billing:client:createBill', function(data)
    local recipientID
    local billAmount
    local billingClosestPlayer = data.billingClosestPlayer
    if billingClosestPlayer then
        local recipientPlayer, distance = getClosestPlayer()
        if recipientPlayer ~= -1 and distance < 4 then
            recipientID = GetPlayerServerId(recipientPlayer)
            if not recipientID then
                QBCore.Functions.Notify(Lang:t('error.getting_id'), 'error')
                return
            end
            local input = exports['qb-input']:ShowInput({
                header = Lang:t('menu.new_bill'),
                submitText = Lang:t('menu.confirm'),
                inputs = {
                    {
                        text = Lang:t('menu.amount'),
                        name = 'amount',
                        type = 'number',
                        isRequired = true
                    }
                }
            })
            if not input then
                return
            end
            billAmount = input.amount
            if not billAmount or billAmount == '' or tonumber(billAmount) <= 0 then
                QBCore.Functions.Notify(Lang:t('error.getting_amount'), 'error')
                return
            end
        else
            QBCore.Functions.Notify(Lang:t('error.no_nearby'), 'error')
            engageSendBillMenu()
            return
        end
    else
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
            }
        })
        if not input then
            return
        end
        recipientID = input.id
        billAmount = input.amount
        if not recipientID or recipientID == '' then
            QBCore.Functions.Notify(Lang:t('error.getting_id'), 'error')
            return
        end
        if not billAmount or billAmount == '' or tonumber(billAmount) <= 0 then
            QBCore.Functions.Notify(Lang:t('error.getting_amount'), 'error')
            return
        end
    end
    QBCore.Functions.TriggerCallback('g-billing:server:getPlayerFromId', function(validRecipient)
        if validRecipient then
            engageConfirmBillMenu(billAmount, validRecipient)
        else
            QBCore.Functions.Notify(Lang:t('error.getting_player'), 'error')
            engageSendBillMenu()
        end
    end, recipientID)
end)

RegisterNetEvent('g-billing:client:engageChooseBillViewMenu', function()
    local menu = {
        {
            header = Lang:t('menu.billing_options'),
            isMenuHeader = true
        },
        {
            header = Lang:t('menu.view_your_bills_bullet'),
            params = {
                event = 'g-billing:client:engageChooseYourBillsViewMenu'
            }
        },
        {
            header = Lang:t('menu.view_sent_bills_bullet'),
            params = {
                event = 'g-billing:client:engageChooseSentBillsViewMenu'
            }
        },
        {
            header = Lang:t('menu.send_new_bill_bullet'),
            params = {
                event = 'g-billing:client:canSendBill'
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

RegisterNetEvent('g-billing:client:engageChooseSentBillsViewMenu', function()
    local menu = {
        {
            header = Lang:t('menu.sent_bills'),
            isMenuHeader = true
        },
        {
            header = Lang:t('menu.view_pending_bullet'),
            params = {
                isServer = true,
                event = 'g-billing:server:getPendingBilled'
            }
        },
        {
            header = Lang:t('menu.view_paid_bullet'),
            params = {
                isServer = true,
                event = 'g-billing:server:getPaidBilled'
            }
        },
        {
            header = Lang:t('menu.return_bullet'),
            params = {
                event = 'g-billing:client:engageChooseBillViewMenu'
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

RegisterNetEvent('g-billing:client:engageChooseYourBillsViewMenu', function()
    local menu = {
        {
            header = Lang:t('menu.your_bills'),
            isMenuHeader = true
        },
        {
            header = Lang:t('menu.view_current_due_bullet'),
            params = {
                isServer = true,
                event = 'g-billing:server:getBillsToPay'
            }
        },
        {
            header = Lang:t('menu.view_past_paid_bullet'),
            params = {
                isServer = true,
                event = 'g-billing:server:getPaidBills'
            }
        },
        {
            header = Lang:t('menu.return_bullet'),
            params = {
                event = 'g-billing:client:engageChooseBillViewMenu'
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

RegisterNetEvent('g-billing:client:openConfirmPayBillMenu', function(data)
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
                event = 'g-billing:server:getBillsToPay'
            }
        },
        {
            header = Lang:t('menu.yes_pay'),
            params = {
                isServer = true,
                event = 'g-billing:server:payBill',
                args = {
                    bill = bill
                }
            }
        }
    }
    exports['qb-menu']:openMenu(billsMenu)
end)

RegisterNetEvent('g-billing:client:openConfirmCancelBillMenu', function(data)
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
                event = 'g-billing:server:getPendingBilled'
            }
        },
        {
            header = Lang:t('menu.yes_cancel'),
            params = {
                isServer = true,
                event = 'g-billing:server:deleteBill',
                args = {
                    bill = bill
                }
            }
        }
    }
    exports['qb-menu']:openMenu(billsMenu)
end)

RegisterNetEvent('g-billing:client:openPendingBilledMenu', function(bills)
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
    if #bills > 6 then
        billsMenu[#billsMenu + 1] = {
            header = Lang:t('menu.return_bullet'),
            params = {
                event = 'g-billing:client:engageChooseSentBillsViewMenu'
            }
        }
    end
    for i = #ordered_keys, 1, -1 do
        local v = bills[i]
        billsMenu[#billsMenu + 1] = {
            header = Lang:t('menu.id_amount', { id = v.id, amount = comma_value(v.amount) }),
            txt = Lang:t('menu.cancel_bill_info', { date = v.bill_date, account = v.sender_account, recipientName = v.recipient_name, recipientCid = v.recipient_citizenid }),
            params = {
                event = 'g-billing:client:openConfirmCancelBillMenu',
                args = {
                    bill = v
                }
            }
        }
    end
    billsMenu[#billsMenu + 1] = {
        header = Lang:t('menu.return_bullet'),
        params = {
            event = 'g-billing:client:engageChooseSentBillsViewMenu'
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

RegisterNetEvent('g-billing:client:openPaidBilledMenu', function(bills)
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
    if #bills > 6 then
        billsMenu[#billsMenu + 1] = {
            header = Lang:t('menu.return_bullet'),
            params = {
                event = 'g-billing:client:engageChooseSentBillsViewMenu'
            }
        }
    end
    for i = #ordered_keys, 1, -1 do
        local v = bills[i]
        billsMenu[#billsMenu + 1] = {
            header = Lang:t('menu.id_amount', { id = v.id, amount = comma_value(v.amount) }),
            txt = Lang:t('menu.paid_billed_info', { date = v.bill_date, account = v.sender_account, recipientName = v.recipient_name, recipientCid = v.recipient_citizenid, datePaid = v.status_date }),
            params = {
                event = 'g-billing:client:notifyOfPaidBilled'
            }
        }
    end
    billsMenu[#billsMenu + 1] = {
        header = Lang:t('menu.return_bullet'),
        params = {
            event = 'g-billing:client:engageChooseSentBillsViewMenu'
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

RegisterNetEvent('g-billing:client:openBillsToPayMenu', function(bills)
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
    if #bills > 6 then
        billsMenu[#billsMenu + 1] = {
            header = Lang:t('menu.return_bullet'),
            params = {
                event = 'g-billing:client:engageChooseYourBillsViewMenu'
            }
        }
    end
    for i = #ordered_keys, 1, -1 do
        local v = bills[i]
        billsMenu[#billsMenu + 1] = {
            header = Lang:t('menu.id_amount', { id = v.id, amount = comma_value(v.amount) }),
            txt = Lang:t('menu.unpaid_bill_info', { date = v.bill_date, senderName = v.sender_name, account = v.sender_account }),
            params = {
                event = 'g-billing:client:openConfirmPayBillMenu',
                args = {
                    bill = v
                }
            }
        }
    end
    billsMenu[#billsMenu + 1] = {
        header = Lang:t('menu.return_bullet'),
        params = {
            event = 'g-billing:client:engageChooseYourBillsViewMenu'
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

RegisterNetEvent('g-billing:client:openPaidBillsMenu', function(bills)
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
    if #bills > 6 then
        billsMenu[#billsMenu + 1] = {
            header = Lang:t('menu.return_bullet'),
            params = {
                event = 'g-billing:client:engageChooseYourBillsViewMenu'
            }
        }
    end
    for i = #ordered_keys, 1, -1 do
        local v = bills[i]
        billsMenu[#billsMenu + 1] = {
            header = Lang:t('menu.id_amount', { id = v.id, amount = comma_value(v.amount) }),
            txt = Lang:t('menu.paid_bills_info', { date = v.bill_date, senderName = v.sender_name, account = v.sender_account, datePaid = v.status_date }),
            params = {
                event = 'g-billing:client:notifyOfPaidBill'
            }
        }
    end
    billsMenu[#billsMenu + 1] = {
        header = Lang:t('menu.return_bullet'),
        params = {
            event = 'g-billing:client:engageChooseYourBillsViewMenu'
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

RegisterNetEvent('g-billing:client:sendText', function(subject, message)
    TriggerServerEvent('qb-phone:server:sendNewMail', { sender = Lang:t('other.bill_text_sender'), subject = subject, message = message })
end)

RegisterNetEvent('g-billing:client:getBillsToPay', function()
    TriggerServerEvent('g-billing:server:getBillsToPay')
end)

RegisterNetEvent('g-billing:client:getPendingBilled', function()
    TriggerServerEvent('g-billing:server:getPendingBilled')
end)