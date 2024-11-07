BACKUP DATABASE[QLBH]
TO DISK = 'D:\project\SQL\QLBH_FullBackup.bak'
WITH FORMAT,
NAME = 'Full Backup Of QLBH';

/*restore*/
RESTORE DATABASE [QLBH] 
FROM DISK = 'D:\project\SQL\QLBH_FullBackup.bak' 
WITH REPLACE;

BACKUP DATABASE [QLBH] 
TO DISK = 'D:\project\SQL\QLBH_DifferentialBackup.bak'
WITH DIFFERENTIAL,
NAME = 'Differential Backup của QLBH';

RESTORE DATABASE [QLBH] 
FROM DISK = 'D:\project\SQL\QLBH_FullBackup.bak' 
WITH NORECOVERY;

RESTORE DATABASE [QLBH] 
FROM DISK = 'D:\project\SQL\QLBH_DifferentialBackup.bak'
WITH RECOVERY;
