# Setting up Traefik with Kubernetes Gateway API on Minikube

This guide provides a step-by-step walkthrough for installing and configuring Traefik Proxy as a Kubernetes Gateway provider on Minikube, and setting up the Argo Rollouts Gateway API plugin.

**Note:** This setup uses HTTP only (no TLS) for simplicity.

## Prerequisites

- **Minikube**: A local Kubernetes cluster.
- **Kubectl**: Kubernetes command-line tool.
- **Helm**: Package manager for Kubernetes.

## Step 1: Start Minikube

Start your Minikube cluster.

```bash
minikube start
```

## Step 2: Install Gateway API CRDs

Traefik will be configured to use the Kubernetes Gateway API. The Custom Resource Definitions (CRDs) for Gateway API are not installed by default.

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/standard-install.yaml
```

## Step 3: Prepare Traefik Configuration

### 3.1 Add Helm Repository

Add the official Traefik Helm chart repository:

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update
```

### 3.2 Create Namespace

Create a dedicated namespace for Traefik:

```bash
kubectl create namespace traefik
```

### 3.3 Create `values.yaml`

Create a `values.yaml` file to configure Traefik. This configuration enables the Gateway API provider on HTTP port 80.

```yaml
# values.yaml
ports:
  web:
    port: 80
    nodePort: 30000
    # No redirection to HTTPS

api:
  dashboard: true
  insecure: true

ingressRoute:
  dashboard:
    enabled: true
    matchRule: Host(`dashboard.localhost`)
    entryPoints:
      - web

ingressClass:
  enabled: false

providers:
  kubernetesIngress:
    enabled: false
  kubernetesGateway:
    enabled: true

gateway:
  listeners:
    web:
      port: 80
      protocol: HTTP
      namespacePolicy:
        from: All

logs:
  access:
    enabled: true

metrics:
  prometheus:
    enabled: true
```

## Step 4: Install Traefik

Install Traefik using Helm and the custom values file:

```bash
helm upgrade traefik traefik/traefik \
  --version 37.4.0 \
  --namespace traefik \
  --create-namespace \
  --install \
  --values values/values-traefik.yaml
```

## Step 5: Deploy Demo Application

### 5.1 Deploy `whoami` App

Create a `whoami.yaml` file:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: whoami
  namespace: traefik
spec:
  replicas: 2
  selector:
    matchLabels:
      app: whoami
  template:
    metadata:
      labels:
        app: whoami
    spec:
      containers:
        - name: whoami
          image: traefik/whoami
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: whoami
  namespace: traefik
spec:
  selector:
    app: whoami
  ports:
    - port: 80
```

Apply it:

```bash
kubectl apply -f whoami.yaml
```

### 5.2 Create HTTPRoute

Create a `whoami-route.yaml` to route traffic via the Gateway:

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: whoami
  namespace: traefik
spec:
  parentRefs:
    - name: traefik-gateway
  hostnames:
    - 'whoami.localhost'
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: whoami
          port: 80
```

Apply it:

```bash
kubectl apply -f whoami-route.yaml
```

## Step 6: Access the Application

### 6.1 Start Minikube Tunnel

Traefik is deployed as a `LoadBalancer` service. To assign it an external IP on your local machine, you must run `minikube tunnel`.

**Open a new terminal window** and run:

```bash
minikube tunnel
```

_Note: This command requires `sudo` privileges and must remain running._

### 6.2 Verify Access

**macOS Users**: The domain `*.localhost` automatically resolves to `127.0.0.1`.

**Linux Users**: The domain `*.localhost` typically resolves to `127.0.0.1` by default on most distributions.

**Windows Users**: You may need to add entries to your `hosts` file (`C:\Windows\System32\drivers\etc\hosts`):

```
127.0.0.1 whoami.localhost
127.0.0.1 dashboard.localhost
```

1.  **Whoami App**: [http://whoami.localhost](http://whoami.localhost)
2.  **Traefik Dashboard**: [http://dashboard.localhost](http://dashboard.localhost)

## Step 7: Install Argo Rollouts Gateway API Plugin

To use Argo Rollouts with the Gateway API, you need to install the traffic router plugin.

### 7.1 Configure the Plugin

Update the Argo Rollouts values file to configure the Gateway API plugin via `initContainers`

```yaml
# values-rollouts.yaml
dashboard:
  enabled: true

# New: For configuring the Gateway API Plugin
# Source: https://rollouts-plugin-trafficrouter-gatewayapi.readthedocs.io/en/latest/installation/#installing-the-plugin-via-init-containers
controller:
  initContainers:
    - name: copy-gwapi-plugin
      image: ghcr.io/argoproj-labs/rollouts-plugin-trafficrouter-gatewayapi:v0.8.0
      command: ['/bin/sh', '-c']
      args:
        - cp /bin/rollouts-plugin-trafficrouter-gatewayapi /plugins
      volumeMounts:
        - name: gwapi-plugin
          mountPath: /plugins
  trafficRouterPlugins:
    - name: argoproj-labs/gatewayAPI
      location: 'file:///plugins/rollouts-plugin-trafficrouter-gatewayapi'
  volumes:
    - name: gwapi-plugin
      emptyDir: {}
  volumeMounts:
    - name: gwapi-plugin
      mountPath: /plugins
```

Upgrade the helm chart with:

```bash
helm upgrade argo-rollouts argo/argo-rollouts \
  --version 2.40.5 \
  --namespace argo-rollouts \
  --create-namespace \
  --install \
  --values values/values-rollouts.yaml
```

### 7.2 Restart Argo Rollouts

Restart the controller to load the plugin:

```bash
kubectl rollout restart deployment -n argo-rollouts argo-rollouts
```

### Troubleshooting

- **"Connection Refused"**: Ensure `minikube tunnel` is running.
- **"404 Not Found"**: Ensure the `HTTPRoute` is created and the `hostnames` match the URL you are visiting.

## Useful Resources

- [Traefik & Kubernetes with Gateway API](https://doc.traefik.io/traefik/reference/install-configuration/providers/kubernetes/kubernetes-gateway/)
- [Traefik Helm Chart](https://artifacthub.io/packages/helm/traefik/traefik)
- [Argo Rollouts Gateway API Plugin Installation Guide](https://rollouts-plugin-trafficrouter-gatewayapi.readthedocs.io/en/latest/installation/#installing-the-plugin-via-init-containers)
- [Traefik Kubernetes Setup](https://doc.traefik.io/traefik/setup/kubernetes/)
