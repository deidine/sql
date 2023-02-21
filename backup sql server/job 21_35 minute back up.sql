--delete the job if exist

declare @jobId binary (16)
select @jobId =job_id from msdb.dbo.sysjobs where name=N'backup_project_23:00'
if (@jobId IS NOT NULL) 
begin Exec  msdb.dbo.sp_delete_job @jobId
end
--Add a job
EXEC msdb.dbo.sp_add_job
@owner_login_name=N'NT SERVICE\SQLSERVERAGENT',

    @job_name = N'backup_project_23:00' ;
--Add a job step named process step. This step runs the stored procedure
EXEC msdb.dbo.sp_add_jobstep
    @job_name =  N'backup_project_23:00',
    @step_name = N'process step',
    @subsystem = N'TSQL',
    @command =N'
while 1=1
BEGIN
WAITFOR time ''23:50''
declare @name varchar(44) 
declare @path varchar(77)
declare @filename varchar(77)
declare @fileDate varchar(20)
set @path=N''C:\backup\''--create a folder name as backup
select @fileDate=convert (varchar(20),getdate(),112)+''_''+replace(CONVERT(varchar(20),getdate(),108),'':'','''')

declare db_cursor Cursor for select name from master.dbo.sysdatabases where name not in (''master'',''model'',''msdb'',''tempdb'')
open db_cursor 
Fetch next from db_cursor into @name while @@FETCH_STATUS =0  
begin set @filename=@path + @name + ''_'' +@fileDate+ ''.back''
backup database @name to disk =@filename
Fetch next from db_cursor into @name end
close db_cursor 
deallocate db_cursor


END
'
--Schedule the job at a specified date and time
exec msdb.dbo.sp_add_jobschedule @job_name ='backup_project_23:00',
@name = 'backupproject',
@freq_type=1,
@active_start_date =  N'20230219',
@active_start_time =N'074200' 
-- Add the job to the SQL Server 
EXEC msdb.dbo.sp_add_jobserver
    @job_name =  N'backup_project_23:00',
    @server_name = @@SERVERNAME

exec msdb.dbo.sp_help_job @job_name='backup_project_23:00'--information about the job


