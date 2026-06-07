# 02 · Validate — Disallow `:latest` Tag

- **What** · rejects Pods using `:latest` or an untagged image.
- **Why** · `:latest` is mutable → non-reproducible deploys, broken rollbacks, supply-chain risk.
- **When** · a baseline supply-chain / image-hygiene control on every cluster.

> 💡 **Live hook:** The "it worked yesterday" bug — `latest` got repushed overnight and now you can't even roll back (no old tag to return to). The bulletproof version pins a **digest** (`@sha256:...`), fully immutable.

### Key mechanics
- Two rules, both must pass:
  - `image: "*:*"` → the image **must have a tag** (untagged silently means `:latest`).
  - `image: "!*:latest"` → the tag **must not be** `latest` (`!` = negation).
- Wildcards (`*`, `?`, `!`) are Kyverno pattern operators, not regex.

### Files
- [policy.yaml](policy.yaml) · [test-pods.yaml](test-pods.yaml) (`pinned-pod` = `nginx:1.27-alpine`, `latest-pod` = `nginx:latest`)

### Test
```bash
kubectl apply -f policy.yaml
kubectl apply -f test-pods.yaml
```
**Verified:**
```
pod/pinned-pod created
resource Pod/kyverno-demo/latest-pod was blocked due to the following policies (disallow-latest-tag)
```

### Interview points
- The strongest version pins to a **digest** (`@sha256:...`), not just a tag — fully immutable.
- This is **validate**, so it only checks. To *force* a digest you'd combine with `verifyImages` or a mutate that resolves the tag.
- Untagged is the sneaky case — people forget the registry default is `:latest`, hence the explicit `*:*` rule.
