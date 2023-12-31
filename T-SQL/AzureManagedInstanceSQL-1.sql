/*
Managed Instance Backup failed - BACKUP DATABASE failed. SQL Database Managed Instance supports only COPY_ONLY full database backups which are initiated by user.

One or more of the options (recovery, move) are not supported for this statement in SQL Database Managed Instance. Review the documentation for supported options.

new DM select * from sys.dm_operation_status 
Cant restore the user managed log backup
Database 'himmigrationdb' already exists. Choose a different database name.

Use case 1 - OnPrem backup with COPY_ONLY and restore on Managed Instannce -- Result sucessfully
Use case 2 - OnPrem backup without COPY_ONLY and restore on Managed Instannce -- Result sucessfully
Use Case 3 - onPrem backup without COPY_ONLY and restore on Managed Instannce NORECOVERY and Restore Log -- Result Fail
*/

--Create Credentials

USE master
CREATE CREDENTIAL "https://sqlservermistorage.blob.core.windows.net/sqlbackup"-- this name must match the container path, start with https and must not contain a trailing forward slash.
    WITH IDENTITY='SHARED ACCESS SIGNATURE' -- this is a mandatory string and do not change it.
    , SECRET = '' -- this is the shared access signature token
GO


-- Backup 

USE [master]
BACKUP DATABASE [himtestdb] TO  URL = N'https://himstoragemi.blob.core.windows.net/sqlinstancedb/himtestdbc__backup_4.bak' WITH  BLOCKSIZE = 65536, COPY_ONLY , MAXTRANSFERSIZE = 4194304, NOFORMAT, NOINIT,  NAME = N'himpc_-Full Database Backup', NOSKIP, NOREWIND, NOUNLOAD,  STATS = 10;

BACKUP LOG [himtestdb] TO  URL = N'https://himstoragemi.blob.core.windows.net/sqlinstancedb/himtestdb_LogBackup_4.bak' WITH COPY_ONLY,NOFORMAT, NOINIT,  NAME = N'himpc_LogBackup_2023-12-29_19-26-34', NOSKIP, NOREWIND, NOUNLOAD,  NORECOVERY ,  STATS = 5


-- Restore 
USE [master]
drop DATABASE [himmigrationdb];
RESTORE DATABASE [himmigrationdb] FROM  URL = N'https://himstoragemi.blob.core.windows.net/sqlinstancedb/himmigrationdb_backup_5.bak'; -- Sucessfull 

-- Restore DB with Different Name 
RESTORE FILELISTONLY FROM  URL = N'https://himstoragemi.blob.core.windows.net/sqlinstancedb/himmigrationdb_backup_5.bak';

RESTORE DATABASE himmigrationdbnew FROM URL = N'https://himstoragemi.blob.core.windows.net/sqlinstancedb/himmigrationdb_backup_5.bak'  with RECOVERY,  MOVE N'himmigrationdb' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\himmigrationdb-new.mdf',
MOVE N'himmigrationdb_log' TO 'c:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\himmigrationdb-new_log.ldf'; -- Failed One or more of the options (recovery, move) are not supported for this statement in SQL Database Managed Instance. Review the documentation for supported options.


GO

USE [himmigrationdb]

SELECT * FROM himmigrationdbSQLTest
GO

select * from sys.dm_exec_requests


select * from sys.dm_operation_status 



--------------------------------------------------------------------------------------------------------------------------------
-- Monitor Backup  Check 
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

CREATE EVENT SESSION [Simple backup trace] ON SERVER
ADD EVENT sqlserver.backup_restore_progress_trace(
WHERE operation_type = 0
AND trace_message LIKE '%100 percent%')
ADD TARGET package0.ring_buffer
WITH(STARTUP_STATE=ON)
GO
ALTER EVENT SESSION [Simple backup trace] ON SERVER
STATE = start;


CREATE EVENT SESSION [Verbose backup trace] ON SERVER 
ADD EVENT sqlserver.backup_restore_progress_trace(
    WHERE (
              [operation_type]=(0) AND (
              [trace_message] like '%100 percent%' OR 
              [trace_message] like '%BACKUP DATABASE%' OR [trace_message] like '%BACKUP LOG%'))
       )
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
       MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,
       TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)

ALTER EVENT SESSION [Verbose backup trace] ON SERVER
STATE = start;


WITH
a AS (SELECT xed = CAST(xet.target_data AS xml)
FROM sys.dm_xe_session_targets AS xet
JOIN sys.dm_xe_sessions AS xe
ON (xe.address = xet.event_session_address)
WHERE xe.name = 'Backup trace'),
b AS(SELECT
d.n.value('(@timestamp)[1]', 'datetime2') AS [timestamp],
ISNULL(db.name, d.n.value('(data[@name="database_name"]/value)[1]', 'varchar(200)')) AS database_name,
d.n.value('(data[@name="trace_message"]/value)[1]', 'varchar(4000)') AS trace_message
FROM a
CROSS APPLY  xed.nodes('/RingBufferTarget/event') d(n)
LEFT JOIN master.sys.databases db
ON db.physical_database_name = d.n.value('(data[@name="database_name"]/value)[1]', 'varchar(200)'))
SELECT * FROM b


WITH
a AS (SELECT xed = CAST(xet.target_data AS xml)
FROM sys.dm_xe_session_targets AS xet
JOIN sys.dm_xe_sessions AS xe
ON (xe.address = xet.event_session_address)
WHERE xe.name = 'Verbose backup trace'),
b AS(SELECT
d.n.value('(@timestamp)[1]', 'datetime2') AS [timestamp],
ISNULL(db.name, d.n.value('(data[@name="database_name"]/value)[1]', 'varchar(200)')) AS database_name,
d.n.value('(data[@name="trace_message"]/value)[1]', 'varchar(4000)') AS trace_message
FROM a
CROSS APPLY  xed.nodes('/RingBufferTarget/event') d(n)
LEFT JOIN master.sys.databases db
ON db.physical_database_name = d.n.value('(data[@name="database_name"]/value)[1]', 'varchar(200)'))
SELECT * FROM b

--------------------------------------------------------------------------------------------------------------------------------
   



