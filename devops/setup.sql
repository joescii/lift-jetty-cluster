create database lift_sessions;
create user 'jetty'@'10.0.%' identified by 'lift-rocks';
grant all on lift_sessions.* TO 'jetty'@'10.0.%';
USE lift_sessions;
DROP PROCEDURE IF EXISTS initConnect;
DELIMITER //
CREATE DEFINER = CURRENT_USER PROCEDURE `initConnect`()
IF NOT (POSITION('rdsadmin@' IN CURRENT_USER()) = 1) THEN     
  SET NAMES 'utf8mb4' COLLATE 'utf8mb4_general_ci';
END IF;
//
DELIMITER ;