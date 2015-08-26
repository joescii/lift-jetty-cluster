create database lift_sessions;
create user 'jetty'@'localhost' identified by 'lift-rocks';
grant all on lift_sessions.* TO 'jetty'@'localhost';
