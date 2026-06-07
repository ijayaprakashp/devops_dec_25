# 06 · Generate — Auto-create a default-deny NetworkPolicy

- **What** · whenever a new Namespace is created, Kyverno generates a default-deny-all `NetworkPolicy` inside it.
- **Why** · closes the gap where a fresh namespace is wide open until someone adds policies.
- **When** · platform guardrails / "secure landing zone" for every new namespace. Ties back to [`../../networkpolicy/01-default-deny-ingress`](../../networkpolicy/01-default-deny-ingress/).

> 💡 **Live hook:** Create a namespace → a default-deny NetworkPolicy appears in it automatically. Delete it to "cheat"... and Kyverno **puts it right back** (`synchronize: true`). Guardrails users can't quietly remove.

### Key mechanics
- `match` on `kind: Namespace` (create).
- `generate.data` holds the resource to create — here a deny-all NetworkPolicy (`podSelector: {}`, both policyTypes, no rules).
- `namespace: "{{request.object.metadata.name}}"` — a **JMESPath variable** placing the policy inside the just-created namespace.
- `synchronize: true` — if the generated object is deleted or drifts, Kyverno **recreates/reconciles** it (self-healing). Handled by the **background controller**.

### Files
- [policy.yaml](policy.yaml)

### Test
```bash
kubectl apply -f policy.yaml
kubectl create ns gen-test
kubectl -n gen-test get netpol
```
**Verified:**
```
NAME               POD-SELECTOR   AGE
default-deny-all   <none>         3s

# spec:
{"podSelector":{},"policyTypes":["Ingress","Egress"]}
```
Created automatically — no one applied a NetworkPolicy by hand.

### Interview points
- **Generate** is what makes Kyverno more than an admission validator — it's a lightweight controller that keeps derived resources in sync.
- Other classic generate uses: copy an image-pull `Secret` or a `ConfigMap` / `LimitRange` / `ResourceQuota` into every new namespace.
- `synchronize: true` vs `false`: with sync on, deleting the child brings it back — important so users can't quietly opt out of a guardrail.
- Generated resources are owned/tracked by Kyverno; deleting the **policy** can clean them up depending on `generateExisting`/retention settings.
