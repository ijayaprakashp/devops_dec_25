# 03 · Validate — Require Requests & Limits

- **What** · rejects Pods whose containers lack CPU/memory **requests and limits**.
- **Why** · no requests → bad scheduling and early eviction; no limits → one pod can starve the node.
- **When** · core capacity-governance / multi-tenant fairness control.

> 💡 **Live hook:** The "noisy neighbour." No limits → one runaway pod eats the node's RAM and evicts everyone else. No requests → the scheduler is flying blind. This policy makes both impossible.

### Key mechanics
- The `pattern` walks `spec.containers[].resources` and asserts each of `requests.cpu/memory` and `limits.cpu/memory` is non-empty (`"?*"`).
- A pattern on a **list** (`containers`) applies to **every** element by default.

### Files
- [policy.yaml](policy.yaml) · [test-pods.yaml](test-pods.yaml) (`sized-pod` has resources, `unsized-pod` doesn't)

### Test
```bash
kubectl apply -f policy.yaml
kubectl apply -f test-pods.yaml
```
**Verified:**
```
pod/sized-pod created
resource Pod/kyverno-demo/unsized-pod was blocked due to the following policies (require-requests-limits)
```

### Interview points
- Kyverno validates the **Pod**, but most workloads are Deployments — Kyverno automatically evaluates the **pod template** inside controllers too, so the failure surfaces at `kubectl apply` of the Deployment.
- A nice complement is a **`LimitRange`** (defaults) + this policy (mandate) — LimitRange fills gaps, Kyverno guarantees nothing slips through.
