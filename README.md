# Redis-Guestbook-Application

### RedisExample.sh up | up online | down
- Up offline is default (using local files)
- Up online is optional to use the online files
- Down removes the app (required for k8s removal using AWS LB)

- Note: This specifically sets up the frontend with a cloud load balancer


### Requirement:
Kubectl is setup to k8s cluster

### Probably needs to be done:
- TODO: Option for default (Nodeport - no LB)
    - Deploy frontend-service.yaml as it is (Commented out in script - lines 215 and 218)
- TODO: Null outputs
- TODO: Check kubectl get nodes

### RedisExample.sh up | up online
```
$ bash RedisExample.sh up online
RedisExample.sh - Online

RedisExample.sh - Up

deployment.apps/redis-master created
.
RedisExample.sh - Redis Master Deployment Up
service/redis-master created

RedisExample.sh - Redis Master Service Up
deployment.apps/redis-slave created
.
RedisExample.sh - Redis Slave 1 Deployment Up

RedisExample.sh - Redis Slave 2 Deployment Up
service/redis-slave created

RedisExample.sh - Redis Slave Service Up
deployment.apps/frontend created
.
RedisExample.sh - Redis Frontend 3 Deployments Up
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   185  100   185    0     0   1316      0 --:--:-- --:--:-- --:--:--  1321
100   438  100   438    0     0   1243      0 --:--:-- --:--:-- --:--:--  1243
service/frontend created
.
RedisExample.sh - Guestbook is coming up.  This takes 2 minutes.
......
RedisExample.sh - Guestbook is up
RedisExample.sh Complete - To access the Guestbook Application: http://ab0bd5b03683a11e9ae580a6f769860d-1442922675.us-west-2.elb.amazonaws.com
```


### RedisExample.sh down
```
$ bash RedisExample.sh down
RedisExample.sh - Bringing down Guestbook application

service "frontend" deleted
service "redis-master" deleted
service "redis-slave" deleted
deployment.extensions "frontend" deleted
deployment.extensions "redis-master" deleted
deployment.extensions "redis-slave" deleted
RedisExample.sh - Guestbook application removed
```