# 05 · Mutate — Add a Default securityContext

- **What** · injects `spec.securityContext.seccompProfile.type: RuntimeDefault` into Pods that don't set it.
- **Why** · raise the security baseline automatically, without every team remembering to add it.
- **When** · platform-team "secure by default" defaults; the canonical Kyverno **mutate** use case.

> 💡 **Live hook:** The superpower validate can't give you — every pod gets hardened defaults and **developers never knew it happened**. Remember the order: mutate runs *before* validate.

### Key mechanics
- `mutate.patchStrategicMerge` describes the desired shape to merge in.
- `+(seccompProfile)` is the **add-if-not-present** anchor:
  - field absent → Kyverno adds it.
  - author already set it → Kyverno leaves their value alone (no clobbering).
- `background: false` — mutation happens at admission; it can't retroactively change existing Pods.

### Files
- [policy.yaml](policy.yaml) · [test-pods.yaml](test-pods.yaml) (`plain-pod` sets no securityContext)

### Test
```bash
kubectl apply -f policy.yaml
kubectl apply -f test-pods.yaml
kubectl -n kyverno-demo get pod plain-pod -o jsonpath='{.spec.securityContext}'
```
**Verified:**
```
{"seccompProfile":{"type":"RuntimeDefault"}}
```
The author supplied none — Kyverno added it.

### Interview points
- **Mutate runs before validate** in the admission chain, so a mutate can fix a resource enough to pass a later validate (e.g. add the default, then a validate confirms it).
- Why `seccompProfile` and not `runAsNonRoot`? Defaulting `runAsNonRoot: true` would **break** any image that runs as root (the pod won't start). seccompProfile is safe to default.
- Real platforms mutate lots of defaults this way: `imagePullPolicy`, drop-all capabilities, inject sidecars, copy labels from the namespace.
