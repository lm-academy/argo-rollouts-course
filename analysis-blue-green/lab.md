## 🎯 Lab Goal

Perform a Blue-Green deployment that automatically validates the new version (Preview) using an `AnalysisRun` _before_ switching production traffic (Active) to it.

## 📝 Overview & Concepts

In a standard Blue-Green deployment, the new version (Green) is deployed alongside the old version (Blue). Usually, a human checks the "Preview" service and then manually promotes the rollout.

With **Pre-Promotion Analysis**, we can automate this. Argo Rollouts will:

1.  Deploy the new version (Green).
2.  Update the `previewService` to point to Green.
3.  **Automatically start an AnalysisRun**.
4.  **Block** the promotion to `activeService` until the analysis passes.
5.  If the analysis succeeds, it automatically switches the `activeService` to Green.
6.  If the analysis fails, it aborts the rollout.

## 📋 Lab Tasks

1.  **Define Services:** Create two services:
    - `blue-green-active`: For production traffic.
    - `blue-green-preview`: For the new version.
    - _Remember to add Prometheus annotations!_
2.  **Define Analysis:** Create an `analysis.yaml` (similar to the previous lab) that checks for a high success rate.
3.  **Define Rollout:** Create a `rollout.yaml` using the `blueGreen` strategy.
    - Configure `activeService` and `previewService`.
    - Add a `prePromotionAnalysis` block that references your analysis template.
    - Pass the **preview service name** as an argument to the analysis.
4.  **Deploy v1:** Apply the manifests and verify the active service points to v1.
5.  **Deploy v2:** Change the color and set an appropriate error rate to deploy a new version.
6.  **Generate Traffic:** **Crucial Step!** The analysis checks metrics on the _preview_ service. You must manually generate traffic to the preview service (using port-forwarding) so Prometheus has data to scrape.
7.  **Observe:** Watch the rollout wait for the analysis. Once the analysis passes, observe the automatic promotion.

## 📚 Helpful Resources

- [Argo Rollouts - BlueGreen Strategy](https://argo-rollouts.readthedocs.io/en/stable/features/bluegreen/)
- [Argo Rollouts - Pre-Promotion Analysis](https://argo-rollouts.readthedocs.io/en/stable/features/bluegreen/#prepromotionanalysis)

## 💭 Reflection Questions

1.  Why is it important to pass the `preview-service` name to the analysis arguments instead of the active service?
2.  What happens if you forget to generate traffic to the preview service during the analysis?
3.  How does this differ from the "Canary" analysis we did in the previous lab?
