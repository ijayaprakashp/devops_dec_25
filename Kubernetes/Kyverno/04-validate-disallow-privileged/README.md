# 04 · Validate — Disallow Privileged Containers

- **What** · rejects Pods with a container running `securityContext.privileged: true`.
- **Why** · a privileged container has near-root access to the host → trivial container escape.
- **When** · a Pod Security "baseline/restricted" control; pairs with the `security_context` and PSA topics.

> 💡 **Live hook:** This is the same check PSA's `baseline` does for free — so why Kyverno? Because here you can **customize** it and add **exceptions** PSA can't (e.g. "allow it only for this one CNI namespace").

### Key mechanics
- `=(securityContext)` and `=(privileged)` are **existence anchors**: "*if* this field is present, it must match."
- So the rule reads: "if `privileged` is set, it must be `false`." A Pod with no `securityContext` passes (privileged defaults to false).

### Files
- [policy.yaml](policy.yaml) · [test-pods.yaml](test-pods.yaml) (`normal-pod` vs `privileged-pod`)

### Test
```bash
kubectl apply -f policy.yaml
kubectl apply -f test-pods.yaml
```
**Verified:**
```
pod/normal-pod created
resource Pod/kyverno-demo/privileged-pod was blocked due to the following policies (disallow-privileged-containers)
```

### Interview points
- This is one rule of many in the **Pod Security Standards**. Kyverno ships the whole PSS set as a ready policy pack — you rarely hand-write all of them.
- **Kyverno vs Pod Security Admission:** PSA enforces the fixed PSS levels at the namespace label; Kyverno is far more flexible (custom rules, mutate, generate, exceptions) — teams often run PSA for the baseline and Kyverno for everything bespoke.
- Don't forget `initContainers` and `ephemeralContainers` — a complete policy matches those too.
