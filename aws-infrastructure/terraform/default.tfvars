# general

region               = "us-east-2"
prefix               = "infra"
environment          = "infra"
network_enabled      = true
vpc_cidr             = "172.31.0.0/16"
az_count             = 2
az_count_network     = 2
public_subnet_cidrs  = ["172.31.0.0/24", "172.31.1.0/24", "172.31.2.0/24"]
private_subnet_cidrs = ["172.31.3.0/24", "172.31.4.0/24", "172.31.5.0/24"]
nat_subnet_cidr      = ["172.31.2.0/24"]
private              = true
private_nat          = false
key_path_public      = ""
key_path_private     = ""
key_name             = ""

# ipsec

ipsec_connections = [
  {
    name          = "infra"
    ip_address    = ""
    static_routes = []
  }
]

# tunnel 1 & tunnel 2 

tunnel1_preshared_key                = ""
tunnel1_inside_cidr                  = ""
tunnel1_ike_versions                 = ["ikev1", "ikev2"]
tunnel1_phase1_dh_group_numbers      = [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
tunnel1_phase1_encryption_algorithms = ["AES128", "AES128-GCM-16", "AES256", "AES256-GCM-16"]
tunnel1_phase1_integrity_algorithms  = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
tunnel1_phase2_dh_group_numbers      = [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
tunnel1_phase2_encryption_algorithms = ["AES128", "AES128-GCM-16", "AES256", "AES256-GCM-16"]
tunnel1_phase2_integrity_algorithms  = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
tunnel1_startup_action               = "start"

tunnel2_preshared_key                = ""
tunnel2_inside_cidr                  = ""
tunnel2_ike_versions                 = ["ikev1", "ikev2"]
tunnel2_phase1_dh_group_numbers      = [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
tunnel2_phase1_encryption_algorithms = ["AES128", "AES128-GCM-16", "AES256", "AES256-GCM-16"]
tunnel2_phase1_integrity_algorithms  = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
tunnel2_phase2_dh_group_numbers      = [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
tunnel2_phase2_encryption_algorithms = ["AES128", "AES128-GCM-16", "AES256", "AES256-GCM-16"]
tunnel2_phase2_integrity_algorithms  = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
tunnel2_startup_action               = "add"

# instances

external_ip_list = [
  "0.0.0.0/0"
]
external_port_list = [80, 443]
external_sg_list   = ""

ec2_instances = {
  nat_instance = {
    type      = "t2.micro"
    disk_size = 8
  }
  # test_instance = {
  #   type        = "t2.micro"
  #   disk_size   = 8
  # }
}
