--BT1
create database AAA_22520115

create table sinhvien(
	mssv char(5),
	ten varchar(30)
)

insert into sinhvien values ('22520','giabao');

BACKUP DATABASE[AAA_22520115]
TO DISK = 'D:\project\SQL\Microsoft_sql\AAA_22520115.bak'
WITH FORMAT,
NAME = 'Full Backup of AAA_22520115';

USE master;
ALTER DATABASE AAA_22520115 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE AAA_22520115;

RESTORE DATABASE [AAA_22520115] 
FROM DISK = 'D:\project\SQL\Microsoft_sql\AAA_22520115.bak' 
WITH NORECOVERY;

RESTORE DATABASE [AAA_22520115] 
FROM DISK = 'D:\project\SQL\Microsoft_sql\AAA_22520115.bak'
WITH RECOVERY;

use AAA_22520115
select * from sys.tables;
--BT2
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
--import dữ liệu
SELECT *
INTO YourTableName
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;Database=D:\project\SQL\SV.xls;HDR=YES;',
    'SELECT * FROM [Sheet1$]'
);

use QLGV
EXEC sp_addlinkedserver
    @server = 'ExcelData',
    @srvproduct = 'Excel',
    @provider = 'Microsoft.ACE.OLEDB.12.0',
    @datasrc = 'D:\project\SQL\SV.xlsx',
    @provstr = 'Excel 12.0;HDR=YES';
--BT3
CREATE LOGIN giabao22510115 WITH PASSWORD = 'giabao123';
CREATE LOGIN giabao22510116 WITH PASSWORD = 'giabao123';
CREATE LOGIN giabao22510117 WITH PASSWORD = 'giabao123';
CREATE LOGIN giabao22510118 WITH PASSWORD = 'giabao123';
CREATE LOGIN giabao22510119 WITH PASSWORD = 'giabao123';
CREATE LOGIN giabao22510110 WITH PASSWORD = 'giabao123';

create user u1 FOR LOGIN giabao22510115;
create user u2 FOR LOGIN giabao22510116;
create user u3 FOR LOGIN giabao22510117;
create user u4 FOR LOGIN giabao22510118;
create user u5 FOR LOGIN giabao22510119;
create user Giabao FOR LOGIN giabao22510110;

-- Tạo role r1
CREATE SERVER ROLE r1;

-- Tạo role r2
CREATE SERVER ROLE r2;

-- Tạo role r3
CREATE SERVER ROLE r3;


alter role r1 add member u1;

alter role r2 add member u2;
alter role r2 add member u3;

alter role r3 add member u4;
alter role r3 add member u5;
alter role r3 add member Giabao;

SELECT name
FROM sys.server_principals
WHERE type_desc = 'SERVER_ROLE' AND name = 'sysadmin';

SELECT name, type_desc
FROM sys.server_principals
WHERE name = 'giabao22520115';


--r1 la thanh vien sysadmin
ALTER SERVER ROLE sysadmin ADD MEMBER r1;
--r2 la thành viên của db_owner, db_accessadmin
use AAA_22520115
-- Thêm r2 vào db_owner
EXEC sp_addrolemember 'db_owner', 'r2';

-- Thêm r2 vào db_accessadmin
EXEC sp_addrolemember 'db_accessadmin', 'r2';

--r3 thành viên của SysAdmin, db_owner, db_accessadmin
ALTER SERVER ROLE sysadmin ADD MEMBER r3;

-- Thêm r3 vào db_owner (database-level role)
EXEC sp_addrolemember 'db_owner', 'r3';

-- Thêm r3 vào db_accessadmin (database-level role)
EXEC sp_addrolemember 'db_accessadmin', 'r3';
--phan quyen người dung
create table T1(
	mssv char(8)
)
create table T2(
	ten varchar(30)
)
create table T3(
	tuoi numeric
)

CREATE LOGIN loginu1 WITH PASSWORD = 'giabao123';
CREATE LOGIN loginu2 WITH PASSWORD = 'giabao123';
CREATE LOGIN loginu_giabao WITH PASSWORD = 'giabao123';

create user U1 FOR LOGIN loginu1;
create user U2 FOR LOGIN loginu2;
create user U_phamgiabao FOR LOGIN loginu_giabao;

-- Cấp quyền cho U1
GRANT SELECT, DELETE ON T1 TO U1;
GRANT SELECT, DELETE ON T3 TO U1;
-- Cấp quyền cho U2
GRANT UPDATE, DELETE ON T2 TO U2;
-- Cấp quyền cho U_phamgiabao
GRANT INSERT ON T1 TO U_phamgiabao;
GRANT INSERT ON T2 TO U_phamgiabao;
GRANT INSERT ON T3 TO U_phamgiabao;
-- Từ chối quyền INSERT cho U1 trên T1 và T2
DENY INSERT ON T1 TO U1;
DENY INSERT ON T2 TO U1;

-- Từ chối quyền DELETE cho U2 trên T3
DENY DELETE ON T3 TO U2;

--BT3
-- Tạo login cho GIANGVIEN
CREATE LOGIN GIANGVIEN WITH PASSWORD = 'giabao';

-- Tạo login cho GIAOVU
CREATE LOGIN GIAOVU WITH PASSWORD = 'giabao';

-- Tạo login cho SINHVIEN
CREATE LOGIN SINHVIEN WITH PASSWORD = 'giabao';

-- Tạo user cho GIANGVIEN
CREATE USER GIANGVIEN FOR LOGIN GIANGVIEN;

-- Tạo user cho GIAOVU
CREATE USER GIAOVU FOR LOGIN GIAOVU;

-- Tạo user cho SINHVIEN
CREATE USER SINHVIEN FOR LOGIN SINHVIEN;

-- Cấp quyền SELECT và UPDATE cho GIAOVU trên tất cả các bảng
GRANT SELECT, UPDATE ON DATABASE::AAA_22520115 TO GIAOVU;
-- Cấp quyền SELECT cho GIANGVIEN trên các bảng liên quan đến giảng viên
GRANT SELECT ON T1 TO GIANGVIEN;
GRANT SELECT ON T2 TO GIANGVIEN;
GRANT SELECT ON T3 TO GIANGVIEN;

-- Cấp quyền UPDATE cho GIANGVIEN trên thông tin cá nhân
GRANT UPDATE ON T1 TO GIANGVIEN;

-- Cấp quyền SELECT cho SINHVIEN trên các bảng liên quan đến sinh viên, hội đồng và đề tài
GRANT SELECT ON T1 TO SINHVIEN;
GRANT SELECT ON T2 TO SINHVIEN;
GRANT SELECT ON T3 TO SINHVIEN;

-- Từ chối quyền DELETE cho tất cả user
DENY DELETE ON DATABASE::AAA_22520115 TO GIAOVU;
DENY DELETE ON DATABASE::AAA_22520115 TO GIANGVIEN;
DENY DELETE ON DATABASE::AAA_22520115 TO SINHVIEN;

