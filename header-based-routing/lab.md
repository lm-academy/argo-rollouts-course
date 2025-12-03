## 🎯 Lab Goal

Implement a Header-Based traffic split by configuring Argo Rollouts to route traffic to the new version based on a specific HTTP header, while keeping public traffic at a minimum.

## 📝 Overview & Concepts

In this lab, you will modify your Canary strategy to include a **header-based routing step**.

You will configure the rollout to look for the header `x-canary: true`. You will also use the `setCanaryScale` step to ensure there are actually pods running to handle this special traffic, even when the public traffic weight is set to a low value. You will verify this behavior using the `test-requests.sh` script available (use `--public` to simulate public access, and `--tester` to simulate adding the `x-canary` header).

## 📋 Lab Tasks

1.  **Reset** your `gateway-lab` environment to a clean state (deploy Version 1).
2.  **Modify** your `rollout.yaml` strategy to include a new first step:
    - Set a weight of 1% for traffic split.
    - Scale up the Canary ReplicaSet to a weight of `40` (ensure physical pods are running).
    - `setHeaderRoute`: Match header `x-canary` with value `true`.
    - `pause`: Pause indefinitely to allow for testing.
    - Continue with the promotion of traffic as before.
3.  **Apply** the changes and trigger an update to **Version 2**.
4.  **Verify Public Traffic:** Use the `test-requests` script with the `--public` flag to confirm standard users still see Version 1 most of the time.
5.  **Verify Test Traffic:** Use the `test-requests` script with the `--tester` flag (or use `curl -H "x-canary: true"`) to confirm you can access Version 2.
6.  **Promote** the rollout to proceed to the next steps and observe the shift.

## 📚 Helpful Resources

- [Argo Rollouts - Header Based Routing](https://argo-rollouts.readthedocs.io/en/stable/features/traffic-management/#traffic-routing-based-on-a-header-values-for-canary)
- [Argo Rollouts - setCanaryScale](https://argo-rollouts.readthedocs.io/en/stable/features/canary/#setcanaryscale)

## 💭 Reflection Questions

1.  Why is `setCanaryScale` necessary when doing header-based routing with small traffic weights?
2.  What happens to the header routing rule when the rollout moves to the next step or completes?
