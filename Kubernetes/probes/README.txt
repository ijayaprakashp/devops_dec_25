Create Flask App docker image
	cd App; docker build -t <image> .

Use the above docker image in all .yaml files and apply them 
    kubectl apply -f <manifest>.yaml

Monitor the Pods Status
	kubectl get pods --watch
 	- Before 10-11 seconds, you should see the pod's status as Running with READY=1/1.
 	- After 10-11 seconds, the pod's readiness probe will fail, and the status will change to CrashLoopBackOff or NotReady.

Monitor the Service Endpoints 
	kubectl get endpoints --watch
 	- Before 10-11 seconds, you will see the pod's IP in the endpoints list.
 	- After 10-11 seconds, the pods IP will be removed from the services endpoints list, reflecting that it is not ready.

Monitor both pod and service 
	watch -n 1 "kubectl get endpoints <service_name> && kubectl get pods"
