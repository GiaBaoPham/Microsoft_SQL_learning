CREATE DATABASE BAITHI01
USE BAITHI01

CREATE TABLE KHACHHANG
(
	MAKH CHAR(5) NOT NULL,
	TENKH VARCHAR(20),
	NGSINH SMALLDATETIME,
	GIOITINH CHAR(4)
)

ALTER TABLE KHACHHANG ADD CONSTRAINT PK_KH PRIMARY KEY (MAKH) 

CREATE TABLE DONGXE
(
	MADONG CHAR(4) NOT NULL,
	HANG VARCHAR(20),
	TENDONG VARCHAR(20),
	LOAIPIN VARCHAR(20),
	NGRAMAT SMALLDATETIME,
	SOCHO INT
)

ALTER TABLE DONGXE ADD CONSTRAINT PK_DX PRIMARY KEY (MADONG)

CREATE TABLE TRUSAC
(
	MATS CHAR(5) NOT NULL,
	HANGXE VARCHAR(20),
	CONGSUAT DECIMAL(8, 2),
	LOAIXE VARCHAR(10),
	SLDR INT,
	KHUVUC VARCHAR(20),
	DIACHI VARCHAR(40)
)

ALTER TABLE TRUSAC ALTER COLUMN DIACHI VARCHAR(60)
ALTER TABLE TRUSAC ADD CONSTRAINT PK_TS PRIMARY KEY (MATS)

CREATE TABLE XE
(
	MAXE CHAR(4) NOT NULL,
	MADONG CHAR(4),
	MAKH CHAR(5),
	BIENSO VARCHAR(20),
	NGMUA SMALLDATETIME
)

ALTER TABLE XE ADD CONSTRAINT PK_XE PRIMARY KEY (MAXE)
ALTER TABLE XE ALTER COLUMN MAKH CHAR(5)
ALTER TABLE XE ALTER COLUMN MADONG CHAR(4)
ALTER TABLE XE ADD CONSTRAINT FK_XE_KH FOREIGN KEY (MAKH) REFERENCES KHACHHANG(MAKH)
ALTER TABLE XE ADD CONSTRAINT FK_XE_DX FOREIGN KEY (MADONG) REFERENCES DONGXE(MADONG)

CREATE TABLE LICHSUSAC
(
	MALS CHAR(4) NOT NULL,
	MAXE CHAR(4),
	MATS CHAR(5),
	TGBD SMALLDATETIME,
	TGKT SMALLDATETIME
)

ALTER TABLE LICHSUSAC ADD CONSTRAINT PK_LSS PRIMARY KEY (MALS)
ALTER TABLE LICHSUSAC ADD CONSTRAINT FK_LSS_XE FOREIGN KEY (MAXE) REFERENCES XE(MAXE)
ALTER TABLE LICHSUSAC ADD CONSTRAINT FK_LSS_TS FOREIGN KEY (MATS) REFERENCES TRUSAC(MATS)
--NHAP DU LIEU KHACHHANG
INSERT INTO KHACHHANG VALUES ('KH001', 'Huynh Man Dat', '1999/04/20', 'Nam')
INSERT INTO KHACHHANG VALUES ('KH002', 'Nguyen Hong Loan', '1989/08/13', 'Nu')
INSERT INTO KHACHHANG VALUES ('KH003', 'Ho Van Hue', '1997/03/12', 'Nam')
--NHAP DU LIEU DONGXE
INSERT INTO DONGXE VALUES ('D001', 'VinFast', 'Klara S', 'Lithium-ion', '2019/12/26', 2)
INSERT INTO DONGXE VALUES ('D002', 'Dat bike', 'Weaver 200', 'Lithium-ion', '2021/11/27', 2)
INSERT INTO DONGXE VALUES ('D003', 'VinFast', 'VF e34', 'Lithium-ion', '2021/10/15', 4)
-- NHAP DU LIEU TRUSAC
INSERT INTO TRUSAC VALUES ('TS001', 'Dat bike', 7, 'xe may', 2, 'cong cong', '273 Dien Bien Phu, Quan 3, TP. HCM')
INSERT INTO TRUSAC VALUES ('TS002', 'VinFast', 1.2, 'xe may', 4, 'trung tam thuong mai', '3 Thang 2, P.11, Quan 10, TP. HCM')
INSERT INTO TRUSAC VALUES ('TS003', 'VinFast', 60, 'o to', 2, 'chung cu', '18 Phan Van Tri, Phuong 10, quan go vap, TP. HCM')
--NHAP DU LIEU XE
INSERT INTO XE VALUES ('X001', 'D001', 'KH001','49-T1 062.95', '2022/02/20')
INSERT INTO XE VALUES ('X002', 'D002', 'KH002','15V 123.45', '2022/03/19')
INSERT INTO XE VALUES ('X003', 'D003', 'KH003','50-T2 011.14', '2022/02/13')
--3 RBTV
ALTER TABLE TRUSAC ADD CONSTRAINT CK_TS_CS CHECK ((LOAIXE = 'o to'  AND CONGSUAT > 60 AND KHUVUC <> 'chung xu') OR (LOAIXE = 'o to'  AND CONGSUAT <= 60) OR (LOAIXE <> 'o to'))
--4 RBTV
GO
CREATE TRIGGER TRG_LSS_IN_UP ON LICHSUSAC
FOR INSERT, UPDATE
AS
BEGIN 
	IF EXISTS (SELECT * FROM INSERTED T
		JOIN XE	X ON T.MAXE = X.MAXE 
		JOIN TRUSAC TS on TS.MATS = T.MATS
		WHERE YEAR(NGMUA) < 2021 AND CONGSUAT > 60)
	BEGIN
		PRINT 'ERROR: NGMUA < 2021 SE KHONG DUOC SAC CONG SUAT > 60'
		ROLLBACK TRAN
	END
	ELSE
	BEGIN 
		PRINT 'LICHSUSAC DA DUOC CAP NHAT THANH CONG'
	END
END


drop trigger TRG_LSS_IN_UP
--5 truy van
SELECT KHACHHANG.MAKH, TENKH
FROM KHACHHANG
JOIN XE ON KHACHHANG.MAKH = XE.MAKH
JOIN LICHSUSAC ON XE.MAXE = LICHSUSAC.MAXE
JOIN TRUSAC ON LICHSUSAC.MATS = TRUSAC.MATS
WHERE HANGXE = 'VinFast' AND KHUVUC = 'cao toc' AND YEAR(TGBD) = 2022
--6 TRUY VAN
