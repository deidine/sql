--% for all ipadress
  CREATE USER 'deidine'@'%' IDENTIFIED BY 'deidine';
 GRANT ALL PRIVILEGES ON * . * TO  'deidine'@'%';
 FLUSH PRIVILEGES;
 DROP USER 'deidine'@'localhost';
 select user from MySQl.user;--show  users
 mysql -u root -p    --create shell with mysql -u user name -p passord

--mysqli_connect("192.168.43.24","deidine","deidine","hospital");
