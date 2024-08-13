  #!/bin/bash
  echo 1 > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -F
  iptables -t nat -A POSTROUTING -d IP -j SNAT --to-source IP
  iptables -t nat -A PREROUTING -d IP -j DNAT --to-destination IP