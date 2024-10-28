resource "local_file" "nats_config_file" {
  filename = "${path.module}/nats-config/nats-config.conf"
  content  = <<EOF
port: 4222
max_payload: 8388608
websocket {
    port: 8222
    no_tls: true
}

jetstream {
    store_dir: "/data/nats-server/"
}

cluster {
    name: "JSC"
    listen: "0.0.0.0:4245"
    routes = ${jsonencode(local.nats_routes)}
}

authorization {
    users = [
      %{ for nkey in var.nats_seed ~}
        { nkey: ${nkey} },
      %{ endfor ~}
    ]
}
EOF
depends_on = [ aws_instance.db_ec2,aws_instance.nats_ec2 ]
}

