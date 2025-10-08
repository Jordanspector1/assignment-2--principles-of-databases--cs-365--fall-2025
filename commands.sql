-- Commands for the assignment
USE passwords;


-- matching the setup.sql encryption settings
SET block_encryption_mode = "aes-256-ecb";
SET @key_str = UNHEX(SHA2("My awesome passphrase", 256));


-- 1. add a new site (Stack Overflow) and give jspector a credential for it
INSERT IGNORE INTO site (siteName, url)
VALUES ("Stack Overflow","https://stackoverflow.com");

INSERT INTO credential (userId, siteId, passwordCipher, comment)
SELECT u.userId, s.siteId,
       AES_ENCRYPT("SoJS_New_F25!11", @key_str),
       "added via commands.sql (new site)"
FROM userAccount u
JOIN site s ON s.url = "https://stackoverflow.com"
WHERE u.username = "jspector";


-- 2. Decrypt and show jspector’s password
SELECT CAST(AES_DECRYPT(c.passwordCipher, @key_str) AS CHAR) AS 'Plain Text Password'
FROM credential c
JOIN userAccount u ON c.userId = u.userId
JOIN site s         ON c.siteId = s.siteId
WHERE s.url = "https://github.com" AND u.username = "jspector";


-- 3. Show all of Jspectors credentials for black board and Asus by joining all 3 tables and decrypting
SELECT u.firstName,
       u.lastName,
       u.username,
       u.email,
       s.siteName,
       s.url,
       c.comment,
       c.createdAt,
       CAST(AES_DECRYPT(c.passwordCipher, @key_str) AS CHAR) AS 'Plain Text Password'
FROM credential c
JOIN userAccount u ON c.userId = u.userId
JOIN site s         ON c.siteId = s.siteId
WHERE s.url IN ("https://blackboard.hartford.edu/ultra/stream","https://www.asus.com")
  AND u.username = "jspector";


-- 4. Change Hartford’s url to use https instead of http
UPDATE site
SET url = "https://hartford.edu"
WHERE url = "http://hartford.edu";


-- 5. Rotate mstein’s Mecha Ramen password and then change comment to "password rotated" by joining all 3 tables
UPDATE credential c
JOIN userAccount u ON c.userId = u.userId AND u.username = "mstein"
JOIN site s ON c.siteId = s.siteId AND s.url = "https://mecharamen.com"
SET c.passwordCipher = AES_ENCRYPT("MrMS_Rotated_F25!99", @key_str),
    c.comment        = "password rotated";


-- 6. remove jspectors Github credential by joining through site.url and deleting the matching row from credential
DELETE c
FROM credential c
JOIN site s ON c.siteId = s.siteId
JOIN userAccount u ON u.userId = c.userId
WHERE s.url = "https://github.com" AND u.username = "jspector";


-- 7. Remove mstein Mecha Ramen credential by matching the decrypted password text in the WHERE clause below
DELETE c
FROM credential c
JOIN userAccount u ON u.userId = c.userId AND u.username = "mstein"
JOIN site s ON s.siteId = c.siteId AND s.url = "https://mecharamen.com"
WHERE CAST(AES_DECRYPT(c.passwordCipher, @key_str) AS CHAR) = "MrMS_Rotated_F25!99";
