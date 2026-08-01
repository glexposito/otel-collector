FROM otel/opentelemetry-collector-contrib:latest

COPY config.yaml /etc/otelcol-contrib/config.yaml

ENTRYPOINT ["/otelcol-contrib"]
CMD ["--config=/etc/otelcol-contrib/config.yaml"]
