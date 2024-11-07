USE QLDT

CREATE PROCEDURE DS_DETAI
AS
	SELECT * FROM DETAI

EXEC DS_DETAI

DROP PROCEDURE DS_DETAI

CREATE PROCEDURE DS_DETAI_DK @NAME NVARCHAR(30)
AS
	SELECT * FROM DETAI WHERE TENDT = @NAME 

EXEC DS_DETAI_DK N'Hệ giải toán thông minh'

--A. STORED PROCEDUREDS VỚI THAM SỐ VÀO
-- 1. Tham số vào là MSGV, TENGV, SODT, DIACHI, MSHH, NAMHH. Trước khi insert dữ liệu cần kiểm tra MSHH đã tồn tại trong table HOCHAM chưa, nếu chưa thì trả về giá trị 0.  
CREATE PROCEDURE KT_HH @MSGV INT, @TENGV NVARCHAR(30), @DIACHI NVARCHAR(50), @MSHH INT, @NAMHH SMALLDATETIME
AS
	IF EXISTS (SELECT MSHH FROM HOCHAM WHERE MSHH = @MSHH)
		BEGIN
			PRINT 'SUCCESS'
		END
	ELSE
		BEGIN
			PRINT N'ERROR: MSHH KHONG TON TAI'
			RETURN 0
		END

EXEC KT_HH '00201', N'Trần Trung', N'Bến Tre', '1', '1996';
--2. Tham số vào là MSGV, TENGV, SODT, DIACHI, MSHH, NAMHH. Trước khi insert dữ liệu cần kiểm tra MSGV trong table GIAOVIEN có trùng không, nếu trùng thì trả về giá trị 0.
CREATE PROCEDURE KT_MSGV @MSGV INT, @TENGV NVARCHAR(30), @DIACHI NVARCHAR(50), @MSHH INT, @NAMHH SMALLDATETIME
AS
	IF EXISTS (SELECT MSGV FROM GIAOVIEN WHERE MSGV = @MSGV)
		BEGIN
			PRINT N'ERROR: GIAO VIEN DA TON TAI'
			RETURN 0
		END
	ELSE
		BEGIN
			PRINT 'SUCCESS'
		END
EXEC KT_MSGV '00201', N'Trần Trung', N'Bến Tre', '1', '1996';
--3. Giống (1) và (2) kiểm tra xem MSGV có trùng không? MSHH có tồn tại chưa? Nếu MSGV trùng thì trả về 0. Nếu MSHH chưa tồn tại trả về 1, ngược lại cho insert dữ liệu.
CREATE PROCEDURE KT_GV_HH @MSGV INT, @TENGV NVARCHAR(30), @DIACHI NVARCHAR(50), @MSHH INT, @NAMHH SMALLDATETIME
AS
	EXEC KT_MSGV @MSGV,@TENGV,@DIACHI,@MSHH,@NAMHH;
	EXEC KT_HH @MSGV,@TENGV,@DIACHI,@MSHH,@NAMHH;
EXEC KT_GV_HH '00201', N'Trần Trung', N'Bến Tre', '1', '1996';
--4. Đưa vào MSDT cũ, TENDT mới. Hãy cập nhật tên đề tài mới với mã đề tài cũ không đổi nếu không tìm thấy trả về 0, ngược lại cập nhật và trả về 1.
CREATE PROCEDURE UP_NAMEDT @MSDTC CHAR(6), @TENDTN NVARCHAR(30)
AS
	IF EXISTS (SELECT * FROM DETAI WHERE MSDT = @MSDTC)
		BEGIN
			UPDATE DETAI
			SET TENDT = @TENDTN
			WHERE MSDT = @MSDTC
			PRINT 'SUCCESS'
			RETURN 1
		END
	ELSE
		BEGIN
			PRINT 'ERROR: KHONG TIM THAY MA DE TAI'
			RETURN 0
		END
EXEC UP_NAMEDT '97001', N'Quản lý thư viện'
--5. Tham số đưa vào MSSV, TENSV mới, DIACHI mới dùng để cập nhật sinh viên trên, nếu không tìm thấy trả về 0, ngược lại cập nhật và trả về 1.
CREATE PROCEDURE UP_SV @MSSV CHAR(8), @TENSV NVARCHAR(30), @DIACHI NCHAR(50)
AS
	IF EXISTS (SELECT * FROM SINHVIEN WHERE MSSV = @MSSV)
		BEGIN
			UPDATE SINHVIEN
			SET TENSV = @TENSV, DIACHI = @DIACHI
			WHERE MSSV = @MSSV
			PRINT 'SUCCESS'
			RETURN 1
		END
	ELSE
		BEGIN
			PRINT 'ERROR: KHONG TIM THAY MA SINH VIEN'
			RETURN 0
		END
--B. STORED PROCEDUREDS VỚI THAM SỐ VÀO VÀ RA
--1. Đưa vào TENHV trả ra: Số GV thỏa học vị, nếu không tìm thấy trả về 0.
CREATE PROCEDURE COUNT_GV_HV @TENHV NVARCHAR(20), @SOGV INT OUTPUT
AS
	SELECT @SOGV = COUNT(GIAOVIEN.MSGV)
	FROM HOCVI
	JOIN GV_HV_CN ON HOCVI.MSHV = GV_HV_CN.MSHV
	JOIN GIAOVIEN ON GIAOVIEN.MSGV = GV_HV_CN.MSGV
	WHERE TENHV = @TENHV
DECLARE @SOGV INT
EXEC COUNT_GV_HV N'Kỹ sư', @SOGV OUTPUT
PRINT @SOGV
--2. Đưa vào MSDT cho biết: Điểm trung bình của đề tài, nếu không tìm thấy trả về 0.
CREATE PROCEDURE AVG_DT @MSDT CHAR(6), @AVGDT FLOAT OUTPUT
AS
	SELECT @AVGDT = (GV_HDDT.DIEM+GV_PBDT.DIEM+GV_UVDT.DIEM)/3
	FROM GV_HDDT JOIN GV_PBDT ON GV_HDDT.MSDT = GV_PBDT.MSDT
	JOIN GV_UVDT ON GV_HDDT.MSDT = GV_UVDT.MSDT
	WHERE GV_HDDT.MSDT = @MSDT
DECLARE @AVGDT FLOAT
EXEC AVG_DT '97002', @AVGDT OUTPUT
PRINT @AVGDT
--3. Đưa vào TENGV trả ra: SDT của giáo viên đó, nếu không tìm thấy trả về 0. Nếu trùng tên thì có báo lỗi không? Tại sao? Làm sao để hiện thông báo có bao nhiêu giáo viên trùng tên và trả về các SDT. 
CREATE PROCEDURE 
--4. Đưa vào MSHD cho biết: Điểm trung bình các đề tài của hội đồng đó.
--5*. Đưa vào TENGV cho biết: Số đề tài hướng dẫn, số đề tài phản biện do giáo viên đó phụ trách. Nếu trùng tên thì có báo lỗi không hay hệ thống sẽ đếm tất cả các đề tài của những giáo viên trùng tên đó?
--C. TRIGGER
SELECT COUNT(MSDT)
FROM HOIDONG_DT
WHERE MSHD = 1
--D. FUNCTION
CREATE FUNCTION CONG(@N INT) RETURN INT
AS
	BEGIN
		IF ( @N > 0)
			BEGIN 
				RETURN @N + CONG(@N-1)
			END
		ELSE
			BEGIN
				RETURN 0
			END
	END
	SELECT COUNT(GIAOVIEN.MSGV)
	FROM HOCVI
	JOIN GV_HV_CN ON HOCVI.MSHV = GV_HV_CN.MSHV
	JOIN GIAOVIEN ON GIAOVIEN.MSGV = GV_HV_CN.MSGV
	WHERE TENHV = N'Kỹ sư'