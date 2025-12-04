## 🎯 Lab Goal

Configure a self-healing deployment pipeline that automatically detects a high error rate using Prometheus metrics and aborts the rollout without human intervention.

## 📝 Overview & Concepts

In this lab, you will combine many concepts we've learned so far.

1.  **Define Success:** You will create an `AnalysisTemplate` that queries your local Prometheus instance. It will check if the application's Global Success Rate is above 90%.
2.  **Configure Automation:** You will attach this template to your `Rollout` strategy to run as a step in our canary release.
3.  **Simulate Failure:** You will generate synthetic traffic using a simple script. Then, you will deploy a "Bad" version of the application configured to throw random 500 errors.
4.  **Observe Self-Healing:** You will watch as Argo Rollouts detects the drop in success rate, marks the analysis as `Failed`, and automatically aborts the rollout, scaling the new faulty pods down to zero and restoring 100% traffic to the stable version.

## 📋 Lab Tasks

1.  **Setup:**
    1.  Create the `analysis-lab` namespace.
    2.  Configure the Pod template in the provided `rollout.yaml`, as well as the services within `services.yaml` with the necessary annotations for Prometheus to start scraping metrics. Metrics are exposed on the `/metrics` endpoint and the application is running on port `3000`.
    3.  Deploy the Rollout and the services.
2.  **Start Traffic Generation:** Run the provided `test-requests.sh` script in a separate terminal to generate continuous traffic for the `rollout-analysis` service.
    1.  Observe how metrics soon start showing up in the Prometheus dashboard.
3.  **Define Analysis:** Create an `analysis.yaml` file defining an `AnalysisTemplate` named `success-rate` in the `analysis-lab` namespace. It should query Prometheus to calculate the success rate (non-500 requests / total requests). You can use the following query for that:
    ```
    sum(rate(http_request_duration_seconds_count{code!~"5.*", service="{{args.service-name}}"}[1m]))
    /
    sum(rate(http_request_duration_seconds_count{service="{{args.service-name}}"}[1m]))
    ```
4.  Update your `rollout.yaml` to include an `analysis` step in the canary strategy.
    - Use the `analysis-lab` namespace.
    - Pause for 3 minutes after the first weight increase. This will allow for metrics to start flowing in.
    - Add an analysis step after this first increase referencing the `success-rate` analysis template.
5.  **Deploy the "Bad" Version:** Update `rollout.yaml` to set the `ERROR_RATE` environment variable to `0.5` (50% errors). Apply this change.
6.  **Watch the Dashboard:** Observe the rollout pause, the `AnalysisRun` start, and then quickly fail as Prometheus reports the errors.
7.  **Verify Rollback:** Confirm the status becomes `Degraded` (which means it aborted) and the Stable pods are taking 100% of the traffic again.

## 📚 Helpful Resources

- [Argo Rollouts - Analysis Configuration](https://argo-rollouts.readthedocs.io/en/stable/features/analysis/)
- [PromQL Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)

## 💭 Reflection Questions

1.  What is the difference between running an Analysis as a "background" step versus an inline "analysis" step?
2.  How does the `failureLimit` field in the AnalysisTemplate prevent a single blip from aborting the rollout?
3.  If the rollout aborts, what manual steps (if any) are required to "fix" the rollout state before trying again?
