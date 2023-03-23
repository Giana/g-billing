Config = {}

Config.OnDutyToBillEnabled = true           -- If player must be on duty to bill

Config.EnableTextNotifications = true       -- If players receive text notifications for bill status changes
Config.EnablePopupNotification = true       -- If players receive pop-up notifications (QBCore Notify) for bill status changes

-- Jobs which can send bills on behalf of their respective establishments' accounts (qb-management)
Config.PermittedJobs = {
    'mechanic',
    'ambulance',
    'realestate',
    'taxi',
    'cardealer',
    'police'
}

-- Commands --
Config.BillingCommand = 'billing'