. $PSScriptRoot\waitforpodready.ps1 # . means we are just loading the functions, not executing anything yet
kubectl apply -f $PSScriptRoot\waiter.yaml 
WaitForPodReady -podName waiterpod
kubectl delete pod waiterpod

kubectl apply -f $PSScriptRoot\waiter.yaml 
WaitForPodReady -podName waiterpod -containerName waitercontainer
kubectl delete pod waiterpod