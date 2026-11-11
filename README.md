# docker-image-template

Template repo for `clbsoldev` Docker images: build → content digest comparison
→ publish to GHCR (optionally Docker Hub), multi-arch (`linux/amd64,linux/arm64`).

## Creating a new image from this template

1. "Use this template" → create a new repo. Repo name = resulting image name
   (e.g. repo `syslog-logdy-server` → `ghcr.io/clbsoldev/syslog-logdy-server`).
   The workflow derives the image name from the repo name automatically —
   **`.github/workflows/build.yml` does not need to be changed for this.**
2. Replace the entire `image/` directory with your actual image.
3. Pin the base image by digest:
   ```bash
   docker buildx imagetools inspect <image>:<tag>
   ```
   Enter the *top-level* digest (manifest list, not `docker inspect` — that
   one only reflects the local host's architecture and would break arm64
   builds) into the Dockerfile.
4. Replace `Readme.md` and `Changelog.md` with project-specific content.
5. If Docker Hub should be used: set the repo variable `ENABLE_DOCKERHUB=true`,
   add `DOCKERHUB_USERNAME`/`DOCKERHUB_TOKEN` as secrets, and add a
   `short-description` to the `dockerhub-description` step in `build.yml`
   (that's project-specific text and can't be derived generically).

## How `build.yml` behaves

- **Image name**: derived automatically from the repo name, with a leading
  `docker-` prefix stripped if present (matches the `docker-<name>` repo
  naming convention, e.g. repo `docker-syslog-logdy-server` → image
  `ghcr.io/clbsoldev/syslog-logdy-server`). No workflow edit needed per repo.
- **Publish gate**: the `check` job hashes the built OCI tarball and compares
  it against `digest.txt` from the last run. Only if the content actually
  changed does `publish` run — so a weekly cron rebuild with no real change
  (e.g. base image unchanged) doesn't spam a new `:latest` push.
- **Docker Hub is off by default.** To enable it on a given repo: set the
  repo variable `ENABLE_DOCKERHUB=true` (Settings → Secrets and variables →
  Actions → Variables), and add `DOCKERHUB_USERNAME` / `DOCKERHUB_TOKEN` as
  secrets. Without the variable, both Docker Hub steps are skipped entirely
  — GHCR publishing always happens regardless of this toggle.

## Labels

`.github/labels.yml` is automatically synced to the repo on every push that
changes this file (`label-sync.yml`, via `micnncim/action-label-syncer`). Just
add/change labels there and push.

## Known limitation of "Use this template"

GitHub does **not** copy repository labels when using "Use this template" —
only files. That's what the separate `label-sync.yml` workflow is for: it
runs automatically on the first push to `main` in the new repo and creates
the labels from `labels.yml`, with no manual step required.
