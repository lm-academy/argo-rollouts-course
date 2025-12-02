## 🎯 Lab Goal

Configure and execute a Blue-Green deployment, allowing you to preview a new version of your application on a private service before atomically switching all production traffic to it.

## 📝 Overview & Concepts

In this lab, we will implement the Blue-Green strategy. Unlike the Canary strategy which gradually shifts traffic, Blue-Green creates a full parallel set of pods for the new version.

You will define two Kubernetes Services:

1.  **Active Service:** The public-facing service receiving live traffic.
2.  **Preview Service:** A private service used to test the new version.

You will trigger an update, observing how Argo Rollouts spins up the new version (Green) and points the Preview Service to it. You will then verify the Green version works using `kubectl port-forward` (simulating a QA test) while the Active Service remains untouched. Finally, you will promote the rollout to perform an instant cutover.

## 📋 Lab Tasks

### Part 1: Deploy Version 1 (Blue)

1.  Create a new namespace `bluegreen-lab`.
2.  Create a `services.yaml` file defining two services:
    - `rollout-bluegreen-active`: The main entry point for users.
    - `rollout-bluegreen-preview`: A service for testing the new version.
3.  Create a `rollout.yaml` file defining a Rollout with the `blueGreen` strategy.
    - **Image:** `lmacademy/simple-color-app:1.0.0`
    - **Env Var:** `APP_COLOR=blue`
    - **Strategy:** `blueGreen`
    - **Active Service:** `rollout-bluegreen-active`
    - **Preview Service:** `rollout-bluegreen-preview`
    - **AutoPromotionEnabled:** `false` (This forces a manual promotion).
4.  Apply the manifests to deploy **Version 1**.

### Part 2: Trigger Blue-Green Update

1.  Update the `rollout.yaml` to change the application color:
    - **Env Var:** `APP_COLOR=green`
2.  Apply the change.
3.  Use the `kubectl argo rollouts` dashboard or CLI to verify the rollout is paused. You should see a new ReplicaSet (Green) fully scaled up, but the Active Service still points to Blue.

### Part 3: Verify and Promote

1.  **Crucial Step:** Use `kubectl port-forward` to connect to the `preview` service and verify it is serving the new Green version.
    - _Tip: Forward the preview service to a different local port (e.g., 8081)._
2.  Verify the `active` service is still serving Blue.
3.  Promote the rollout to switch the `active` service to Green.
4.  Verify the old Blue replica set scales down after the successful cutover.

## 📚 Helpful Resources

- [Argo Rollouts - BlueGreen Strategy](https://argo-rollouts.readthedocs.io/en/stable/features/bluegreen/)
- [Kubectl Port-Forward](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)

## 💭 Reflection Questions

1.  What is the main trade-off of Blue-Green deployments regarding resource usage compared to Canary?
2.  Why is the `previewService` optional but highly recommended?
3.  What happens if you find a bug in the Green version before promoting? How do you abort?
