
--Add a job
EXEC msdb.dbo.sp_add_job
@owner_login_name=N'NT SERVICE\SQLSERVERAGENT',
    @job_name = N'backup_project_50_min' ;
--Add a job step named process step. This step runs the stored procedure
EXEC msdb.dbo.sp_add_jobstep
    @job_name =  N'backup_project_50_min',
    @step_name = N'process step',
    @subsystem = N'TSQL',
    @command =N'
	WAITFOR DELAY ''00:05:00.000''
while 1=1
BEGIN
declare @name varchar(44) 
declare @path varchar(77)
declare @filename varchar(77)
declare @fileDate varchar(20)
set @path=N''C:\backup\''
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
exec msdb.dbo.sp_add_jobschedule @job_name ='backup_project_50_min',
@name = 'backupproject',
@freq_type=1,
@active_start_date =  N'20230217',
@active_start_time =N'211900' 
-- Add the job to the SQL Server 
EXEC msdb.dbo.sp_add_jobserver
    @job_name =  N'backup_project_50_min',
    @server_name = @@SERVERNAME




  exec msdb.dbo.sp_help_job @job_name='backup_project_50_min'--information about the job