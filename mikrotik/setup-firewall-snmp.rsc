# RouterOS 7 bootstrap. Review interface names and addresses before import.
# Run only from the router console or an authenticated ZeroTier management path.
:local monitoringSubnet "10.147.20.0/24"
:local snmpCommunity "CHANGE_ME_snmp_community"

/snmp set enabled=yes contact="network-admin" location="remote-site"
/snmp community add name=$snmpCommunity addresses=$monitoringSubnet read-access=yes write-access=no

# Permit SNMP only from the ZeroTier monitoring subnet; drop all other SNMP.
/ip firewall filter add chain=input action=accept protocol=udp dst-port=161 src-address=$monitoringSubnet comment="Allow SNMP from ZeroTier monitoring subnet"
/ip firewall filter add chain=input action=drop protocol=udp dst-port=161 comment="Deny SNMP outside monitoring subnet"

# Permit RouterOS API only if the optional mktxp exporter is enabled.
# Uncomment after replacing the source subnet and confirming API TLS requirements.
# /ip firewall filter add chain=input action=accept protocol=tcp dst-port=8728 src-address=$monitoringSubnet comment="Allow API from ZeroTier monitoring subnet"
