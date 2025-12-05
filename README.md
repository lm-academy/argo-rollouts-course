# Argo CD and Argo Rollouts for GitOps: The Definitive Guide

This repository contains the code and materials for the **Argo Rollouts** section of my **Argo CD & Argo Rollouts** course.

If you are looking for the **Argo CD** materials, please check the [Argo CD Repository](https://github.com/lm-academy/argocd-course).

### ➡️ Course link (with a big discount 🙂): [https://www.lauromueller.com/courses/argo-cd-rollouts](https://www.lauromueller.com/courses/argo-cd-rollouts)

### Check my other courses:

- 👉 [Prompt Engineering for Developers: The Definitive Guide](https://www.lauromueller.com/courses/prompt-engineering)
- 👉 [Python for DevOps: Mastering Real-World Automation](https://www.lauromueller.com/courses/python-devops)
- 👉 [The Complete Docker and Kubernetes Course: From Zero to Hero](https://www.lauromueller.com/courses/docker-kubernetes)
- 👉 [The Definitive Helm Course: From Beginner to Master](https://www.lauromueller.com/courses/definitive-helm-course)
- 👉 [Mastering Terraform: From Beginner to Expert](https://www.lauromueller.com/courses/mastering-terraform)
- 👉 [Mastering GitHub Actions: From Beginner to Expert](https://www.lauromueller.com/courses/mastering-github-actions)
- 👉 [Write better code: 20 code smells and how to get rid of them](https://www.lauromueller.com/courses/writing-clean-code)

## Welcome!

I'm thrilled to have you here! This repository contains all the code, examples, and supplementary materials for the Progressive Delivery portion of the course. My goal is to provide you with practical, real-world examples that will help you master Argo Rollouts on Kubernetes.

### 🔗 Further Course Materials

- [Argo CD Example Apps](https://github.com/lm-academy/argocd-example-apps)
- [Argo CD Example Apps Labs](https://github.com/lm-academy/argocd-example-apps-labs)
- [Argo CD Repository (Course Companion)](https://github.com/lm-academy/argocd-course)

## 🚀 Getting Started

To run the code examples, you'll need a Kubernetes cluster and some command-line tools installed.

### Prerequisites

1.  **Kubernetes Cluster**: You can use a local cluster like [Minikube](https://minikube.sigs.k8s.io/docs/start/), [Kind](https://kind.sigs.k8s.io/), or [Docker Desktop](https://docs.docker.com/desktop/kubernetes/).
2.  **kubectl**: The Kubernetes command-line tool. [Installation guide](https://kubernetes.io/docs/tasks/tools/).
3.  **Argo Rollouts CLI**: Command-line interface for Argo Rollouts. [Installation guide](https://argoproj.github.io/argo-rollouts/installation/#kubectl-plugin-installation).

### Repository Setup

1.  **Clone the Repository**

    ```bash
    git clone https://github.com/lm-academy/argo-rollouts-code.git
    cd argo-rollouts-code
    ```

## 📚 Repository Structure

This repository covers the following topics:

- **installing-argo-rollouts**: Introduction to Argo Rollouts. Installing the controller and the kubectl plugin.
- **first-rollout**: Rollouts Basics. Creating your first Rollout and understanding the difference from standard Deployments.
- **blue-green**: Rollout Strategies. Implementing Blue-Green deployments to switch traffic between active and preview environments.
- **canary**: Rollout Strategies. Implementing Canary deployments to gradually shift traffic to new versions.
- **traffic-weighting**: Advanced Traffic Management. Using traffic weighting for granular control over canary steps.
- **header-based-routing**: Implementing Header-Based Routing for targeted testing of canary revisions.
- **setup-gateway-api**: Setting up the Kubernetes Gateway API and Traefik to enable advanced traffic management features.
- **setup-prometheus**: Setting up Prometheus to collect metrics for analysis.
- **analysis-blue-green**: Implementing Analysis Runs for Blue-Green deployments to automate promotion based on metrics.
- **analysis-canary**: Implementing Analysis Runs for Canary deployments to automate promotion based on metrics.

I'm looking forward to seeing you in the course!
