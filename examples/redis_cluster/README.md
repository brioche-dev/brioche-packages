# `redis_cluster`

A Redis cluster example that builds OCI container images for master, replica, and sentinel roles, along with a Docker Compose file to run them together.

See [`project.bri`](./project.bri) for the Brioche build definition.

## Configuration

Edit the `config` object at the top of `project.bri` to customize the cluster topology:

```typescript
const config = {
  replicas: 2,
  sentinel: true,
  sentinelCount: 3,
  tls: false,
  password: "changeme",
  persistence: true,
};
```

All Redis instances bind on IPv4 and optionally on IPv6 if the
interface is available.

## Usage

- Build the cluster artifacts with `brioche build -p ./examples/redis_cluster -o ./examples/redis_cluster/output`. This produces OCI image tarballs and a `docker-compose.yml`.
- Run the cluster with Docker Compose:
    1. Load the images with `docker load < ./examples/redis_cluster/output/redis-master.tar && docker load < ./examples/redis_cluster/output/redis-replica.tar && docker load < ./examples/redis_cluster/output/redis-sentinel.tar`
    2. Start the cluster with `docker compose -f ./examples/redis_cluster/output/docker-compose.yml up`
