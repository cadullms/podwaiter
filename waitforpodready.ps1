function GetPodStatuses ($podName)
{
    if ($podName -and $podLabel)
    {
        throw "Both podName AND podLabel are set, only one can be used."
    }

    if ($podName)
    {
        $podJson = (kubectl get pod $podName -o json)
        $podInfo = $podJson | ConvertFrom-Json
        return $podInfo.status.containerStatuses
    }

    if ($podLabel)
    {
        $podJson = (kubectl get pod -l $podLabel -o json)
        $podInfo = $podJson | ConvertFrom-Json
        return $podInfo.items.status.containerStatuses
    }

    throw "Either podName OR podLabel must be set."
}

function IsPodReady ($podName, $podLabel, $containerName = "")
{
    $statuses = GetPodStatuses -podName $podName -podLabel $podLabel
    if (-not $statuses)
    {
        return $false
    }

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

function GetPodText($podName, $podLabel)
{
    if ($podName)
    {
        return "pod $podName" 
    }   

    return "pod(s) with label $podLabel"
}

function WaitForPodReady($podName, $podLabel, $containerName = "")
{
    $podText = GetPodText -podName $podName -podLabel $podLabel
    Write-Output "Waiting for $podText to be ready..."
    $interval = 0.25
    $maxInterval = 64
    $timeOut = 600
    $startTime = [DateTime]::Now
    $secondsPassed = 0
    while (-not (IsPodReady -podName $podName -podLabel $podLabel -containerName $containerName))
    {
        Start-Sleep -Seconds $interval
        if ($interval -le $maxInterval)
        {
            $interval *= 2
        }

        $secondsPassed = ([DateTime]::Now - $startTime).TotalSeconds
        if ($secondsPassed -gt $timeOut)
        {
            throw "Timed out after $timeOut seconds waiting for $podText to get ready."
        }
    }
    
    Write-Output "The $podText is ready after $secondsPassed seconds."
}
