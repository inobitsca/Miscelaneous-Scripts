SELECT percent_complete, start_time, status, command, estimated_completion_time/1000/60 As 'Minutes to Completion', total_elapsed_time/1000/60 As 'Minutes Elapsed', wait_type, last_wait_type
FROM sys.dm_exec_requests
Where command = 'DbccFilesCompact'