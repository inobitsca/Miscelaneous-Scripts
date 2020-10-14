select r.replica_server_name, r.endpoint_url,
rs.connected_state_desc, rs.last_connect_error_description, 
rs.last_connect_error_number, rs.last_connect_error_timestamp 
from sys.dm_hadr_availability_replica_states rs join sys.availability_replicas r
on rs.replica_id=r.replica_id
where rs.is_local=1
