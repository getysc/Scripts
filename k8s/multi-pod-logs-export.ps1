# Linux
kubectl logs -n default podname 
kubectl logs -n default podname --all-containers=true

#bash code
for pod in `kubectl get pods --no-headers -o custom-columns=":metadata.name"` ; do
  echo $pod
  kubectl logs $pod 
done

# powershell
# Get all pod names
$pods=kubectl get pods --no-headers -o custom-columns=":metadata.name"
foreach ($pod in $pods)
{
  if ($pod.Contains('infraviz'))
  {
	    kubectl logs $pod  >  "$($pod).log"
      kubectl logs $pod containername  >  "$($pod).log"
  }
}
