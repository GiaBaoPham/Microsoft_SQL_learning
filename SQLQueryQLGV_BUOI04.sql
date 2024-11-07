USE QLGV
--19.Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất.
SELECT * FROM KHOA
SELECT MAKHOA, TENKHOA
FROM KHOA K1
WHERE NGTLAP = (
	SELECT MIN(NGTLAP)
	FROM KHOA K2
	)
--20.Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.
SELECT COUNT(MAGV)
FROM GIAOVIEN
WHERE HOCHAM = 'GS' OR HOCHAM = 'PGS'
--21.	Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa.
SELECT COUNT(MAGV)
FROM GIAOVIEN
WHERE HOCVI IN ('CN','KS','Ths','TS','PTS')
GROUP BY MAKHOA
--32.* Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng).
SELECT MAHV, TEN
FROM HOCVIEN
WHERE MAHV NOT IN (
	SELECT MAHV
	FROM KETQUATHI KQ1
	WHERE LANTHI >= ALL (
		SELECT LANTHI
		FROM KETQUATHI KQ2
		WHERE KQ2.MAMH = KQ1.MAMH AND KQ2.MAHV = KQ1.MAHV
	)
AND KQUA = 'Khong Dat'
)
--35.** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần thi sau cùng).
SELECT MAHV
FROM KETQUATHI JOIN(
	SELECT KQSC.MAMH, MAX(DIEM) AS DCN
	FROM
	(
		SELECT MAHV, MAMH, DIEM
		FROM KETQUATHI KQ1
		WHERE LANTHI >= ALL
		(
			SELECT LANTHI
			FROM KETQUATHI KQ2
			WHERE KQ2.MAMH = KQ1.MAMH AND KQ2.MAHV = KQ1.MAHV
		)
	)KQSC
GROUP BY KQSC.MAMH
)
ON KETQUATHI.MAMH = MAMH AND DIEM = MAX(DIEM)
