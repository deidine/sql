--delete the job if exist

declare @jobId binary (16)
select @jobId =job_id from msdb.dbo.sysjobs where name=N'delete_backup_files_23:00'
if (@jobId IS NOT NULL) 
begin Exec  msdb.dbo.sp_delete_job @jobId
end
--Add a job
EXEC msdb.dbo.sp_add_job
@owner_login_name=N'NT SERVICE\SQLSERVERAGENT',

    @job_name = N'delete_backup_files_23:00' ;
--Add a job step named process step. This step runs the stored procedure
EXEC msdb.dbo.sp_add_jobstep
    @job_name =  N'delete_backup_files_23:00',
    @step_name = N'process step',
    @subsystem = N'TSQL',
    @command =N'
while 1=1

begin 

WAITFOR time ''23:00''
declare @deletedate nvarchar(22)
declare @deletetime datetime
set @deletetime=DATEADD(second,4,getdate())
set @deletedate=(select replace( convert (nvarchar,@deletetime,111),''/'',''-'')+''T''+convert(nvarchar,@deletetime,108))
execute master.dbo.xp_delete_file 0,N''C:\backup'', N''back'',@deletedate,1

END
'
--Schedule the job at a specified date and time
exec msdb.dbo.sp_add_jobschedule @job_name ='delete_backup_files_23:00',
@name = 'delete files',
@freq_type=1,
@active_start_date =  N'20230219',
@active_start_time =N'074200' 
-- Add the job to the SQL Server 
EXEC msdb.dbo.sp_add_jobserver
    @job_name =  N'delete_backup_files_23:00',
    @server_name = @@SERVERNAME

exec msdb.dbo.sp_help_job @job_name='delete_backup_files_23:00'--information about the job
