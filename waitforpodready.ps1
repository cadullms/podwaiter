function GetPodStatuses ($podName)
{
    $podJson = (kubectl get pod $podName -o json)
    $podInfo = $podJson | ConvertFrom-Json
    return $podInfo.status.containerStatuses
}

function IsPodReady ($podName, $containerName = "")
{
    $statuses = GetPodStatuses -podName $podName
    if ([String]::IsNullOrEmpty($containerName))
    {
        $totalCount = $statuses.Count
        $readyCount = ($statuses | Where-Object {$_.ready}).Count  
        return ($readyCount -eq $totalCount)     
    }
    else
    {
        $containerStatus = $statuses | Where-Object { $_.name -eq $containerName}
        if (-not $containerStatus)
        {
            throw "No container named $containerName found in pod $podName."
        }
        return $containerStatus.ready
    }
}

function WaitForPodReady($podName, $containerName = "")
{
    Write-Output "Waiting for pod $podName to be ready..."
    $interval = 0.25
    $maxInterval = 64
    $timeOut = 600
    $startTime = [DateTime]::Now
    $secondsPassed = 0
    while (-not (IsPodReady -podName $podName -containerName $containerName))
    {
        Start-Sleep -Seconds $interval
        if ($interval -le $maxInterval)
        {
            $interval *= 2
        }

        $secondsPassed = ([DateTime]::Now - $startTime).TotalSeconds
        if ($secondsPassed -gt $timeOut)
        {
            throw "Timed out after $timeOut seconds waiting for pod $podName to get ready."
        }
    }
    
    Write-Output "Pod $podName ready after $secondsPassed seconds."
}
