#!/bin/bash

# RedisExample.sh up | up online | down
# - Up offline is default (using local files)
# - Up online is optional to use the online files
# - Down removes the app (required for k8s removal using AWS LB)

# Requires: Kubectl setup to k8s cluster

# TODO - Null outputs
# TODO - Check kubectl get nodes

case "$2" in
online)
	#echo "RedisExample.sh - Online"
	#echo
	REDIS_OFFLINE=0
	REDIS_CMD="https://k8s.io/examples/application/guestbook/"
	;;
"")
	#echo "RedisExample.sh - Offline"
	#echo
	REDIS_OFFLINE=1
	REDIS_CMD="./Files/"
	;;
*)
	echo "Fail - RedisExample.sh up | up online | down 
	- Error in Argument 2"
	echo
	exit
	;;
esac

case "$1" in 
up) 
	echo "RedisExample.sh - Starting Guestbook Application..."
	echo

	## Deploy Redis master pods and service:
	#	kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-deployment.yaml
	FILE=$REDIS_CMD"redis-master-deployment.yaml"
	kubectl apply -f $FILE

	## Optional: Check Pod
	#kubectl get pods
		#		$   kubectl get pods
		#		NAME                           READY   STATUS              RESTARTS   AGE
		#		redis-master-596696dd4-kpjnv   0/1     ContainerCreating   0          8s
		#		$   kubectl get pods
		#		NAME                           READY   STATUS    RESTARTS   AGE
		#		redis-master-596696dd4-kpjnv   1/1     Running   0          43s
	while true
	do
    	# Get pod status
    	TASK=$(kubectl get pods | grep redis-master | awk '{print $3}' | grep Running)
      if [ "$TASK" != "Running" ]
      then
           	printf "."
      else
            echo
            echo "RedisExample.sh - Redis Master Deployment Up"
            break
      fi
    	sleep 5
	done

	# kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-service.yaml
	FILE=$REDIS_CMD"redis-master-service.yaml"
	kubectl apply -f $FILE

	#kubectl logs -f <POD-NAME>
	## Optional: Check Service
	#kubectl get service
		#		$ kubectl get service
		#		NAME           TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
		#		kubernetes     ClusterIP   10.0.0.1     <none>        443/TCP    4h53m
		#		redis-master   ClusterIP   10.0.0.174   <none>        6379/TCP   4m45s
	while true
	do
    	# Get svc status
    	TASK=$(kubectl get service | awk '{print $1}' | grep redis-master)

      if [ "$TASK" != "redis-master" ]
      then
           	printf "."
      else
            echo
            echo "RedisExample.sh - Redis Master Service Up"
            break
      fi
    	sleep 5
	done

	## Deploy the Redis slaves
	# kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-deployment.yaml
	FILE=$REDIS_CMD"redis-slave-deployment.yaml"
	kubectl apply -f $FILE

	## Optional: Check Pod
	#kubectl get pods
		#		$ cat redis-slave-deployment.out | grep slave | awk '{print $1}' | sed -n 1p
		#		redis-slave-2005841000-fpvqc
		#		$ cat redis-slave-deployment.out | grep slave | awk '{print $1}' | sed -n 2p
		#		redis-slave-2005841000-phfv9

	SLAVE_1=$(kubectl get pods | grep slave | awk '{print $1}' | sed -n 1p)
	SLAVE_2=$(kubectl get pods | grep slave | awk '{print $1}' | sed -n 2p)

	## Check Slave 1
	while true
	do
    	# Get pod status
    	TASK=$(kubectl get pods | grep $SLAVE_1 | awk '{print $3}')

      if [ "$TASK" != "Running" ]
      then
           	printf "."
      else
            echo
            echo "RedisExample.sh - Redis Slave 1 Deployment Up"
            break
      fi
    	sleep 5
	done

	## Check Slave 2
	while true
	do
    	# Get pod status
    	TASK=$(kubectl get pods | grep $SLAVE_2 | awk '{print $3}')

      if [ "$TASK" != "Running" ]
      then
           	printf "."
      else
            echo
            echo "RedisExample.sh - Redis Slave 2 Deployment Up"
            break
      fi
    	sleep 5
	done

	# kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-service.yaml
	FILE=$REDIS_CMD"redis-slave-service.yaml"
	kubectl apply -f $FILE


	## Optional: Check Service
	#kubectl get service
		#		$ kubectl get service
		#		NAME           TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
		#		kubernetes     ClusterIP   10.0.0.1     <none>        443/TCP    4h53m
		#		redis-master   ClusterIP   10.0.0.174   <none>        6379/TCP   4m45s
		#		redis-slave    ClusterIP   10.0.0.223   <none>        6379/TCP   6s

	while true
	do
    	# Get svc status
    	TASK=$(kubectl get service | awk '{print $1}' | grep redis-slave)

      if [ "$TASK" != "redis-slave" ]
      then
           	printf "."
      else
            echo
            echo "RedisExample.sh - Redis Slave Service Up"
            break
      fi
    	sleep 5
	done

	## Deploy the webapp frontend
	# kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-deployment.yaml
	FILE=$REDIS_CMD"frontend-deployment.yaml"
	kubectl apply -f $FILE

	## Optional: Check frontend replicas
	#kubectl get pods -l app=guestbook -l tier=frontend
	#		  NAME                        READY     STATUS    RESTARTS   AGE
	#		  frontend-3823415956-dsvc5   1/1       Running   0          54s
	#		  frontend-3823415956-k22zn   1/1       Running   0          54s
	#		  frontend-3823415956-w9gbt   1/1       Running   0          54s

	NUM=1
	## Check for all 3 frontends
	while true
	do
		SED_VAR=$NUM"p"
    	# Get pod status
    	TASK=$(kubectl get pods -l app=guestbook -l tier=frontend | grep frontend | awk '{print $3}' | sed -n $SED_VAR)

      if [ "$TASK" != "Running" ]
      then
           	printf "."
			sleep 1
      else
			((NUM+=1))
			if (( $NUM > 3 ))
			then
            	echo
            	echo "RedisExample.sh - Redis Frontend 3 Deployments Up"
            	break
			fi
      fi
    	sleep 1
	done

	## Deploy the load-balancer - NOTE: Exchanging NodePort for LoadBalancer bc of AWS capabilities
	# curl -L https://k8s.io/examples/application/guestbook/frontend-service.yaml | sed "s@NodePort@LoadBalancer@" | kubectl apply -f -
	FILE=$REDIS_CMD"frontend-service.yaml"

	if [ $REDIS_OFFLINE == 0 ]
	then
		curl -L $FILE | sed "s@NodePort@LoadBalancer@" | kubectl apply -f -
		#kubectl apply -f $FILE
	else
		cat $FILE | sed "s@NodePort@LoadBalancer@" | kubectl apply -f -
		#kubectl apply -f $FILE
	fi

	## Optional: Check the deployed service
	#kubectl get service frontend                        # check the load balancer
		#		$ 	kubectl get service frontend
		#		NAME       TYPE           CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE
		#		frontend   LoadBalancer   10.0.0.49    <pending>     80:30372/TCP   1s
	while true
	do
    	# Get svc status
    	URL=$(kubectl get service frontend | awk '{print $4}' | grep elb)
        if [ "$URL" == "" ]
        then
           	printf "."
        else
            echo
            echo "RedisExample.sh - Guestbook is coming up.  This takes 2 minutes."
            break
        fi
    	sleep 5
	done
	## Check page status
	#		$ curl -Is http://ab7b912ff683011e9a37e0aede8bc9b7-671057563.us-west-2.elb.amazonaws.com | head -1
	#		HTTP/1.1 200 OK
	while true
	do
    	# Get svc status
    	TASK=$(curl -Is http://$URL | head -1)
      if [[ "$TASK" != *OK* ]]
      then
         printf "."
      else
         echo
         echo "RedisExample.sh - Guestbook is up"

			## Go to Application
			echo "RedisExample.sh Complete - To access the Guestbook Application: http://$URL"
			#		e.g. TASK=af3b58de1677011e9b24e0a977c26205-150039293.us-west-2.elb.amazonaws.com
			echo
         break
      fi
    	sleep 15
	done
	;;
down)
   echo "RedisExample.sh - Bringing down Guestbook application"
	echo
	## Remove app
	kubectl delete service frontend
	kubectl delete service redis-master
	kubectl delete service redis-slave
	kubectl delete deployment frontend
	kubectl delete deployment redis-master
	kubectl delete deployment redis-slave
	echo "RedisExample.sh - Guestbook application removed"
	echo
	;;
*)
	echo "Fail - RedisExample.sh up | up online | down
	- Error in Argument 1"
	echo
	exit
	;;
esac