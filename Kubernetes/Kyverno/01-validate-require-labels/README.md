# 01 · Validate — Require Labels (Enforce)

- **What** · rejects any Pod that doesn't carry a non-empty `team` label.
- **Why** · enforce org standards (ownership, cost-allocation, on-call routing) at the door.
- **When** · the "hello world" of Kyverno validation; the pattern behind most label/annotation governance.

> 💡 **Live hook:** The "who owns this pod at 3am?" problem. No `team` label → no on-call routing, no cost-allocation. Block it at the door so ownership is never optional.

### Key mechanics
- `kind: ClusterPolicy` → cluster-wide (a namespaced `Policy` would scope to one ns).
- `validationFailureAction: Enforce` → **block** non-compliant resources. `Audit` would only record a report.
- `validate.pattern` is declarative — `team: "?*"` means the label must exist and be non-empty (`?`=one char, `*`=zero+).
- `background: true` → also re-scans existing resources and writes a `PolicyReport`.

### Files
- [policy.yaml](policy.yaml) · [test-pods.yaml](test-pods.yaml) (`good-pod` labelled, `bad-pod` not)

### Test
```bash
kubectl create ns kyverno-demo
kubectl apply -f policy.yaml
kubectl apply -f test-pods.yaml
```
**Verified:**
```
pod/good-pod created
Error from server: ... admission webhook "validate.kyverno.svc-fail" denied the request:
resource Pod/kyverno-demo/bad-pod was blocked due to the following policies
require-team-label:
  check-team-label: 'validation error: Every Pod must have a 'team' label.'
```

### Interview points
- Validation runs in the **admission webhook** — the resource never reaches etcd, so it's true prevention, not after-the-fact.
- Use **`Audit` first** when rolling out to an existing cluster: see what *would* break via PolicyReports, then switch to `Enforce`.
- The `svc-fail` webhook name reflects the **failurePolicy: Fail** — if Kyverno is down, requests are denied (fail-closed).
