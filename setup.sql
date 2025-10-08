-- CS 365 - Fall 2025 — Assignment 2

-- Resetting the Database if it exists
DROP DATABASE IF EXISTS passwords;
CREATE DATABASE passwords;

-- use this database for everything that follows
USE passwords;

-- Encrypt/decrypt settings
SET block_encryption_mode = "aes-256-ecb";
SET @key_str = UNHEX(SHA2("My awesome passphrase", 256));

-- Create the three tables: userAccount, site, credential
CREATE TABLE IF NOT EXISTS userAccount (
  userId     INT          NOT NULL AUTO_INCREMENT,
  firstName  VARCHAR(50)  NOT NULL,
  lastName   VARCHAR(50)  NOT NULL,
  username   VARCHAR(50)  NOT NULL,
  email      VARCHAR(255) NOT NULL,

  PRIMARY KEY (userId)
);

CREATE TABLE IF NOT EXISTS site (
  siteId    INT          NOT NULL AUTO_INCREMENT,
  siteName  VARCHAR(100) NOT NULL,
  url       VARCHAR(255) NOT NULL,

  UNIQUE (url),
  PRIMARY KEY (siteId)
);

CREATE TABLE IF NOT EXISTS credential (
  credId          INT            NOT NULL AUTO_INCREMENT,
  userId          INT            NOT NULL,
  siteId          INT            NOT NULL,
  passwordCipher  VARBINARY(255) NOT NULL,
  comment         TEXT,
  createdAt       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (credId),
  CONSTRAINT fk_credential_user FOREIGN KEY (userId) REFERENCES userAccount(userId),
  CONSTRAINT fk_credential_site FOREIGN KEY (siteId) REFERENCES site(siteId)
);

-- Making users and giving it credeintials
INSERT INTO userAccount (userId, firstName, lastName, username, email) VALUES
  (1, "Jordan", "Spector", "jspector", "jordan.n.spector@gmail.com"),
  (2, "Mia",    "Stein",   "mstein",  "mimi@outlook.com");

-- Making sites and giving it credentials
INSERT INTO site (siteId, siteName, url) VALUES
  (1, "Blackboard",  "https://blackboard.hartford.edu/ultra/stream"),
  (2, "GitHub",      "https://github.com"),
  (3, "Hartford",    "http://hartford.edu"),
  (4, "Mecha Ramen", "https://mecharamen.com"),
  (5, "ASUS",        "https://www.asus.com");

-- Inserting 10 credentials and each row ties a userId to a siteId and encrypts its password
INSERT INTO credential (userId, siteId, passwordCipher, comment) VALUES
  (1, 1, AES_ENCRYPT("BbJS_F25!1",   @key_str), "initial registration"),
  (1, 2, AES_ENCRYPT("GhJS_F25!2",   @key_str), "2FA enabled"),
  (1, 3, AES_ENCRYPT("HfdJS_F25!3",  @key_str), "migrated from legacy"),
  (1, 4, AES_ENCRYPT("MrJS_F25!4",   @key_str), "password rotation"),
  (1, 5, AES_ENCRYPT("AsusJS_F25!5", @key_str), "added for warranty portal"),
  (2, 1, AES_ENCRYPT("BbMS_F25!6",   @key_str), "initial registration"),
  (2, 2, AES_ENCRYPT("GhMS_F25!7",   @key_str), "2FA enabled"),
  (2, 3, AES_ENCRYPT("HfdMS_F25!8",  @key_str), "migrated from legacy"),
  (2, 4, AES_ENCRYPT("MrMS_F25!9",   @key_str), "password rotation"),
  (2, 5, AES_ENCRYPT("AsusMS_F25!10",@key_str), "added for warranty portal");
