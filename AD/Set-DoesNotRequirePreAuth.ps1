get-aduser -properties DoesNotRequirePreAuth -filter 'DoesNotRequirePreAuth -eq "true" -and Enabled -eq "True"' | select Name 

#get-aduser -properties DoesNotRequirePreAuth -filter 'DoesNotRequirePreAuth -eq "false" -and Enabled -eq "True"' | Set-ADAccountControl -DoesNotRequirePreAuth $true