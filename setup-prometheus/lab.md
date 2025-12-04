## 🎯 Lab Goal

Install a Prometheus instance into your Minikube cluster to serve as the metrics backend for Argo Rollouts' automated analysis.

## 📝 Overview & Concepts

To use Automated Analysis, Argo Rollouts needs a source of truth. It needs to ask a question like "What is the error rate?" and get a number back. That source of truth is a **Metrics Provider**.

In this lab, we will install **Prometheus**, the industry-standard open-source monitoring system. We will use the official community Helm chart to deploy it into a dedicated `monitoring` namespace. This will provide us with a running Prometheus server that scrapes metrics from our pods and an API that Argo Rollouts can query to make deployment decisions.

## 📋 Lab Tasks

1.  Add the `prometheus-community` Helm repository to your local Helm client.
2.  Create a dedicated namespace called `monitoring`.
3.  Install the `prometheus` chart version `27.49.0` into the `monitoring` namespace using the provided `values.yaml` file.
4.  Verify that the Prometheus Server pod is running.
5.  Access the Prometheus Web UI via the NodePort (or port-forwarding) and verify it is active.

## 📚 Helpful Resources

- [Prometheus Helm Charts](https://artifacthub.io/packages/helm/prometheus-community/prometheus)
- [Prometheus Overview](https://prometheus.io/docs/introduction/overview/)

## 💭 Reflection Questions

1.  How does Prometheus discover which pods to scrape metrics from? (Hint: Look for `scrape` annotations or ServiceMonitors).
2.  What is the internal DNS name that Argo Rollouts (running in the cluster) will use to talk to Prometheus?
