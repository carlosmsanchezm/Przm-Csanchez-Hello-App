# hello-app

Minimal FastAPI service packaged for container runtime with **rootless Podman**.
Publishes an OCI image to GHCR via GitHub Actions.

## Local (Podman)
```bash
# macOS: ensure the Podman VM is running
podman machine start

# Build & run
podman build -t hello-app:local .
podman run --rm -p 8080:8080 --read-only --tmpfs /tmp:rw,size=64m localhost/hello-app:local

# Test
curl -s http://localhost:8080/         # {"message":"Hello from your app!"}
curl -s http://localhost:8080/healthz  # {"status":"ok"}
```

## CI (GitHub Actions)

**On push to main**: build with Buildah, push to GHCR, Trivy scan (fail on HIGH/CRITICAL).

**On v* tag**: build & push SemVer tags `vX.Y.Z`, `vX.Y`, `vX`, plus `latest`.

**Image coordinates**: `ghcr.io/carlosmsanchezm/hello-app:<tag>`

## Release Flow

1. **Conventional commits** trigger Release Please
2. **Release Please** creates version bump PRs
3. **Merge PR** creates `v*` tag
4. **Tag trigger** publishes multi-tag container images

Example:
- `feat: add new endpoint` → minor version bump
- `fix: resolve bug` → patch version bump
- `feat!: breaking change` → major version bump

## Security

- **Non-root container** (user 10001:10001)
- **Read-only filesystem** with tmpfs for writable areas
- **Trivy vulnerability scanning** blocks HIGH/CRITICAL issues
- **Rootless Podman** for local development