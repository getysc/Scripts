# Linux
kubectl logs -n default podname 
kubectl logs -n default podname --all-containers=true

# Get a pod\container log
kubectl logs pod_name container_name -n default  
# Get a crashed pod\container log   (previous pod log)
kubectl logs pod_name container_name -n default  --previous


#bash code
for pod in `kubectl get pods --no-headers -o custom-columns=":metadata.name"` ; do
  echo $pod
  kubectl logs $pod 
done

# powershell
# Get all pod names
$namespace='default'
kubectl -n $namespace get pods --no-headers -o custom-columns=":metadata.name"
foreach ($pod in $pods)
{
  Write-Host "kubectl -n $($namespace) logs $($pod) --all-containers"
  kubectl -n $namespace logs $pod --all-containers >  "$($pod).log"
}

foreach ($pod in $pods)
{
  if ($pod.Contains('infraviz'))
  {
	    kubectl logs $pod  >  "$($pod).log"
      kubectl logs $pod containername  >  "$($pod).log"
  }
}
