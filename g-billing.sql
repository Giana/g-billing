CREATE TABLE `bills` (
	`id` BIGINT(255) NOT NULL AUTO_INCREMENT,
    `bill_date` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
    `amount` INT(11) NULL DEFAULT NULL,
    `sender_account` VARCHAR(255) NOT NULL COLLATE 'utf8_general_ci',
    `sender_name` VARCHAR(255) NOT NULL COLLATE 'utf8_general_ci',
    `sender_citizenid` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
    `recipient_name` VARCHAR(255) NOT NULL COLLATE 'utf8_general_ci',
    `recipient_citizenid` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
    `status` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
    `status_date` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
    PRIMARY KEY (`id`) USING BTREE
) COLLATE='latin1_swedish_ci' ENGINE=InnoDB;