output "ipsec" {
  value = length(var.ipsec_connections) < 1 ? null : {
    for i, conn in var.ipsec_connections : conn.name => {
      "tunnel1 ip" : module.ipsec[conn.name].tunnel1_address
      "tunnel2 ip" : module.ipsec[conn.name].tunnel2_address
    }
  }
}
