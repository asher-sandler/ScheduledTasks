function Enable-ScheduledTasks {
    [CmdletBinding()]        
   
    # Parameters used in this function
    param
    (
        [Parameter(Position=0, Mandatory = $false, HelpMessage="Provide server names", ValueFromPipeline = $true)] 
        $Servers = $env:computername,
   
        
        [Parameter(Position=1, Mandatory = $true, HelpMessage="Select task name (or part)", ValueFromPipeline = $true)][string]
        $TaskName = $null
		
    ) 
  
    # Error action set to Stop
    $ErrorActionPreference = "Stop"
  
    # Checking module
    Try
    {
        Import-Module ScheduledTasks
    }
    Catch
    {
        $_.Exception.Message
        Write-Warning "Scheduled Tasks module not installed"
        Break
    }
        if ($TaskName) { 
			# Looping each server
			ForEach($Server in $Servers)
			{
				Write-Host "Processing $Server" -ForegroundColor Yellow 
		  
				# Testing connection
				If(!(Test-Connection -Cn $Server -BufferSize 16 -Count 1 -ea 0 -Quiet))
				{
					Write-Warning   "Failed to connect to $Server"
				}
				Else
				{
					$TasksArray = @()
	  
					Try
					{
						$Tasks = Get-ScheduledTask -CimSession $Server | Where-Object {$_.state -match "$State" -and $_.TaskName.ToLower().Contains($TaskName.ToLower())}
						
					}
					Catch
					{
						$_.Exception.Message
						Continue
					}
	 
					If($Tasks)
					{
						# Loop through the servers
						$Tasks | ForEach-Object {
							
							Enable-ScheduledTask $_ -CimSession $Server
							Write-Host "Enable " $_.TaskName
	   
	  
						}
	  
					}
					Else
					{
						Write-Warning "Tasks not found"
					}
				}
			}
		}
}
<#
Get-ScheduledTasks
Get-ScheduledTasks -State Disabled
Get-ScheduledTasks -Servers DC01
Get-ScheduledTasks -Servers DC01,DC02
Get-ScheduledTasks -Servers (Get-Content "c:/temp/input.txt")
Get-ScheduledTasks -Servers DC01,DC02 -State Running
#>

#Get-ScheduledTasks
#Get-ScheduledTasks -State Disabled
Enable-ScheduledTasks -TaskName "reboot"
Enable-ScheduledTasks -TaskName "Secure-Boot"
#Get-ScheduledTasks -TaskName "boot" -State "Disabled"