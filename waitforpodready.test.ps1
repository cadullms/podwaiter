. $PSScriptRoot\waitforpodready.ps1 # The . at the start of this line means we are just loading the functions, not executing anything yet

# WaitForPodReady -podLabel "run=notexist" # will timeout and throw
# WaitForPodReady -podName "notexist" # will timeout and throw

kubectl apply -f $PSScriptRoot\waiter.yaml 
WaitForPodReady -podLabel "run=waiter" 
kubectl delete pod -l "run=waiter"

kubectl apply -f $PSScriptRoot\waiter.yaml 
WaitForPodReady -podName waiterpod
kubectl delete pod -l "run=waiter"

kubectl apply -f $PSScriptRoot\waiter.yaml 
WaitForPodReady -podName waiterpod -containerName waitercontainer
kubectl delete pod -l "run=waiter"