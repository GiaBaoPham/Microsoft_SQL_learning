USE QLGV


--1.	Tăng hệ số lương thêm 0.2 cho những giáo viên là trưởng khoa.
--2.	Cập nhật giá trị điểm trung bình tất cả các môn học  (DIEMTB) của mỗi học viên (tất cả các môn học đều có hệ số 1 và nếu học viên thi một môn nhiều lần, chỉ lấy điểm của lần thi sau cùng).
UPDATE HOCVIEN
SET DIEMTB = (
	SELECT AVG(DIEM)
	FROM(
		SELECT MAHV, MAMH, LANTHI, DIEM
		FROM KETQUATHI KQ1
		WHERE LANTHI >= ALL(
			SELECT LANTHI 
			FROM KETQUATHI KQ2
			WHERE KQ2.MAHV = KQ1.MAHV AND KQ2.MAMH = KQ1.MAMH
			)
		) AS LANCUOI
	WHERE HOCVIEN.MAHV = LANCUOI.MAHV
	)

--4.	Cập nhật giá trị cho cột XEPLOAI trong quan hệ HOCVIEN như sau:
--o	Nếu DIEMTB  9 thì XEPLOAI =”XS”
--o	Nếu  8 <= DIEMTB < 9 thì XEPLOAI = “G”
--o	Nếu  6.5 <= DIEMTB < 8 thì XEPLOAI = “K”
--o	Nếu  5  <=  DIEMTB < 6.5 thì XEPLOAI = “TB”
--o	Nếu  DIEMTB < 5 thì XEPLOAI = ”Y”
UPDATE HOCVIEN
SET XEPLOAI = 
	CASE 
		WHEN DIEMTB >= 9 THEN  'XS'
		WHEN DIEMTB >= 8 AND DIEMTB < 9 THEN 'G'
		WHEN DIEMTB >= 6.5 AND DIEMTB < 8 THEN 'K'
		WHEN DIEMTB >= 5 AND DIEMTB < 6.5 THEN 'TB'
		ELSE 'Y'
	END
SELECT* FROM HOCVIEN