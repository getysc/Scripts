# NGINX Ingress controller Cheatsheet
https://lzone.de/cheat-sheet/nginx-ingress


https://kubernetes.github.io/ingress-nginx/troubleshooting/


# start a container that contains curl
kubectl run -it --rm test --image=curlimages/curl --restart=Never -- /bin/sh
# check base connectivity from cluster inside
curl -k https://kubernetes.default.svc.cluster.local
# connect using tokens
curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H  "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc.cluster.local
&& echo
