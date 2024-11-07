Create database BAITHI

use BAITHI
set dateformat DMY 

create table HOASI
(
	MAHS char(5) not null,
	TENHS varchar(40),
	PHONGCACH varchar(40),
	NAMSINH int
)
alter table HOASI add constraint pk_HS primary key (MAHS)

create table TRANH(
	MATRANH char(4) not null,
	MAHS char(5),
	TENTRANH varchar(50),
	LOAITRANH varchar(40),
	NAMVE int,
	GIAUT int
)
alter table TRANH add constraint pk_T primary key (MATRANH)
alter table TRANH add constraint fk_T foreign key (MAHS) references HOASI(MAHS)

create table BUOIDAUGIA(
	MABDG char(4) not null,
	TENCHUDE varchar(40),
	TGBD smalldatetime,
	DVTC varchar(40)
)
alter table BUOIDAUGIA add constraint pk_BDG primary key (MABDG)

create table KETQUA
(
	MABDG char(4) not null,
	MATRANH char(4) not null,
	GIABAN money,
	TENKH varchar(40)
)
alter table KETQUA add constraint fk_KQ_T foreign key (MATRANH) references TRANH(MATRANH)
alter table KETQUA add constraint fk_KQ_BDG foreign key (MABDG) references BUOIDAUGIA(MABDG)
alter table KETQUA add constraint pk_KQ primary key (MABDG, MATRANH)
-- cau 2
insert into HOASI values ('HS001 ','Nguyen Minh Son ','Truu tuong ','1876')
insert into HOASI values ('HS002 ','Max Pechstein ','Bieu hien ','1881')
insert into HOASI values ('HS003 ','Monet ','An tuong ','1840')

insert into TRANH values ('T001 ','HS001 ','Truu tuong hoa ','Son acrylic ','2019','45')
insert into TRANH values ('T002 ','HS002 ','Ben cang Leba ','Son dau ','1922','80')
insert into TRANH values ('T003 ','HS002 ','Summer in ','Son dau ','1921','50')

insert into BUOIDAUGIA values ('B001 ','Truu tuong Viet Nam ','15/02/2023 13:00:00 ','The gioi hoi hoa ')
insert into BUOIDAUGIA values ('B002 ','Pechstein Collection ','17/04/2023 09:00:00 ','The gioi hoi hoa ')
insert into BUOIDAUGIA values ('B003 ','Monet Expression ','15/06/2023 19:00:00 ','Vanvi ')

insert into KETQUA values ('B001 ','T001 ','50','Ho Van Hue ')
insert into KETQUA values ('B002 ','T002 ','100','Cao Huu Cau ')
insert into KETQUA values ('B002 ','T003 ','90','Nguyen Thi Nhung ')

--cau 3
alter table BUOIDAUGIA add constraint ck_dvtc_tgbd check ((DVTC = 'Vanvi' and year(TGBD) >= 2022) or (DVTC <> 'Vanvi'))
--cau 4
select MATRANH , TENTRANH
from TRANH T1
join KETQUA 
on KETQUA.MATRANH = TRANH.MATRANH
where (GIABAN < all(select GIABAN from KETQUA T2 join TRANH
				on KETQUA.MATRANH = TRANH.MATRANH
				where T1.MATRANH = T2.MATRANH))
				and GIABAN < GIAUT
