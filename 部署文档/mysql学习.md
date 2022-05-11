# Mysql学习

## 一、数据库基本操作

### 1、登录

```shell
mysqld -uroot -p
```

###### 执行结果

```txt
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 7
Server version: 5.7.36-log MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

### 2、查询所有数据库

```shell
show databases;
```

##### 执行结果

```txt
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| mytest             |
| performance_schema |
| sxpt               |
| sys                |
| test               |              |
+--------------------+
7 rows in set (0.00 sec)
```

### 3、切换当前数据库

```shell
 use mytest;
```

##### 执行结果

```txt
mysql> use mytest;
Database changed
```

## 二、数据库类型相关

### 1、查询数据库版本

```shell
 SELECT version();
```

##### 执行结果

```txt
+------------+
| version()  |
+------------+
| 5.7.36-log |
+------------+
1 row in set (0.00 sec)
```

### 2、查询数据库类型

```shell
SHOW engines;
```

##### 执行结果

```txt
mysql> SHOW engines;
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                        | Transactions | XA   | Savepoints |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     | YES          | YES  | YES        |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          | NO           | NO   | NO         |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      | NO           | NO   | NO         |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                          | NO           | NO   | NO         |
| CSV                | YES     | CSV storage engine                                             | NO           | NO   | NO         |
| ARCHIVE            | YES     | Archive storage engine                                         | NO           | NO   | NO         |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                             | NO           | NO   | NO         |
| FEDERATED          | NO      | Federated MySQL storage engine                                 | NULL         | NULL | NULL       |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
9 rows in set (0.00 sec)
```

### 3、查询表的类型

```shell
SHOW CREATE table  config_user;
```

##### 执行结果

```txt
mysql> SHOW CREATE table  config_user;
+-------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Table       | Create Table                                                                                                                                                                                                                 |
+-------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| config_user | CREATE TABLE `config_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `nickname` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 |
+-------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```

### 4、查看表详情

```shell
DESC config_user;
```

##### 执行结果

```txt
mysql> DESC config_user;
+----------+-------------+------+-----+---------+----------------+
| Field    | Type        | Null | Key | Default | Extra          |
+----------+-------------+------+-----+---------+----------------+
| id       | int(11)     | NO   | PRI | NULL    | auto_increment |
| name     | varchar(50) | YES  |     | NULL    |                |
| nickname | varchar(50) | YES  |     | NULL    |                |
+----------+-------------+------+-----+---------+----------------+
3 rows in set (0.00 sec)
```

### 5、查询表当前状态

```shell
SHOW table status like 'config_user';
```

##### 执行结果

```txt
mysql> SHOW table status like 'config_user';
+-------------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------+
| Name        | Engine | Version | Row_format | Rows | Avg_row_length | Data_length | Max_data_length | Index_length | Data_free | Auto_increment | Create_time         | Update_time         | Check_time | Collation          | Checksum | Create_options | Comment |
+-------------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------+
| config_user | InnoDB |      10 | Dynamic    |    3 |           5461 |       16384 |               0 |            0 |         0 |              4 | 2022-03-17 13:57:46 | 2022-03-17 14:10:16 | NULL       | utf8mb4_general_ci |     NULL |                |         |
+-------------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+--------------------+----------+----------------+---------+
1 row in set (0.00 sec)
```

## 二、事务级别相关

### 1、查询数据库事务状态

```shell
SELECT @@tx_isolation;
```

##### 执行结果

```txt
mysql> SELECT @@tx_isolation;
+-----------------+
| @@tx_isolation  |
+-----------------+
| REPEATABLE-READ |
+-----------------+
1 row in set, 1 warning (0.00 sec)
```

### 2、修改事务隔离级别

#### 设置事务隔离级别

```shell
set session TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

#### 设置事务隔离级别

```shell
set session TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
```

#### 设置事务隔离级别(默认)

```shell
set session TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

#### 设置事务隔离级别

```shell
set session TRANSACTION ISOLATION LEVEL SERIALIZABLE ;
```

### 2、一个事务

#### 开始事务

```shell
START TRANSACTION;
```

#### 更新数据

```shell
update config_user set nickname="超级管理员" where name='admin';
```

#### 提交事务

```shell
 COMMIT;
```

#### 回滚事务

```shell
 ROLLBACK;
```
