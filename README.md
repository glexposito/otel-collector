# otel-collector

A self-contained OpenTelemetry Collector image that fans out traces, metrics, and logs to both New Relic and a self-hosted SigNoz instance. The pipeline config is baked into the image (`config.yaml`), so the same image runs unchanged via `docker run`, Compose, ECS, Nomad, or Kubernetes — only runtime env vars differ per environment.

Deployment manifests (K8s, etc.) live in a separate repo; this one just builds and publishes the image.

## Build & push

A GitHub Actions workflow (`.github/workflows/build-and-push.yml`) builds and pushes the image to GHCR automatically on every push to `main` that touches `Dockerfile` or `config.yaml`. It tags both `:latest` and `:<git-sha>`, using the repo's own `GITHUB_TOKEN` — no extra secrets to set up.

Image: `ghcr.io/glexposito/otel-collector`.

**One-time step:** GHCR packages are created **private** by default even though `packages: write` was used to push. After the first successful workflow run, go to the package page (github.com/glexposito?tab=packages → otel-collector → Package settings) and change visibility to **Public**, otherwise anything pulling it elsewhere (K8s, etc.) will need an `imagePullSecret`.

To build locally instead:

```
docker build -t ghcr.io/glexposito/otel-collector:latest .
docker push ghcr.io/glexposito/otel-collector:latest
```

## Configs

- `config.yaml` (default) — traces, metrics, and logs to both New Relic and SigNoz.
- `config.dev.yaml` — metrics only, to SigNoz only. No New Relic exporter, no traces/logs pipelines. Both are baked into the same image; pick one with the container's `--config` arg.

## Runtime configuration (env vars, any platform)

- `NEW_RELIC_OTLP_ENDPOINT` — `otlp.nr-data.net:4317` (US) or `otlp.eu01.nr-data.net:4317` (EU, if your license key starts `eu01xx`) — `config.yaml` only
- `NEW_RELIC_LICENSE_KEY` — your New Relic ingest license key — `config.yaml` only
- `SIGNOZ_OTLP_ENDPOINT` — your SigNoz collector's OTLP gRPC address — both configs
- `SIGNOZ_OTLP_INSECURE` — `"true"` for plaintext, `"false"` if SigNoz's collector is behind TLS — both configs
- `DEPLOY_ENV` — value for the `deployment.environment`/`deployment.environment.name` resource attributes — both configs

## Run locally

Default (traces + metrics + logs, New Relic + SigNoz):

```
docker run --rm \
  -p 4317:4317 -p 4318:4318 -p 13133:13133 \
  -e NEW_RELIC_OTLP_ENDPOINT=otlp.nr-data.net:4317 \
  -e NEW_RELIC_LICENSE_KEY=... \
  -e SIGNOZ_OTLP_ENDPOINT=signoz-otel-collector:4317 \
  -e SIGNOZ_OTLP_INSECURE=true \
  -e DEPLOY_ENV=production \
  ghcr.io/glexposito/otel-collector:latest
```

Dev (metrics only, SigNoz only):

```
docker run --rm \
  -p 4317:4317 -p 4318:4318 -p 13133:13133 \
  -e SIGNOZ_OTLP_ENDPOINT=signoz-otel-collector:4317 \
  -e SIGNOZ_OTLP_INSECURE=true \
  ghcr.io/glexposito/otel-collector:latest \
  --config=/etc/otelcol-contrib/config.dev.yaml
```

## Sending data to it

Point your applications' OTLP exporters at the collector on port `4317` (gRPC) or `4318` (HTTP).

## Verify

- Health check: `curl localhost:13133`
- Collector logs: `docker logs -f <container>`
- Confirm data lands in both the New Relic UI and your SigNoz dashboard.
