# OpenTelemetry Collector Docker Setup

This project provides a Dockerized setup for running the OpenTelemetry Collector with a custom configuration.

## Project Structure

- `Dockerfile`: Builds a container image for the OpenTelemetry Collector using the provided configuration.
- `config/otel-config.yaml`: Configuration file for the collector, including OTLP receivers and exporters for New Relic and debug output.

## Usage

1. **Build the Docker image:**
   ```sh
   docker build -t otel-collector .
   ```

2. **Run the container:**
   ```sh
   docker run -e NEW_RELIC_LICENSE_KEY=<your_new_relic_license_key> -p 4317:4317 -p 4318:4318 otel-collector
   ```

   Replace `<your_new_relic_license_key>` with your actual New Relic license key.

## Configuration

The collector is configured to:
- Receive telemetry data via OTLP over gRPC and HTTP.
- Export traces and metrics to New Relic and to a debug exporter.

See [`config/otel-config.yaml`](config/otel-config.yaml) for details.

## Ports

- `4317`: OTLP gRPC receiver
- `4318`: OTLP HTTP receiver

## References

- [OpenTelemetry Collector Documentation](https://opentelemetry.io/docs/collector/)
- [New Relic OTLP Ingest](https://docs.newrelic.com/docs/more-integrations/open-source-telemetry-integrations/opentelemetry/opentelemetry-setup/)