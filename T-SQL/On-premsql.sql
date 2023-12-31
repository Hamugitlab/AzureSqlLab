USE master
CREATE CREDENTIAL "https://himstoragemi.blob.core.windows.net/sqlinstancedb"-- this name must match the container path, start with https and must not contain a trailing forward slash.
    WITH IDENTITY='SHARED ACCESS SIGNATURE' -- this is a mandatory string and do not change it.
    , SECRET = '' -- this is the shared access signature token
GO



BACKUP DATABASE himmigrationdb TO  URL = N'https://himstoragemi.blob.core.windows.net/sqlinstancedb/himmigrationdb_backup_5.bak' WITH  BLOCKSIZE = 65536,  MAXTRANSFERSIZE = 4194304, NOFORMAT, NOINIT,  NAME = N'himmigrationdb-Full Database Backup', NOSKIP, NOREWIND, NOUNLOAD,  STATS = 10;


BACKUP LOG [himmigrationdb] TO  URL = N'https://himstoragemi.blob.core.windows.net/sqlinstancedb/himmigrationdb_backup_Log_5.bak' WITH NOFORMAT, NOINIT,  NAME = N'himmigrationdb-LOG Database Backup', NOSKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

GO


-- Backup Copy_Only

BACKUP DATABASE himmigrationdb TO  URL = N'https://himstoragemi.blob.core.windows.net/sqlinstancedb/himmigrationdb_COPY_ONLY_backup_5.bak' WITH  COPY_ONLY, BLOCKSIZE = 65536,  MAXTRANSFERSIZE = 4194304, NOFORMAT, NOINIT,  NAME = N'himmigrationdb-Full-COPY_ONLY Database Backup', NOSKIP, NOREWIND, NOUNLOAD,  STATS = 10;


BACKUP LOG [himmigrationdb] TO  URL = N'https://himstoragemi.blob.core.windows.net/sqlinstancedb/himmigrationdb_COPY_ONLY_backup_Log_5.bak' WITH COPY_ONLY, NOFORMAT, NOINIT,  NAME = N'himmigrationdb-LOG-COPY_ONLYDatabase Backup', NOSKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

GO

SELECT * from sys.credentials;


DROP CREDENTIAL "https://sqlservermistorage.blob.core.windows.net/sqlbackup";

-- Restore Database 

RESTORE DATABASE himtestdb FROM  URL = N'https://himstoragemi.blob.core.windows.net/sqlinstancedb/himtestdb_backup_2.bak' WITH  FILE = 1,  NOUNLOAD,  STATS = 5


-- Restore DB with Different Name 


RESTORE FILELISTONLY FROM  URL = N'https://himstoragemi.blob.core.windows.net/sqlinstancedb/himmigrationdb_backup_5.bak';


RESTORE DATABASE himmigrationdbnew FROM URL = N'https://himstoragemi.blob.core.windows.net/sqlinstancedb/himmigrationdb_backup_5.bak'   with RECOVERY,  MOVE N'himmigrationdb' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\himmigrationdb-new.mdf',
MOVE N'himmigrationdb_log' TO 'c:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\himmigrationdb-new_log.ldf';


On Prem SQL Instance 




USE [master]
GO


USE [himmigrationdb]
GO
CREATE TABLE himmigrationdbSQLTest (
   ID INT NOT NULL PRIMARY KEY,
   c1 VARCHAR(100) NOT NULL,
   dt1 DATETIME NOT NULL DEFAULT GETDATE()
)
GO

USE [himmigrationdb]
GO

INSERT INTO himmigrationdbSQLTest (ID, c1) VALUES (1, 'test1')
INSERT INTO himmigrationdbSQLTest (ID, c1) VALUES (2, 'test2')
INSERT INTO himmigrationdbSQLTest (ID, c1) VALUES (3, 'ttest3')
INSERT INTO himmigrationdbSQLTest (ID, c1) VALUES (4, 'test4')
INSERT INTO himmigrationdbSQLTest (ID, c1) VALUES (5, 'test5')
GO


INSERT INTO himmigrationdbSQLTest (ID, c1) VALUES (11, 'afterbackuptest1')
INSERT INTO himmigrationdbSQLTest (ID, c1) VALUES (21, 'afterbackuptesttest2')
INSERT INTO himmigrationdbSQLTest (ID, c1) VALUES (31, 'afterbackuptesttest3')
INSERT INTO himmigrationdbSQLTest (ID, c1) VALUES (41, 'afterbackuptesttest4')
INSERT INTO himmigrationdbSQLTest (ID, c1) VALUES (51, 'afterbackuptesttest5')
GO


SELECT * FROM himmigrationdbSQLTest
GO




select * from sys.databases;

/* Backup Monitor  */

SELECT 
   CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server, 
   msdb.dbo.backupset.database_name, 
   msdb.dbo.backupset.backup_start_date, 
   msdb.dbo.backupset.backup_finish_date, 
   msdb.dbo.backupset.expiration_date, 
   CASE msdb..backupset.type 
      WHEN 'D' THEN 'Database' 
      WHEN 'L' THEN 'Log' 
      END AS backup_type, 
   msdb.dbo.backupset.backup_size, 
   msdb.dbo.backupmediafamily.logical_device_name, 
   msdb.dbo.backupmediafamily.physical_device_name, 
   msdb.dbo.backupset.name AS backupset_name, 
   msdb.dbo.backupset.description 
FROM 
   msdb.dbo.backupmediafamily 
   INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE 
   (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 7) 
   -- and msdb.dbo.backupset.database_name = 'SQLTestDB'
ORDER BY 
   msdb.dbo.backupset.backup_finish_date desc


select * from sys.dm_exec_requests


select * from sys.dm_operation_status 