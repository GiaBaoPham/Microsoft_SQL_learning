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
EXEC UP_SV '13520002', N'Phan Tấn Đạt', N'QUẬN 1'
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
CREATE PROCEDURE SDT_GV @TENGV NVARCHAR(30), @SODT VARCHAR(10) OUTPUT
AS
	DECLARE @COUNT INT
	SELECT @COUNT = COUNT(*)
	FROM GIAOVIEN
	WHERE TENGV = @TENGV

	IF @COUNT = 0
		BEGIN
			SET @SODT = '0'
		END
	ELSE IF @COUNT > 1
		BEGIN
			PRINT 'CO' + CAST(@COUNT AS NVARCHAR) + ' GIAO VIEN TRUNG TEN' + @TENGV;

			DECLARE @SDT VARCHAR(10)
			DECLARE CUR CURSOR FOR 
				SELECT SODT
				FROM GIAOVIEN
				WHERE TENGV = @TENGV

			OPEN CUR
			FETCH NEXT FROM CUR INTO @SDT
			WHILE @@FETCH_STATUS = 0
				BEGIN
					PRINT 'SODT: ' + @SDT
					FETCH NEXT FROM CUR INTO @SDT
				END
			CLOSE CUR
			DEALLOCATE CUR

			SET @SODT = 'NHIEU GV TRUNG TEN'
		END
	ELSE
		BEGIN
			SELECT @SODT = SODT
			FROM GIAOVIEN
			WHERE TENGV = @TENGV
		END
DECLARE @SODT VARCHAR(10)
EXEC SDT_GV N'Nguyễn Văn An', @SODT OUTPUT
PRINT @SODT
--4. Đưa vào MSHD cho biết: Điểm trung bình các đề tài của hội đồng đó.
CREATE PROCEDURE AVG_DT_HD @MSHD CHAR(6), @AVG FLOAT OUTPUT
AS
	DECLARE @SUMAVG FLOAT
	DECLARE @COUNT INT
	SELECT @SUMAVG = SUM(GV_HDDT.DIEM+GV_PBDT.DIEM+GV_UVDT.DIEM)/3, @COUNT = COUNT(GV_PBDT.MSDT)
	FROM HOIDONG_DT A
	JOIN GV_PBDT ON A.MSDT = GV_PBDT.MSDT
	JOIN GV_UVDT ON A.MSDT = GV_UVDT.MSDT
	JOIN GV_HDDT ON A.MSDT = GV_HDDT.MSDT
	WHERE A.MSHD = @MSHD
	SET @AVG = @SUMAVG/@COUNT
DECLARE @AVG FLOAT
EXEC AVG_DT_HD '1', @AVG OUTPUT
PRINT @AVG
--5*. Đưa vào TENGV cho biết: Số đề tài hướng dẫn, số đề tài phản biện do giáo viên đó phụ trách. Nếu trùng tên thì có báo lỗi không hay hệ thống sẽ đếm tất cả các đề tài của những giáo viên trùng tên đó?
CREATE PROCEDURE SDT_HD_PB @TENGV NVARCHAR(30), @SODTHD INT OUTPUT, @SODTPB INT OUTPUT
AS
	DECLARE @COUNT INT
	SELECT @COUNT = COUNT(*)
	FROM GIAOVIEN
	WHERE TENGV = @TENGV

	IF @COUNT > 1
		BEGIN
			PRINT 'CO' + CAST(@COUNT AS NVARCHAR) + ' GIAO VIEN TRUNG TEN' + @TENGV;

			DECLARE @COUNTHD INT
			DECLARE @COUNTPB INT
			DECLARE CUR1 CURSOR FOR 
				SELECT COUNT(GV_HDDT.MSDT)
				FROM GIAOVIEN A
				JOIN GV_HDDT ON A.MSGV = GV_HDDT.MSGV
				JOIN GV_PBDT ON A.MSGV = GV_PBDT.MSGV
				WHERE TENGV = @TENGV

			OPEN CUR1
			FETCH NEXT FROM CUR1 INTO @COUNTHD 
			WHILE @@FETCH_STATUS = 0
				BEGIN
					PRINT 'COUNTHD: ' + @COUNTHD
					FETCH NEXT FROM CUR INTO @COUNTHD
				END
			CLOSE CUR1
			DEALLOCATE CUR1
			SET @SODTHD = 'NHIEU GV TRUNG TEN'

			DECLARE CUR2 CURSOR FOR 
				SELECT COUNT(GV_PBDT.MSDT)
				FROM GIAOVIEN A
				JOIN GV_HDDT ON A.MSGV = GV_HDDT.MSGV
				JOIN GV_PBDT ON A.MSGV = GV_PBDT.MSGV
				WHERE TENGV = @TENGV

			OPEN CUR2
			FETCH NEXT FROM CUR2 INTO @COUNTPB 
			WHILE @@FETCH_STATUS = 0
				BEGIN
					PRINT 'COUNTPB: ' + @COUNTPB
					FETCH NEXT FROM CUR2 INTO @COUNTPB
				END
			CLOSE CUR2
			DEALLOCATE CUR2
			SET @COUNTPB = 'NHIEU GV TRUNG TEN'
		END
	ELSE
		BEGIN
			SELECT @SODTHD = COUNT(GV_HDDT.MSDT), @SODTPB = COUNT(GV_PBDT.MSDT)
			FROM GIAOVIEN A
			JOIN GV_HDDT ON A.MSGV = GV_HDDT.MSGV
			JOIN GV_PBDT ON A.MSGV = GV_PBDT.MSGV
			WHERE TENGV = @TENGV
		END
DECLARE @SODTHD INT
DECLARE @SODTPB INT
EXEC SDT_HD_PB N'Nguyễn Văn An', @SODTHD OUTPUT, @SODTPB OUTPUT
PRINT @SODTHD
PRINT @SODTPB
--C. TRIGGER
--1. Tạo Trigger thỏa mãn điều kiện khi xóa một đề tài sẽ xóa các thông tin liên quan.
CREATE TRIGGER DEL_DT ON DETAI FOR DELETE
AS
	BEGIN 
		IF EXISTS(SELECT * FROM DELETED A WHERE A.MSDT IN (SELECT MSDT FROM SV_DETAI))
			BEGIN
				PRINT 'ERROR: CHUA XOA DE TAI O BANG SV_DETAI'
				ROLLBACK TRAN
			END
		ELSE
			BEGIN
				IF EXISTS(SELECT * FROM inserted A WHERE A.MSDT IN (SELECT MSDT FROM GV_HDDT))
					BEGIN
						PRINT 'ERROR: CHUA XOA DE TAI O BANG GV_HDDT'
						ROLLBACK TRAN
					END
				ELSE
					BEGIN
						IF EXISTS(SELECT * FROM inserted A WHERE A.MSDT IN (SELECT MSDT FROM GV_PBDT))
							BEGIN
								PRINT 'ERROR: CHUA XOA DE TAI O BANG GV_PBDT'
								ROLLBACK TRAN
							END
						ELSE
							BEGIN
								IF EXISTS(SELECT * FROM inserted A WHERE A.MSDT IN (SELECT MSDT FROM GV_UVDT))
									BEGIN
										PRINT 'ERROR: CHUA XOA DE TAI O BANG GV_UVDT'
										ROLLBACK TRAN
									END
								ELSE
									BEGIN
										IF EXISTS(SELECT * FROM inserted A WHERE A.MSDT IN (SELECT MSDT FROM HOIDONG_DT))
											BEGIN
												PRINT 'ERROR: CHUA XOA DE TAI O BANG HOIDONG_DT'
												ROLLBACK TRAN
											END
										ELSE
											BEGIN
												PRINT 'DELETE THANH CONG'
											END
									END
							END
					END
			END
	END
--2. Tạo Trigger thỏa mãn ràng buộc là một hội đồng không quá 5 đề tài. Dùng “Group by” có được không? Giải thích.
CREATE TRIGGER HD_5DT ON HOIDONG_DT FOR INSERT, UPDATE
AS
	BEGIN
		IF (SELECT COUNT(MSDT) FROM HOIDONG_DT A WHERE A.MSHD = (SELECT MSHD FROM inserted)) > 5
			BEGIN
				PRINT 'ERROR: SO LUONG DE TAI KHONG THE CUOT QUA 5'
				ROLLBACK TRAN
			END
		ELSE
			BEGIN
				PRINT 'INSERT/UPDATE THANH CONG'
			END
	END
--3. Tạo Trigger thỏa mãn ràng buộc là một đề tài không quá 3 sinh viên. Dùng “Group by” có được không? Giải thích.
CREATE TRIGGER DT_3SV ON SV_DETAI FOR INSERT, UPDATE
AS
	BEGIN 
		IF (SELECT COUNT(MSSV) FROM SV_DETAI A WHERE A.MSDT = (SELECT MSDT FROM inserted)) > 3
			BEGIN
				PRINT 'ERROR: SO LUONG SINH VIEN CUA 1 DE TAI KHONG THE VUOT QUA 3'
				ROLLBACK TRAN
			END
		ELSE
			BEGIN
				PRINT 'INSERT/UPDATE THANH CONG'
			END
	END
--4. Tạo Trigger thỏa mãn ràng buộc là một giáo viên muốn có học hàm PGS phải là tiến sĩ.
CREATE TRIGGER GV_HH_HV ON GIAOVIEN FOR INSERT, UPDATE
AS
	BEGIN
		IF (SELECT MSHV FROM inserted A JOIN GV_HV_CN ON A.MSGV = GV_HV_CN.MSGV WHERE MSHH = 1) != 4
			BEGIN
				PRINT 'ERROR: MUON TRO THANH PGS THI PHAI TRO THANH TIEN SI'
				ROLLBACK TRAN
			END
		ELSE
			BEGIN
				PRINT 'INSERT/UPDATE THANH CONG'
			END
	END
--D. FUNCTION
--1. Viết hàm tính điểm trung bình của một đề tài. Giá trị trả về là điểm trung bình ứng với mã số đề tài nhập vào.
CREATE FUNCTION TINHAVG(@MSDT CHAR(6)) RETURNS FLOAT
AS
	BEGIN
		DECLARE @AVGDT FLOAT
		SELECT @AVGDT = (GV_HDDT.DIEM+GV_PBDT.DIEM+GV_UVDT.DIEM)/3
		FROM GV_HDDT JOIN GV_PBDT ON GV_HDDT.MSDT = GV_PBDT.MSDT
		JOIN GV_UVDT ON GV_HDDT.MSDT = GV_UVDT.MSDT
		WHERE GV_HDDT.MSDT = @MSDT
		RETURN @AVGDT
	END
SELECT DBO.TINHAVG(97001) AS KQ
--2. Trả về kết quả của đề tài theo MSDT nhập vào. Kết quả là DAT nếu như điểm trung bình từ 5 trở lên, và KHONGDAT nếu như điểm trung bình dưới 5.
CREATE FUNCTION KQDT(@MSDT CHAR(6)) RETURNS NVARCHAR(10)
AS
	BEGIN
		DECLARE @KQ NVARCHAR(10)
		DECLARE @AVGDT FLOAT
		SELECT @AVGDT = (GV_HDDT.DIEM+GV_PBDT.DIEM+GV_UVDT.DIEM)/3
		FROM GV_HDDT JOIN GV_PBDT ON GV_HDDT.MSDT = GV_PBDT.MSDT
					JOIN GV_UVDT ON GV_HDDT.MSDT = GV_UVDT.MSDT
		WHERE GV_HDDT.MSDT = @MSDT
		IF @AVGDT >= 5
			BEGIN
				SET @KQ = 'DAT'
			END
		ELSE
			BEGIN
				SET @KQ = 'KHONG DAT'
			END
		RETURN @KQ
	END
SELECT DBO.KQDT(97001) AS KQ		
--3*. Đưa vào MSDT, trả về mã số và họ tên của các sinh viên thực hiện đề tài.
CREATE FUNCTION DSSVTHDT(@MSDT CHAR(6)) RETURNS @NEW_TABLE TABLE (MSSV CHAR(8), HOVATEN NVARCHAR(30))
AS
	BEGIN
		INSERT INTO @NEW_TABLE
		SELECT SINHVIEN.MSSV, TENSV FROM SINHVIEN JOIN SV_DETAI ON SINHVIEN.MSSV = SV_DETAI.MSSV WHERE MSDT = @MSDT
		RETURN
	END
SELECT * FROM DBO.DSSVTHDT(97001)
--E. CURSOR
CREATE TABLE DETAI_DIEM(
	MSDT CHAR(6),
	DIEMTB FLOAT
)
ALTER TABLE DETAI_DIEM ADD CONSTRAINT FK_DT_DIEM FOREIGN KEY (MSDT) REFERENCES DETAI(MSDT)
--1. Viết Cursor tính điểm trung bình cho từng đề tài. Sau đó lưu kết quả vào bảng DETAI_DIEM
DECLARE @MSDT CHAR(6);              -- Biến để lưu mã số đề tài
DECLARE @AVGDT FLOAT;               -- Biến để lưu điểm trung bình

-- Khai báo con trỏ
DECLARE diem_cursor CURSOR FOR
SELECT DISTINCT MSDT
FROM SV_DETAI; -- Lấy danh sách mã số đề tài duy nhất

-- Mở con trỏ
OPEN diem_cursor;

-- Lấy từng mã số đề tài
FETCH NEXT FROM diem_cursor INTO @MSDT;

-- Vòng lặp qua từng đề tài
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Tính điểm trung bình cho đề tài hiện tại
    SELECT @AVGDT = (ISNULL(GV_HDDT.DIEM, 0) + ISNULL(GV_PBDT.DIEM, 0) + ISNULL(GV_UVDT.DIEM, 0)) / 3
    FROM GV_HDDT
    JOIN GV_PBDT ON GV_HDDT.MSDT = GV_PBDT.MSDT
    JOIN GV_UVDT ON GV_HDDT.MSDT = GV_UVDT.MSDT
    WHERE GV_HDDT.MSDT = @MSDT;

    -- Kiểm tra nếu đã tồn tại mã số đề tài trong bảng DETAI_DIEM
    IF EXISTS (SELECT 1 FROM DETAI_DIEM WHERE MSDT = @MSDT)
    BEGIN
        UPDATE DETAI_DIEM
        SET DIEMTB = @AVGDT
        WHERE MSDT = @MSDT;
    END
    ELSE
    BEGIN
        -- Thêm kết quả vào bảng DETAI_DIEM
        INSERT INTO DETAI_DIEM (MSDT, DIEMTB)
        VALUES (@MSDT, @AVGDT);
    END

    -- Lấy mã số đề tài tiếp theo
    FETCH NEXT FROM diem_cursor INTO @MSDT;
END

-- Đóng và giải phóng con trỏ
CLOSE diem_cursor;
DEALLOCATE diem_cursor;
--2. Gom các bước xử lý của Cursor ở câu 1 vào một Stored Procedure
CREATE PROCEDURE SP_TINH_DIEMTB_DETAI
AS
BEGIN
    -- Biến tạm để lưu trữ mã số đề tài và điểm trung bình
    DECLARE @MSDT CHAR(6)              
    DECLARE @AVGDT FLOAT               

    -- Khai báo con trỏ
    DECLARE diem_cursor CURSOR FOR
    SELECT DISTINCT MSDT
    FROM SV_DETAI; -- Lấy danh sách mã số đề tài duy nhất từ bảng SV_DETAI

    -- Mở con trỏ
    OPEN diem_cursor

    -- Lấy từng mã số đề tài
    FETCH NEXT FROM diem_cursor INTO @MSDT;

    -- Vòng lặp qua từng đề tài
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Tính điểm trung bình cho đề tài hiện tại
        SELECT @AVGDT = (ISNULL(GV_HDDT.DIEM, 0) + ISNULL(GV_PBDT.DIEM, 0) + ISNULL(GV_UVDT.DIEM, 0)) / 3
        FROM GV_HDDT
        JOIN GV_PBDT ON GV_HDDT.MSDT = GV_PBDT.MSDT
        JOIN GV_UVDT ON GV_HDDT.MSDT = GV_UVDT.MSDT
        WHERE GV_HDDT.MSDT = @MSDT

        -- Kiểm tra nếu đã tồn tại mã số đề tài trong bảng DETAI_DIEM
        IF EXISTS (SELECT 1 FROM DETAI_DIEM WHERE MSDT = @MSDT)
        BEGIN
            UPDATE DETAI_DIEM
            SET DIEMTB = @AVGDT
            WHERE MSDT = @MSDT
        END
        ELSE
        BEGIN
            -- Thêm kết quả vào bảng DETAI_DIEM
            INSERT INTO DETAI_DIEM (MSDT, DIEMTB)
            VALUES (@MSDT, @AVGDT)
        END

        -- Lấy mã số đề tài tiếp theo
        FETCH NEXT FROM diem_cursor INTO @MSDT
    END

    -- Đóng và giải phóng con trỏ
    CLOSE diem_cursor
    DEALLOCATE diem_cursor
END
--Tạo thêm cột XEPLOAI có kiểu là NVARCCHAR(20) trong bảng DETAI_DIEM, viết Cursor cập nhật kết quả xếp loại cho mỗi đề tài như sau:
--		+ "Xuất sắc": điểm trung bình từ 9 đến 10.
--		+ "Giỏi": điểm trung bình từ 8 đến dưới 9.
--		+ "Khá": điểm trung bình từ 6.5 đến dưới 8.
--		+ "Trung bình": điểm trung bình từ 5 đến dưới 6.5.
--		+ "Không đạt": điểm trung bình dưới 5.
ALTER TABLE DETAI_DIEM
ADD XEPLOAI NVARCHAR(20);

DECLARE @MSDT CHAR(6);              -- Biến để lưu mã số đề tài
DECLARE @DIEMTB FLOAT;              -- Biến để lưu điểm trung bình
DECLARE @XEPLOAI NVARCHAR(20);      -- Biến để lưu kết quả xếp loại

-- Khai báo con trỏ
DECLARE xep_loai_cursor CURSOR FOR
SELECT MSDT, DIEMTB
FROM DETAI_DIEM; -- Lấy danh sách mã số đề tài và điểm trung bình

-- Mở con trỏ
OPEN xep_loai_cursor;

-- Lấy từng dòng dữ liệu
FETCH NEXT FROM xep_loai_cursor INTO @MSDT, @DIEMTB;

-- Vòng lặp qua từng dòng
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Xác định xếp loại dựa trên điểm trung bình
    IF @DIEMTB >= 9 AND @DIEMTB <= 10
        SET @XEPLOAI = N'Xuất sắc';
    ELSE IF @DIEMTB >= 8 AND @DIEMTB < 9
        SET @XEPLOAI = N'Giỏi';
    ELSE IF @DIEMTB >= 6.5 AND @DIEMTB < 8
        SET @XEPLOAI = N'Khá';
    ELSE IF @DIEMTB >= 5 AND @DIEMTB < 6.5
        SET @XEPLOAI = N'Trung bình';
    ELSE
        SET @XEPLOAI = N'Không đạt';

    -- Cập nhật xếp loại vào bảng DETAI_DIEM
    UPDATE DETAI_DIEM
    SET XEPLOAI = @XEPLOAI
    WHERE MSDT = @MSDT;

    -- Lấy dòng tiếp theo
    FETCH NEXT FROM xep_loai_cursor INTO @MSDT, @DIEMTB;
END;

-- Đóng và giải phóng con trỏ
CLOSE xep_loai_cursor;
DEALLOCATE xep_loai_cursor;
