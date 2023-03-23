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
        bill_sent = 'Bill sent - Amount: $%{amount} - To: %{recipient}',
        bill_paid_recipient = 'Bill paid - #%{billId} - Amount: $%{amount} - Paid to: %{senderName} "%{account}"',
        bill_canceled_sender = 'Bill canceled - #%{billId} - Amount: $%{amount} - To: %{recipient}',
        bill_sent_text = 'Bill sent<br>Amount: $%{amount}<br>To: %{recipient}<br><br>Access bill via /billing',
        bill_paid_recipient_text = 'Bill paid<br>#%{billId}<br>Amount: $%{amount}<br>Paid to: %{senderName} "%{account}"<br><br>Access bill via /billing',
        bill_canceled_sender_text = 'Bill canceled<br>#%{billId}<br>Amount: $%{amount}<br>To: %{recipient}<br><br>Access bill via /billing'
    },
    info = {
        bill_received = 'Bill received - Amount: $%{amount} - From: %{sender} "%{account}"',
        bill_paid_sender = 'Bill paid - #%{billId} - Amount: $%{amount} - Paid by: %{recipient}',
        bill_canceled_recipient = 'Bill canceled - #%{billId} - Amount: $%{amount} - Due to: %{senderName} "%{account}"',
        bill_received_text = 'Bill received<br>Amount: $%{amount}<br>From: %{sender} "%{account}"<br><br>Access bill via /billing',
        bill_paid_sender_text = 'Bill paid<br>#%{billId}<br>Amount: $%{amount}<br>Paid by: %{recipient}<br><br>Access bill via /billing',
        bill_canceled_recipient_text = 'Bill canceled<br>#%{billId}<br>Amount: $%{amount}<br>Due to: %{senderName} "%{account}"<br><br>Access bill via /billing'
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
        total_owed = 'Total Owed: $%{amount}',
        id_amount = '#%{id} - $%{amount}',
        bills_paid = 'Bills Paid',
        total_paid = 'Total Paid: $%{amount}',
        paid_billed_info = 'Date: %{date}<br>Due to: %{account}<br>Recipient: %{recipientName} (%{recipientCid})<br>Paid: %{datePaid}',
        owed_bills = 'Owed Bills',
        total_due = 'Total Due: $%{amount}',
        unpaid_bill_info = 'Date: %{date}<br>Due to: %{senderName} "%{account}"',
        paid_bills = 'Paid Bills',
        paid_bills_info = 'Date: %{date}<br>Due to: %{senderName} "%{account}"<br>Paid: %{datePaid}'
    },
    other = {
        bill_pay_desc = 'Bill pay',
        bill_text_sender = 'Billing Department',
        bill_sent_text_subject = 'Bill Sent',
        bill_received_text_subject = 'Bill Received',
        sent_bill_paid_text_subject = 'Sent Bill Paid',
        received_bill_paid_text_subject = 'Received Bill Paid',
        sent_bill_canceled_text_subject = 'Sent Bill Canceled',
        received_bill_canceled_text_subject = 'Received Bill Canceled'
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})