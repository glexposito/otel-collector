FROM otel/opentelemetry-collector:latest

COPY ./config/otel-config.yaml /etc/otelcol/config.yaml

EXPOSE 4317 4318

CMD ["--config", "/etc/otelcol/config.yaml"]