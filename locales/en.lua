local Translations = {
    error = {
        must_be_on_duty = 'You must be on duty and authorized to bill for your occupation!',
        already_paid = 'This bill is already paid!',
        getting_id = 'Error getting recipient ID',
        getting_amount = 'Error getting bill amount',
        getting_player = 'Error getting player from given ID',
        sending_bill = 'Error sending bill',
        not_permitted = 'You are not permitted to bill for this account!',
        retrieving_bills = 'Error retrieving bills',
        not_enough_money = 'Not enough money in your bank account!'
    },
    success = {
        bill_sent = 'Bill sent\nAmount: $%{amount}\nTo: %{recipient}',
        bill_paid_recipient = 'Bill paid\n#%{billId}\nAmount: $%{amount}\nPaid to: %{senderName} "%{account}"',
        bill_canceled_sender = 'Bill canceled'
    },
    info = {
        bill_received = 'Bill received\nAmount: $%{amount}\nFrom: %{sender} "%{account}"',
        bill_paid_sender = 'Bill paid\n#%{billId}\nAmount: $%{amount}\nPaid by: %{recipient}',
        bill_canceled_recipient = 'Bill canceled\n#%{billId}\nAmount: $%{amount}\nDue to: %{senderName} "%{account}"'
    },
    menu = {
        confirm_send = 'Are you sure you want to send this bill?',
        amount_billed_to = 'Amount: $%{amount}<br>Billed to: %{firstName} %{lastName}',
        no_changed_mind = 'No, I changed my mind!',
        send_bill_for_account = 'Yes, send this bill on behalf of this account: %{account}',
        ask_send = 'Do you want to send a bill?',
        account_name = 'Account: %{account}',
        send_bill_bullet = '• Send a Bill',
        return_bullet = '← Return',
        cancel_bullet = '✖ Cancel',
        new_bill = 'New Bill',
        confirm = 'Confirm',
        recipient_id = 'Recipient Server ID (#)',
        amount = 'Amount ($)',
        options = 'Options',
        view_your_bills_bullet = '• View Your Bills',
        view_sent_bills_bullet = '• View Sent Bills',
        send_bill_bullet = '• Send New Bill',
        sent_bills = 'Sent Bills',
        view_pending_bullet = '• View Pending',
        view_paid_bullet = '• View Paid',
        your_bills = 'Your Bills',
        view_current_due_bullet = '• View Current Due',
        view_past_paid_bullet = '• View Past Paid',
        confirm_pay = 'Are you sure you want to pay this bill? Amount: $%{amount}',
        no_back = 'No, take me back!',
        yes_pay = 'Yes, I want to pay it!',
        confirm_bill_info = 'Bill #%{billId}<br>Date: %{date}<br>Due to: %{senderName} "%{account}"',
        confirm_cancel = 'Are you sure you want to cancel this bill? Amount: $%{amount}',
        cancel_bill_info = 'Date: %{date}<br>Due to: %{account}<br>Recipient: %{recipientName} (%{recipientCid})',
        yes_cancel = 'Yes, cancel this bill!',
        bills_owed = 'Bills Owed',
        total_due = 'Total Due: $%{amount}',
        id_amount = '#%{id} - $%{amount}',
        bills_paid = 'Bills Paid',
        total_paid = 'Total Paid: $%{amount}',
        paid_billed_info = 'Date: %{date}<br>Due to: %{account}<br>Recipient: %{recipientName} (%{recipientCid})<br>Paid: %{datePaid}',
        owed_bills = 'Owed Bills',
        unpaid_bill_info = 'Date: %{date}<br>Due to: %{senderName} "%{account}"',
        paid_bills = 'Paid Bills',
        paid_bills_info = 'Date: %{date}<br>Due to: %{senderName} "%{account}"<br>Paid: %{datePaid}'
    },
    button = {

    },
    other = {
        bill_pay_desc = 'Bill pay'
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})