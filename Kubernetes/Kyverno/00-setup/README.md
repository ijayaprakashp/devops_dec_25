# 00 · Setup

Kyverno is already installed on this cluster (namespace `kyverno`, v1.18.1). For reference, this is how it was done:

```bash
# server-side apply is required — the CRDs are too large for client-side apply
kubectl apply --server-side -f https://github.com/kyverno/kyverno/releases/download/v1.18.1/install.yaml
kubectl -n kyverno rollout status deploy/kyverno-admission-controller
```

Kyverno runs as **four controllers**, each a separate deployment:
| Controller | Job |
|---|---|
| **admission** | the webhook — validates/mutates resources at create/update time |
| **background** | re-scans existing resources against policies; produces PolicyReports |
| **reports** | aggregates results into `PolicyReport` / `ClusterPolicyReport` |
| **cleanup** | runs `CleanupPolicy` (TTL-based resource deletion) |

A throwaway namespace used by the examples:
```bash
kubectl create ns kyverno-demo
```
