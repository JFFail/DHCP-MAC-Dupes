#PowerShell script to check for duplicate MACs in a DHCP database.
#Get the servers first.
$serverList = "first","second"

#Make sure they are valid and accessible.
foreach($server in $serverList) {
	$isAvailable = $false
	try {
		$isAvailable = Test-Connection -ComputerName $server -Quiet -Count 1
	} catch {
		Write-Host "$server is not valid of unavailable! Quitting..." -ForegroundColor Red
		break
	}
}

#Quit the whole thing if there were failures.
if(-not $isAvailable) {
	exit
}

#Initialize the array that will hold every lease.
$leaseArray = @()

#If we made it this far, start to loop through the servers.
foreach($server in $serverList) {
	#First get the scopes for that server since we can't wholesale get leases.
	$scopeList = Get-DhcpServerv4Scope -ComputerName $server
	
	#Loop through each of the scopes, adding their leases to the array.
	foreach($scope in $scopeList) {
		$leaseArray += Get-DhcpServerv4Lease -ComputerName $server -ScopeId $scope.ScopeID
	}
}

#Loop through each element, and compare it to the others to find duplicates.
foreach($lease in $leaseArray) {
	#Start counting the duplicate values.
	$currentCount = 0
	#Compare the current lease to every other. Increment the counter on hits.
	foreach($checkLease in $leaseArray) {
		if($lease.ClientID -eq $checkLease.ClientID) {
			$currentCount++
			#Hits over 1 mean duplicates; every instance will have at least one.
			if($currentCount -eq 2) {
				Write-Output $lease
				Write-Output $checkLease
			} elseif ($currentCount -gt 2) {
				Write-Output $checkLease
			}
		}
	}
	if($currentCount -gt 1) {
		Write-Output "========================="
	}
}