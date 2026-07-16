CREATE DATABASE IF NOT EXISTS personal_savings
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE personal_savings;

CREATE TABLE IF NOT EXISTS user_accounts (
  account_id INT NOT NULL AUTO_INCREMENT,
  full_name VARCHAR(100) NOT NULL,
  account_username VARCHAR(50) NOT NULL,
  account_password CHAR(64) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (account_id),
  UNIQUE KEY uq_account_username (account_username)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS transactions (
  transaction_id INT NOT NULL AUTO_INCREMENT,
  account_id INT NOT NULL,
  transaction_type ENUM('deposit', 'withdrawal') NOT NULL,
  transaction_date DATE NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  description VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (transaction_id),
  CONSTRAINT fk_transactions_account FOREIGN KEY (account_id)
    REFERENCES user_accounts(account_id) ON DELETE CASCADE,
  CONSTRAINT chk_transaction_amount CHECK (amount > 0)
) ENGINE=InnoDB;
