# Kubernetes manifests for the beloved-pets voting app

This folder contains the Kubernetes manifests that deploy a voting application with a Postgres database, Redis cache, vote and result services, a standalone worker, and TLS-enabled ingress.

The manifests are ordered for a stable startup: credentials and storage first, followed by database and cache, then application workloads, and finally TLS/ingress.

Directory tree:

```
README.md
certificate.yaml
ingress-tls.yaml
postgres-deployment.yaml
postgres-secrets.yaml
redis-deployment.yaml
redis-service.yaml
result-deployment.yaml
result-service.yaml
vote-deployment.yaml
vote-service.yaml
worker-deployment.yaml
```

Apply order:

```
kubectl apply -f redis-deployment.yaml
kubectl apply -f redis-service.yaml
kubectl apply -f postgres-secrets.yaml
kubectl apply -f worker-deployment.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f result-deployment.yaml 
kubectl apply -f result-service.yaml
kubectl apply -f vote-deployment.yaml
kubectl apply -f vote-service.yaml
kubectl apply -f certificate.yaml
kubectl apply -f ingress-tls.yaml
```


Delete order:

```
kubectl delete -f ingress-tls.yaml
kubectl delete -f certificate.yaml
kubectl delete -f vote-service.yaml
kubectl delete -f vote-deployment.yaml
kubectl delete -f result-service.yaml
kubectl delete -f result-deployment.yaml 
kubectl delete -f postgres-deployment.yaml
kubectl delete -f worker-deployment.yaml
kubectl delete -f postgres-secrets.yaml
kubectl delete -f redis-service.yaml
kubectl delete -f redis-deployment.yaml
```

Manifest roles:

- `postgres-secrets.yaml`: stores database credentials and the Postgres database name in a Kubernetes Secret.
- `postgres-deployment.yaml`: deploys the Postgres database pod, creates its internal service, and provisions persistent storage with a PVC.
- `redis-deployment.yaml`: deploys a single Redis pod for caching and fast state access.
- `redis-service.yaml`: exposes Redis inside the cluster on port 6379 for the vote app and the worker.
- `vote-deployment.yaml`: deploys the voting frontend app, configured to connect to Redis using the Redis service.
- `vote-service.yaml`: exposes the vote app internally on port 80 so ingress or other services can route to it.
- `result-deployment.yaml`: deploys the result app, configured to connect to Postgres using the database service and secret credentials.
- `result-service.yaml`: exposes the result app internally on port 80 for ingress routing and internal access.
- `worker-deployment.yaml`: deploys a background worker pod that connects to both Postgres and Redis for asynchronous processing.
- `certificate.yaml`: requests a TLS certificate from cert-manager for the application hostnames and stores it in a secret.
- `ingress-tls.yaml`: configures NGINX ingress with TLS termination and routes vote and result traffic to the internal services.
