Create database BAITHI

use BAITHI
set dateformat DMY 

create table NHASANXUAT
(
	MANSX char(6) not null,
	TENNSX varchar(40),
	NUOC varchar(40),
	NAMTL int
)
alter table NHASANXUAT add constraint pk_NSX primary key (MANSX)

create table GUITAR(
	MADAN char(6) not null,
	MANSX char(6),
	TENDAN varchar(40),
	DANG varchar(40),
	LOAIDAN varchar(40),
	MATTOP varchar(40),
	BACK varchar(40),
	GIA int
)
alter table GUITAR add constraint pk_G primary key (MADAN)
alter table GUITAR add constraint fk_G foreign key (MANSX) references NHASANXUAT(MANSX)

create table PHIEUNHAP(
	MAPN char(5) not null,
	MANSX char(6),
	TRIGIA int,
	NGNHAP smalldatetime
)
alter table PHIEUNHAP add constraint pk_PN primary key (MAPN)
alter table PHIEUNHAP add constraint fk_PN foreign key (MANSX) references NHASANXUAT(MANSX)

create table CTPN
(
	MAPN char(5) not null,
	MADAN char(6) not null,
	SL int
)
alter table CTPN add constraint fk_CTPN_PN foreign key (MAPN) references PHIEUNHAP(MAPN)
alter table CTPN add constraint fk_CTPN_GUITAR foreign key (MADAN) references GUITAR(MADAN)
alter table CTPN add constraint pk_CTPN primary key (MAPN, MADAN)
-- cau 2
insert into NHASANXUAT values ('NSX001 ', 'Fender ','Mi ','1946')
insert into NHASANXUAT values ('NSX002 ', 'Suzuki ','Nhat ','1886')
insert into NHASANXUAT values ('NSX003 ', 'Takamine ','Nhat ','1959')

insert into GUITAR values ('DAN001 ', 'NSX001 ','CD-60S ','Dreadnought ','Acoustic ','Spruce ',' Layered Koa ','6')
insert into GUITAR values ('DAN002 ', 'NSX001 ','CD-140SCE','D khuyet ','Acoustic ','Spruce ','Sapele ','10')
insert into GUITAR values ('DAN003 ', 'NSX002 ','C40M ','D ','Classic ','Van sam ','Meranti ','5')

insert into PHIEUNHAP values ('PN001 ', 'NSX001 ','44','15/06/2023 ')
insert into PHIEUNHAP values ('PN002 ', 'NSX002 ','5','16/07/2023 ')
insert into PHIEUNHAP values ('PN003 ', 'NSX003 ','20','13/09/2023 ')

insert into CTPN values ('PN001 ', 'DAN001 ','4')
insert into CTPN values ('PN002 ', 'DAN002 ','2')
insert into CTPN values ('PN003 ', 'DAN003 ','1')

--cau 3
alter table GUITAR add constraint ck_guitar_loaidan check ((LOAIDAN = 'mini' and TENDAN like 'mini' and MATTOP <> 'Thong') or (LOAIDAN <> 'mini'))
--cau 4
--create trigger trg_pn_nsx
--()
--cau 5
select PHIEUNHAP.MAPN, NGNHAP
from PHIEUNHAP
join NHASANXUAT
on NHASANXUAT.MANSX = PHIEUNHAP.MANSX
where (NGNHAP between '01/06/2023' and '30/06/2023') and TENNSX = 'Yamaha' 
group by NGNHAP desc
--cau 6
select DANG
from GUITAR
join CTPN on GUITAR.MADAN = CTPN.MADAN
join PHIEUNHAP on PHIEUNHAP.MAPN = CTPN.MAPN
where year(NGNHAP) = '2023' and SL < all (select SL from CTPN)
--cau7
select MADAN, TENDAN
from GUITAR
join NHASANXUAT on NHASANXUAT.MANSX = GUITAR.MANSX
join PHIEUNHAP on PHIEUNHAP.MANSX = NHASANXUAT.MANSX
where TENNSX = 'Taylor' and BACK = 'Spruce' and (NGNHAP between '01/03/2023' and '31/03/2023')
--cau 8
select MAPN
from PHIEUNHAP
where year(NGNHAP) = '2022' and MANSX = all(select MANSX 
										from NHASANXUAT
										where NUOC ='Mi')
select MAPN
from PHIEUNHAP 
intersect
select MAPN
from NHASANXUAT NSX join PHIEUNHAP PN on NSX.MANSX = PN.MANSX