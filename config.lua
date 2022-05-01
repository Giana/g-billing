Config = {}

Config.OnDutyToBillEnabled = true  -- True == player must be on duty to bill, False == player does not have to be on duty to bill

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