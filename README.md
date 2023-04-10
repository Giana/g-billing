# G-Billing

G-Billing is a script for FiveM QBCore providing a simple and intuitive menu (accessed via one command) for employees to send bills on behalf of boss accounts/society funds and for employees *and* regular citizens to manage, view, and pay bills.

Note: G-Billing is a completely separate script/system from QBCore's included /bill command and qb-phone app.

<h1>INSTALLATION GUIDE</h1>

1. Drop the g-billing folder into your [standalone] folder (or whichever other ensured folder you want to use)
2. Execute the query from g-billing.sql in your server's database

<h1>FEATURES</h1>

- /billing to open up the billing menu
  - View your own owed and paid bills
  - View your pending and paid bills sent to other citizens
  - Send new bills
    - Can be sent by server ID or to closest player (if enabled)
  - Pay owed bills
  - Cancel pending bills
- Enable/disable pop-up and/or text notifications regarding bill status changes

**IMAGES**
-----
![Options Menu](https://i.ibb.co/wYp1frv/gbillingoptionsmenu.png)
![Send Bill Menu](https://i.ibb.co/jMFQt0b/gbillingsendbillmenu.png)
![Bills Owed Menu](https://i.ibb.co/Fx1b4KD/gbillingbillsowedmenu.png)
![Text Notification](https://i.ibb.co/tLFZcgt/gbillingtextnotification.png)

**DEPENDENCIES**
-----
- [QBCore](https://github.com/qbcore-framework)
  - [qb-core](https://github.com/qbcore-framework/qb-core)
  - [qb-input](https://github.com/qbcore-framework/qb-input)
  - [qb-management](https://github.com/qbcore-framework/qb-management)
  - [qb-menu](https://github.com/qbcore-framework/qb-menu)
  - [qb-phone](https://github.com/qbcore-framework/qb-phone)

**CREDIT**
-----
The code for getting the closest player was repurposed from [qb-ambulancejob](https://github.com/qbcore-framework/qb-ambulancejob).