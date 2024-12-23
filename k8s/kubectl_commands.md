Cheatsheet
https://kubernetes.io/docs/reference/kubectl/cheatsheet/


#kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yml - this kubectl command is used to create a pod based on Calico

#kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml - this kubectl command is used to create the dashboard

#kubectl proxy - this kubectl command is used to enable proxy and continues with new terminal window

#kubectl version - this kubectl command is used to check the version

#kubectl get nodes - this kubectl command is used to check the status of nodes

# pods
kubectl -n default get pods 
#kubectl get pods --all-namespaces - this kubectl command is used to check the status of pods
#kubectl get -o wide pods --all-namespaces - this kubectl command is used to check detailed status of pods
kubectl get pods --show-labels

# List all pod secret names
kubectl get pods -o json | jq '.items[].spec.containers[].env[]?.valueFrom.secretKeyRef.name' | grep -v null | sort | uniq

#pod logs
kubectl logs -f test-pod-0  # Show Continuous Logs
kubectl -n default logs -f deployment/deploymentn-green  --all-containers=true --since=30m
kubectl -n default logs -f deployment/deploymentn-green -c  core-container --timestamps=true -f 

# Look for error in all pods
for i in $(kubectl get pods | grep my-nginx | awk {'print $1'});do echo "******$i******\n";kubectl logs $i | grep -i error;done

#kubectl create serviceaccount dashboard -n default - to create a service account for your dashboard

#kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard - to create cluster binding rules for
our roles on dashboard

#kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode - to get secret key to be
pasted onto the dashboard token pwd.Copy the outcoming secret key.

#kubectl create deployment nginx --image=nginx - create a deployment

#kubectl get deployments - Verify the deployment

#kubectl describe deployment nginx - more details about the deployment

#kubectl create service nodeport nginx --tcp=80:80 - create the service on the nodes

#kubectl get svc - to check which deployment is running on which node

#kubectl delete deployment <name> - to delete the deployment

#kubectl get pods --namespace kube-system - To verify that Tiller is running, list the pods in the kube-system namespace

#kubectl -n kube-system create serviceaccount tiller - to Create the tiller serviceaccount

#kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller - to bind the tiller serviceaccount to the cluster-admin role

#kubectl exec shell-demo ps aux - to run "ps aux" command in running container shell-demo

#kubectl exec shell-demo ls / - to run "ls /" command in running container shell-demo

#  Run a command in existing pod
# kubectl exec test-pod-0 -- du -sh /u01/test/

#kubectl exec shell-demo cat /proc/1/mounts - to run "cat /proc/1/mounts" running container shell-demo

#kubectl exec -it shell-demo -- /bin/bash - to get a shell to the running container(Note: The double dash symbol “–” is used to separate the arguments you want to pass to the command from the kubectl arguments.)

#kubectl apply -f https://k8s.io/examples/application/shell-demo.yaml - to create a pod "shell-demo"

#kubectl set image deployment/nginx nginx=1.13

#kubectl scale deployment nginx --replicas=9

# Horizontal Scale Up/Down  - https://www.cyberithub.com/horizontal-scale-up-down-the-pods-cpu-utilization-kubernetes/
kubectl get hpa
kubectl autoscale rs web-app --max=8 --min=2 --cpu-percent=60


# Stateful and Stateless Pods - https://www.cyberithub.com/how-to-check-stateful-and-stateless-pods-in-kubernetes-cluster/
kubectl get statefulset




