storage "file" {
  path = "/vault/file"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"  # Disable TLS for local dev; enable for prod
}

ui = true  # Enable web UI
api_addr = "http://localhost:8200"
disable_mlock = true  # Avoid memory locking issues in Docker