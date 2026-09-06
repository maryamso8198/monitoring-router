# 2026-08-29 12:31:05 by RouterOS 7.20.8
# software id = 7SKX-A1B7
#
# model = RB3011UiAS
# serial number = E7E60FE63C4B
/interface pptp-client
add connect-to=37.255.216.42 name=pptp-out-deplomat user=cepco
/interface bridge
add name=WAN-TCI port-cost-mode=short
add name=bridge port-cost-mode=short
/interface ethernet
set [ find default-name=ether1 ] comment="To Switch for Kerio "
set [ find default-name=ether2 ] comment=\
    "To Switch for Voip, Manage , Client"
set [ find default-name=ether3 ] comment="To Switch to Server"
set [ find default-name=ether4 ] comment="To Switch for Camera"
set [ find default-name=ether7 ] comment=Mokhaberat
set [ find default-name=ether8 ] comment="To Server for WAN BBB discannect"
set [ find default-name=ether9 ] comment=Shatel
/interface pppoe-client
add comment=Mokhaberat--Internet interface=ether7 max-mtu=1492 name=\
    pppoe-out2-Fiber user=3111337249
add comment="Mokhaberat-Internet " disabled=no interface=ether7 name=\
    pppoe-out3 user=3198998857
/interface ipip
add comment="Tunnel To Diplomat Office" local-address=37.255.236.73 name=\
    "IP IP TO DipLomat Office" remote-address=37.255.216.42
add comment="KimiaRoshd Main Office To Kimia051" disabled=yes local-address=\
    37.255.219.133 name="ipip-tunnel Mashad" remote-address=2.180.21.178
add comment=Shatel---Ip-Ip disabled=yes local-address=94.183.170.242 name=\
    ipip-tunnel1 remote-address=46.148.34.39
add comment="MOKHABERAT FIBER ---Ip-Ip" local-address=37.255.236.73 name=\
    ipip-tunnel2 remote-address=46.148.34.39
add disabled=yes local-address=37.255.219.133 name=ipip-tunnel3 \
    remote-address=85.133.161.190
add disabled=yes local-address=37.202.157.152 name=ipip-tunnel4 \
    remote-address=46.148.34.39
/interface gre
add !keepalive local-address=37.202.157.152 name=gre-tunnel1 remote-address=\
    85.15.21.68
add comment="To FAC-Shatel" local-address=37.202.157.152 name=gre-tunnel2 \
    remote-address=46.148.34.39
add comment="To Diplomat-Shatel" local-address=37.202.157.152 name=\
    gre-tunnel3 remote-address=37.255.216.42
/interface gre6
add disabled=yes local-address=fd22::115 name=gre6-tunnel1 remote-address=\
    fd22::114
/caps-man interface
add disabled=no mac-address=74:4D:28:4D:B9:BD master-interface=none name=cap1 \
    radio-mac=74:4D:28:4D:B9:BD radio-name=744D284DB9BD
/interface 6to4
add disabled=yes !keepalive local-address=37.255.219.133 name=6to4-tunnel1 \
    remote-address=45.88.8.64
/interface vlan
add comment="Internet Kerio" interface=ether1 name=VLAN16 vlan-id=16
add comment=LAN-Kerio interface=ether1 name=VLAN17 vlan-id=17
add comment=Camera interface=ether4 name=Vlan60 vlan-id=60
add comment=server interface=ether3 name=vlan20 vlan-id=20
add comment=Client interface=ether2 name=vlan21 vlan-id=21
add comment=Voip interface=ether2 name=vlan50 vlan-id=50
add comment=manag interface=ether2 name=vlan80 vlan-id=80
/caps-man datapath
add bridge=bridge name=datapath1
/caps-man security
add authentication-types=wpa-psk,wpa2-psk encryption=aes-ccm name=security1
/caps-man configuration
add channel.band=2ghz-b/g/n .extension-channel=Ce .reselect-interval=1d \
    country=iran datapath=datapath1 distance=indoors installation=indoor \
    mode=ap name=cfg-2.4 security=security1 ssid=KimiaRoshd
add channel.band=2ghz-b/g/n .extension-channel=Ce .reselect-interval=1d \
    country=iran datapath=datapath1 distance=indoors installation=indoor \
    mode=ap name=cfg-5.8 security=security1 ssid=KimiaRoshd
/caps-man interface
add configuration=cfg-2.4 disabled=no l2mtu=1600 mac-address=\
    04:F4:1C:4F:65:C7 master-interface=none name=AP-F0-1 radio-mac=\
    04:F4:1C:4F:65:C7 radio-name=04F41C4F65C7
add configuration=cfg-2.4 disabled=no mac-address=04:F4:1C:4F:64:FB \
    master-interface=none name=AP-F1-1 radio-mac=04:F4:1C:4F:64:FB \
    radio-name=04F41C4F64FB
add configuration=cfg-2.4 disabled=no mac-address=04:F4:1C:4F:63:6F \
    master-interface=none name=AP-F2-1 radio-mac=04:F4:1C:4F:63:6F \
    radio-name=04F41C4F636F
add configuration=cfg-2.4 disabled=no mac-address=CC:2D:E0:84:73:47 \
    master-interface=none name=AP01-1 radio-mac=CC:2D:E0:84:73:47 radio-name=\
    CC2DE0847347
add configuration=cfg-2.4 disabled=no mac-address=74:4D:28:4D:B9:BE \
    master-interface=none name=ap00-1 radio-mac=74:4D:28:4D:B9:BE radio-name=\
    744D284DB9BE
/interface list
add name=WAN
/interface lte apn
set [ find default=yes ] ip-type=ipv4 use-network-apn=no
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip hotspot profile
add hotspot-address=192.168.21.1 login-by=http-chap name=hsprof1
/ip hotspot user profile
set [ find default=yes ] shared-users=2
add name=admins shared-users=10
/ip pool
add name=dhcp_pool5 ranges=192.168.21.50-192.168.21.254
add name=VPN-Pool-User ranges=172.16.21.50-172.16.21.80
add name=OVpn ranges=172.16.10.10-172.16.10.20
add name=VPN-Pool-CRM ranges=172.16.21.30-172.16.21.40
add name=OVpn-Transport ranges=172.16.20.10-172.16.20.20
/ip dhcp-server
add address-pool=dhcp_pool5 disabled=yes interface=vlan21 lease-time=1w1d10m \
    name=dhcp1
/ip hotspot
add address-pool=dhcp_pool5 interface=bridge name=hotspot1 profile=hsprof1
/ip smb users
set [ find default=yes ] disabled=yes
/port
set 0 name=serial0
/ppp profile
add dns-server=192.168.20.20 local-address=172.16.21.1 name=Vpn-profile-User \
    remote-address=VPN-Pool-User
add dns-server=8.8.8.8,1.1.1.1 local-address=172.16.10.1 name=Ovpn \
    remote-address=OVpn
add dns-server=192.168.20.20 local-address=172.16.21.1 name=Vpn-Profile-CRM \
    remote-address=VPN-Pool-CRM
add dns-server=8.8.8.8,1.1.1.1 local-address=172.16.20.1 name=\
    Ovpn-Profile-Transport remote-address=OVpn-Transport
set *FFFFFFFE dns-server=8.8.8.8,1.1.1.1
/queue simple
add dst=ipip-tunnel3 max-limit=50000000/50000000 name=queue1 queue=\
    default/default target=192.168.21.110/32 total-queue=default
add dst=pppoe-out2-Fiber max-limit=50000000/50000000 name=queue2 queue=\
    default/default target=192.168.21.110/32 total-queue=default
/routing table
add disabled=no fib name=vpn
add disabled=no fib name=Fibr-internet
add disabled=no fib name=Shatel
/system logging action
add name=cepcon8n remote=37.255.245.162 remote-port=51400 target=remote
/user group
add name=hotspot policy="read,write,winbox,!local,!telnet,!ssh,!ftp,!reboot,!p\
    olicy,!test,!password,!web,!sniff,!sensitive,!api,!romon,!rest-api"
add name=n8n policy="ssh,read,write,!local,!telnet,!ftp,!reboot,!policy,!test,\
    !winbox,!password,!web,!sniff,!sensitive,!api,!romon,!rest-api"
/caps-man manager
set ca-certificate=CAPsMAN-CA-DC2C6E9B92CC certificate=CAPsMAN-DC2C6E9B92CC \
    enabled=yes
/caps-man provisioning
add action=create-enabled hw-supported-modes=gn master-configuration=cfg-2.4 \
    name-format=identity
/interface bridge port
add bridge=bridge disabled=yes interface=ether3 internal-path-cost=10 \
    path-cost=10
add bridge=bridge disabled=yes interface=ether4 internal-path-cost=10 \
    path-cost=10
add bridge=bridge interface=ether5 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether6 internal-path-cost=10 path-cost=10
add bridge=WAN-TCI disabled=yes interface=ether8 internal-path-cost=10 \
    path-cost=10
add bridge=bridge disabled=yes interface=vlan21
/ip firewall connection tracking
set udp-timeout=10s
/ip neighbor discovery-settings
set discover-interface-list=!dynamic
/ip settings
set max-neighbor-entries=8192
/ipv6 settings
set max-neighbor-entries=8192 soft-max-neighbor-entries=8191
/interface l2tp-server server
set enabled=yes use-ipsec=required
/interface list member
add disabled=yes interface=pppoe-out2-Fiber list=WAN
add interface=ipip-tunnel3 list=WAN
add interface=ether9 list=WAN
add interface=pppoe-out3 list=WAN
/interface ovpn-server server
add auth=sha1 certificate=server-certificate cipher=\
    blowfish128,aes128-cbc,aes256-cbc default-profile=Ovpn disabled=no \
    mac-address=FE:B1:58:F3:18:63 name=ovpn-server1 port=55005 \
    require-client-certificate=yes
/interface pptp-server server
# PPTP connections are considered unsafe, it is suggested to use a more modern VPN protocol instead
set authentication=pap,chap,mschap1,mschap2
/interface sstp-server server
set default-profile=default-encryption port=44333
/ip address
add address=172.16.50.2/24 comment=Voip interface=vlan50 network=172.16.50.0
add address=192.168.20.1/24 comment=server interface=vlan20 network=\
    192.168.20.0
add address=10.10.10.2/30 interface=vlan21 network=10.10.10.0
add address=192.168.70.2/30 interface=ipip-tunnel2 network=192.168.70.0
add address=37.255.219.133/30 interface=WAN-TCI network=37.255.219.132
add address=192.168.15.2/30 interface="ipip-tunnel Mashad" network=\
    192.168.15.0
add address=192.168.40.2/30 interface="IP IP TO DipLomat Office" network=\
    192.168.40.0
add address=10.3.1.2/30 disabled=yes interface=*22 network=10.3.1.0
add address=10.20.30.2/30 interface=ipip-tunnel3 network=10.20.30.0
add address=192.192.192.14/30 interface=gre6-tunnel1 network=192.192.192.12
add address=172.16.16.1/30 comment="Kerio WAN" interface=VLAN16 network=\
    172.16.16.0
add address=172.16.17.1/30 comment=Kerio-LAN interface=VLAN17 network=\
    172.16.17.0
add address=192.168.60.1/24 comment=Camera interface=Vlan60 network=\
    192.168.60.0
add address=192.168.80.1/24 comment=manage interface=vlan80 network=\
    192.168.80.0
add address=172.24.53.226/30 interface=gre-tunnel1 network=172.24.53.224
add address=172.24.53.229/30 interface=vlan50 network=172.24.53.228
add address=192.168.70.5/30 interface=gre-tunnel2 network=192.168.70.4
add address=192.168.40.5/30 interface=gre-tunnel3 network=192.168.40.4
add address=192.168.3.1/24 comment=Shatel interface=ether9 network=\
    192.168.3.0
add address=192.168.8.10/24 comment=Mokhaberat interface=ether7 network=\
    192.168.8.0
/ip cloud
set ddns-enabled=yes
/ip dhcp-client
add add-default-route=no default-route-tables=main disabled=yes interface=\
    ether2 use-peer-dns=no use-peer-ntp=no
add add-default-route=no default-route-tables=main interface=ether9
/ip dhcp-relay
add dhcp-server=192.168.21.1 disabled=no interface=vlan21 name=relay1
/ip dhcp-server lease
add address=192.168.21.252 client-id=1:f0:92:1c:e6:51:a7 mac-address=\
    F0:92:1C:E6:51:A7 server=dhcp1
add address=192.168.21.251 client-id=1:cc:2d:e0:84:73:42 mac-address=\
    CC:2D:E0:84:73:42 server=dhcp1
add address=192.168.21.249 client-id=1:74:4d:28:4d:b9:b8 mac-address=\
    74:4D:28:4D:B9:B8 server=dhcp1
add address=192.168.21.241 client-id=1:2c:44:fd:21:1e:e0 mac-address=\
    2C:44:FD:21:1E:E0 server=dhcp1
add address=192.168.21.237 client-id=1:24:be:5:1c:ef:8d mac-address=\
    24:BE:05:1C:EF:8D server=dhcp1
add address=192.168.21.234 client-id=1:44:37:e6:89:f0:5 mac-address=\
    44:37:E6:89:F0:05 server=dhcp1
add address=192.168.21.232 client-id=1:a0:48:1c:87:45:24 mac-address=\
    A0:48:1C:87:45:24 server=dhcp1
add address=192.168.21.226 client-id=1:dc:b7:2e:40:7a:c2 mac-address=\
    DC:B7:2E:40:7A:C2 server=dhcp1
add address=192.168.21.225 client-id=1:7c:fd:6b:a8:48:7 mac-address=\
    7C:FD:6B:A8:48:07 server=dhcp1
add address=192.168.21.215 client-id=1:2c:44:fd:31:d5:93 mac-address=\
    2C:44:FD:31:D5:93 server=dhcp1
add address=192.168.21.51 client-id=1:de:ea:d6:9:0:1 mac-address=\
    DE:EA:D6:09:00:01 server=dhcp1
add address=192.168.21.83 client-id=1:d8:5e:d3:92:8a:40 mac-address=\
    D8:5E:D3:92:8A:40 server=dhcp1
add address=192.168.21.134 client-id=1:a0:36:bc:28:51:35 mac-address=\
    A0:36:BC:28:51:35 server=dhcp1
add address=192.168.21.109 client-id=1:28:c5:d2:57:ce:c mac-address=\
    28:C5:D2:57:CE:0C server=dhcp1
add address=192.168.21.88 client-id=1:e8:9c:25:43:8:28 mac-address=\
    E8:9C:25:43:08:28 server=dhcp1
add address=192.168.21.96 client-id=1:e8:9c:25:43:a:50 mac-address=\
    E8:9C:25:43:0A:50 server=dhcp1
add address=192.168.21.73 client-id=1:0:e0:4c:36:b:3d mac-address=\
    00:E0:4C:36:0B:3D server=dhcp1
add address=192.168.21.63 client-id=1:1c:ce:51:43:9b:55 mac-address=\
    1C:CE:51:43:9B:55 server=dhcp1
add address=192.168.21.189 client-id=1:10:7c:61:79:dd:c5 mac-address=\
    10:7C:61:79:DD:C5 server=dhcp1
add address=192.168.21.124 client-id=1:c0:35:32:74:c2:b3 mac-address=\
    C0:35:32:74:C2:B3 server=dhcp1
add address=192.168.21.102 client-id=1:e8:9c:25:43:69:b8 mac-address=\
    E8:9C:25:43:69:B8 server=dhcp1
add address=192.168.21.216 client-id=1:3c:52:82:47:b6:4d mac-address=\
    3C:52:82:47:B6:4D server=dhcp1
add address=192.168.21.107 client-id=1:14:ab:c5:d:95:1c mac-address=\
    14:AB:C5:0D:95:1C server=dhcp1
add address=192.168.21.161 client-id=1:f8:54:f6:63:82:45 mac-address=\
    F8:54:F6:63:82:45 server=dhcp1
add address=192.168.21.148 client-id=1:d8:5e:d3:d9:3c:27 mac-address=\
    D8:5E:D3:D9:3C:27 server=dhcp1
add address=192.168.21.201 client-id=1:10:5f:ad:86:22:7f mac-address=\
    10:5F:AD:86:22:7F server=dhcp1
add address=192.168.21.52 client-id=1:44:37:e6:88:60:81 mac-address=\
    44:37:E6:88:60:81 server=dhcp1
add address=192.168.21.104 client-id=1:4c:5f:70:41:9e:4d mac-address=\
    4C:5F:70:41:9E:4D server=dhcp1
add address=192.168.21.76 client-id=1:f8:54:f6:63:82:b mac-address=\
    F8:54:F6:63:82:0B server=dhcp1
add address=192.168.21.166 client-id=1:c4:c6:e6:75:ab:63 mac-address=\
    C4:C6:E6:75:AB:63 server=dhcp1
add address=192.168.21.92 client-id=1:10:5f:ad:bf:74:94 mac-address=\
    10:5F:AD:BF:74:94 server=dhcp1
add address=192.168.21.128 client-id=1:c0:35:32:74:88:b1 mac-address=\
    C0:35:32:74:88:B1 server=dhcp1
add address=192.168.21.129 client-id=1:c4:c6:e6:75:aa:88 mac-address=\
    C4:C6:E6:75:AA:88 server=dhcp1
add address=192.168.21.66 client-id=1:10:5f:ad:bf:67:15 mac-address=\
    10:5F:AD:BF:67:15 server=dhcp1
add address=192.168.21.112 client-id=1:c4:c6:e6:77:95:e1 mac-address=\
    C4:C6:E6:77:95:E1 server=dhcp1
add address=192.168.21.117 client-id=1:c4:c6:e6:8d:e8:e4 mac-address=\
    C4:C6:E6:8D:E8:E4 server=dhcp1
add address=192.168.21.95 client-id=1:66:88:61:a:7a:0 mac-address=\
    66:88:61:0A:7A:00 server=dhcp1
add address=192.168.21.144 client-id=1:0:17:61:11:a6:12 comment=\
    "Attendance Device" mac-address=00:17:61:11:A6:12 server=dhcp1
/ip dhcp-server network
add address=192.168.21.0/24 caps-manager=192.168.21.1 dns-server=\
    192.168.20.20,8.8.8.8,1.1.1.1 gateway=192.168.21.1 next-server=\
    192.168.20.25 ntp-server=192.168.21.1
/ip dns
set allow-remote-requests=yes servers=192.168.20.20,10.104.88.8,10.104.88.9
/ip dns static
add address=188.213.75.32 name=tax.gov.ir type=A
add address=77.104.79.20 name=tax.gov.ir type=A
/ip firewall address-list
add address=192.168.20.0/24 disabled=yes list=InterNetUsers
add address=192.168.21.0/24 disabled=yes list=InterNetUsers
add address=91.108.56.0/23 list=telegram
add address=91.108.56.0/22 list=telegram
add address=91.108.4.0/22 list=telegram
add address=67.198.55.0/24 list=telegram
add address=149.154.172.0/22 list=telegram
add address=149.154.168.0/22 list=telegram
add address=149.154.164.0/22 list=telegram
add address=149.154.160.0/22 list=telegram
add address=109.239.140.0/24 list=telegram
add address=91.108.8.0/22 list=telegram
add address=95.161.64.0/20 list=telegram
add address=web.telegram.org list=telegram
add address=telegra.ph list=telegram
add address=tmacos.com list=telegram
add address=stel.com list=telegram
add address=telegram.org list=telegram
add address=tx.me list=telegram
add address=telega.one list=telegram
add address=192.168.21.0/24 list=local
add address=8.8.8.8 list=telegram
add address=4.2.2.4 list=telegram
add address=1.1.1.1 list=telegram
add address=core.telegram.org list=telegram
add address=desktop.telegram.org list=telegram
add address=208.117.224.0/24 list=Youtube1
add address=208.117.225.0/24 list=Youtube1
add address=208.117.228.0/24 list=Youtube1
add address=208.117.229.0/24 list=Youtube1
add address=208.117.232.0/24 list=Youtube1
add address=208.117.233.0/24 list=Youtube1
add address=208.117.234.0/24 list=Youtube1
add address=208.117.238.0/24 list=Youtube1
add address=208.65.152.0/24 list=Youtube1
add address=208.65.153.0/24 list=Youtube1
add address=208.65.154.0/24 list=Youtube1
add address=64.15.112.0/20 list=Youtube1
add address=208.117.236.0/24 list=Youtube1
add address=74.125.96.0/19 list=Youtube1
add address=72.14.221.0/24 list=Youtube1
add address=84.53.128.0/18 list=Youtube1
add address=87.248.192.0/19 list=Youtube1
add address=216.155.128.0/19 list=Youtube1
add address=208.73.208.0/21 list=Youtube1
add address=66.55.140.0/23 list=Youtube1
add address=74.125.208.0/24 list=Youtube1
add address=199.223.239.0/24 list=Youtube1
add address=207.223.160.0/24 list=Youtube1
add address=207.223.161.0/24 list=Youtube1
add address=207.223.162.0/24 list=Youtube1
add address=207.223.163.0/24 list=Youtube1
add address=207.223.164.0/24 list=Youtube1
add address=207.223.165.0/24 list=Youtube1
add address=207.223.166.0/24 list=Youtube1
add address=207.223.167.0/24 list=Youtube1
add address=207.223.168.0/24 list=Youtube1
add address=207.223.169.0/24 list=Youtube1
add address=207.223.170.0/24 list=Youtube1
add address=207.223.171.0/24 list=Youtube1
add address=207.223.172.0/24 list=Youtube1
add address=207.223.173.0/24 list=Youtube1
add address=207.223.174.0/24 list=Youtube1
add address=207.223.175.0/24 list=Youtube1
add address=172.217.17.238 list=Youtube1
add address=youtube.com list=Youtube1
add address=208.117.226.0/24 list=Youtube1
add address=208.117.227.0/24 list=Youtube1
add address=208.117.230.0/24 list=Youtube1
add address=208.117.231.0/24 list=Youtube1
add address=208.117.235.0/24 list=Youtube1
add address=208.117.237.0/24 list=Youtube1
add address=208.117.239.0/24 list=Youtube1
add address=208.117.240.0/24 list=Youtube1
add address=208.117.241.0/24 list=Youtube1
add address=208.117.242.0/24 list=Youtube1
add address=208.117.243.0/24 list=Youtube1
add address=208.117.244.0/24 list=Youtube1
add address=208.117.245.0/24 list=Youtube1
add address=208.117.246.0/24 list=Youtube1
add address=208.117.247.0/24 list=Youtube1
add address=208.117.248.0/24 list=Youtube1
add address=208.117.249.0/24 list=Youtube1
add address=208.117.250.0/24 list=Youtube1
add address=208.117.251.0/24 list=Youtube1
add address=208.117.252.0/24 list=Youtube1
add address=208.117.253.0/24 list=Youtube1
add address=208.117.254.0/24 list=Youtube1
add address=208.117.255.0/24 list=Youtube1
add address=209.85.128.0/24 list=Youtube1
add address=209.85.129.0/24 list=Youtube1
add address=209.85.130.0/24 list=Youtube1
add address=209.85.131.0/24 list=Youtube1
add address=209.85.132.0/24 list=Youtube1
add address=209.85.133.0/24 list=Youtube1
add address=209.85.134.0/24 list=Youtube1
add address=209.85.135.0/24 list=Youtube1
add address=209.85.136.0/24 list=Youtube1
add address=209.85.137.0/24 list=Youtube1
add address=209.85.138.0/24 list=Youtube1
add address=209.85.139.0/24 list=Youtube1
add address=209.85.140.0/24 list=Youtube1
add address=209.85.141.0/24 list=Youtube1
add address=209.85.142.0/24 list=Youtube1
add address=209.85.143.0/24 list=Youtube1
add address=209.85.144.0/24 list=Youtube1
add address=209.85.145.0/24 list=Youtube1
add address=209.85.146.0/24 list=Youtube1
add address=209.85.147.0/24 list=Youtube1
add address=209.85.148.0/24 list=Youtube1
add address=209.85.149.0/24 list=Youtube1
add address=209.85.150.0/24 list=Youtube1
add address=209.85.151.0/24 list=Youtube1
add address=209.85.152.0/24 list=Youtube1
add address=209.85.153.0/24 list=Youtube1
add address=209.85.154.0/24 list=Youtube1
add address=209.85.155.0/24 list=Youtube1
add address=209.85.156.0/24 list=Youtube1
add address=209.85.157.0/24 list=Youtube1
add address=209.85.158.0/24 list=Youtube1
add address=209.85.159.0/24 list=Youtube1
add address=209.85.160.0/24 list=Youtube1
add address=209.85.161.0/24 list=Youtube1
add address=209.85.162.0/24 list=Youtube1
add address=209.85.163.0/24 list=Youtube1
add address=209.85.164.0/24 list=Youtube1
add address=209.85.165.0/24 list=Youtube1
add address=209.85.166.0/24 list=Youtube1
add address=209.85.167.0/24 list=Youtube1
add address=209.85.168.0/24 list=Youtube1
add address=209.85.169.0/24 list=Youtube1
add address=209.85.170.0/24 list=Youtube1
add address=209.85.171.0/24 list=Youtube1
add address=209.85.172.0/24 list=Youtube1
add address=209.85.173.0/24 list=Youtube1
add address=209.85.174.0/24 list=Youtube1
add address=209.85.175.0/24 list=Youtube1
add address=209.85.176.0/24 list=Youtube1
add address=209.85.177.0/24 list=Youtube1
add address=209.85.178.0/24 list=Youtube1
add address=209.85.179.0/24 list=Youtube1
add address=209.85.180.0/24 list=Youtube1
add address=209.85.181.0/24 list=Youtube1
add address=209.85.182.0/24 list=Youtube1
add address=209.85.183.0/24 list=Youtube1
add address=209.85.184.0/24 list=Youtube1
add address=209.85.185.0/24 list=Youtube1
add address=209.85.186.0/24 list=Youtube1
add address=209.85.187.0/24 list=Youtube1
add address=209.85.188.0/24 list=Youtube1
add address=209.85.189.0/24 list=Youtube1
add address=209.85.190.0/24 list=Youtube1
add address=209.85.191.0/24 list=Youtube1
add address=209.85.192.0/24 list=Youtube1
add address=209.85.193.0/24 list=Youtube1
add address=209.85.194.0/24 list=Youtube1
add address=209.85.195.0/24 list=Youtube1
add address=209.85.196.0/24 list=Youtube1
add address=209.85.197.0/24 list=Youtube1
add address=209.85.198.0/24 list=Youtube1
add address=209.85.199.0/24 list=Youtube1
add address=209.85.200.0/24 list=Youtube1
add address=209.85.201.0/24 list=Youtube1
add address=209.85.202.0/24 list=Youtube1
add address=209.85.203.0/24 list=Youtube1
add address=209.85.204.0/24 list=Youtube1
add address=209.85.205.0/24 list=Youtube1
add address=209.85.206.0/24 list=Youtube1
add address=209.85.207.0/24 list=Youtube1
add address=209.85.208.0/24 list=Youtube1
add address=209.85.209.0/24 list=Youtube1
add address=209.85.210.0/24 list=Youtube1
add address=209.85.211.0/24 list=Youtube1
add address=209.85.212.0/24 list=Youtube1
add address=209.85.213.0/24 list=Youtube1
add address=209.85.214.0/24 list=Youtube1
add address=209.85.215.0/24 list=Youtube1
add address=209.85.216.0/24 list=Youtube1
add address=209.85.217.0/24 list=Youtube1
add address=209.85.218.0/24 list=Youtube1
add address=209.85.219.0/24 list=Youtube1
add address=209.85.220.0/24 list=Youtube1
add address=209.85.221.0/24 list=Youtube1
add address=209.85.222.0/24 list=Youtube1
add address=209.85.223.0/24 list=Youtube1
add address=209.85.224.0/24 list=Youtube1
add address=209.85.225.0/24 list=Youtube1
add address=209.85.226.0/24 list=Youtube1
add address=209.85.227.0/24 list=Youtube1
add address=209.85.228.0/24 list=Youtube1
add address=209.85.229.0/24 list=Youtube1
add address=209.85.230.0/24 list=Youtube1
add address=209.85.231.0/24 list=Youtube1
add address=209.85.232.0/24 list=Youtube1
add address=209.85.233.0/24 list=Youtube1
add address=209.85.234.0/24 list=Youtube1
add address=209.85.235.0/24 list=Youtube1
add address=209.85.236.0/24 list=Youtube1
add address=209.85.237.0/24 list=Youtube1
add address=209.85.238.0/24 list=Youtube1
add address=209.85.239.0/24 list=Youtube1
add address=209.85.240.0/24 list=Youtube1
add address=209.85.241.0/24 list=Youtube1
add address=209.85.242.0/24 list=Youtube1
add address=209.85.243.0/24 list=Youtube1
add address=209.85.244.0/24 list=Youtube1
add address=209.85.245.0/24 list=Youtube1
add address=209.85.246.0/24 list=Youtube1
add address=209.85.247.0/24 list=Youtube1
add address=209.85.248.0/24 list=Youtube1
add address=209.85.249.0/24 list=Youtube1
add address=209.85.250.0/24 list=Youtube1
add address=209.85.251.0/24 list=Youtube1
add address=209.85.252.0/24 list=Youtube1
add address=209.85.253.0/24 list=Youtube1
add address=209.85.254.0/24 list=Youtube1
add address=209.85.255.0/24 list=Youtube1
add address=216.58.192.0/24 list=Youtube1
add address=216.58.193.0/24 list=Youtube1
add address=216.58.194.0/24 list=Youtube1
add address=216.58.195.0/24 list=Youtube1
add address=216.58.196.0/24 list=Youtube1
add address=216.58.197.0/24 list=Youtube1
add address=216.58.198.0/24 list=Youtube1
add address=216.58.199.0/24 list=Youtube1
add address=216.58.200.0/24 list=Youtube1
add address=216.58.201.0/24 list=Youtube1
add address=216.58.202.0/24 list=Youtube1
add address=216.58.203.0/24 list=Youtube1
add address=216.58.204.0/24 list=Youtube1
add address=216.58.205.0/24 list=Youtube1
add address=216.58.206.0/24 list=Youtube1
add address=216.58.207.0/24 list=Youtube1
add address=216.58.208.0/24 list=Youtube1
add address=216.58.209.0/24 list=Youtube1
add address=216.58.219.0/24 list=Youtube1
add address=216.58.218.0/24 list=Youtube1
add address=216.58.217.0/24 list=Youtube1
add address=216.58.216.0/24 list=Youtube1
add address=216.58.215.0/24 list=Youtube1
add address=216.58.214.0/24 list=Youtube1
add address=216.58.213.0/24 list=Youtube1
add address=216.58.212.0/24 list=Youtube1
add address=216.58.211.0/24 list=Youtube1
add address=216.58.210.0/24 list=Youtube1
add address=216.58.220.0/24 list=Youtube1
add address=216.58.221.0/24 list=Youtube1
add address=216.58.222.0/24 list=Youtube1
add address=216.58.223.0/24 list=Youtube1
add address=216.239.57.0/24 list=Youtube1
add address=216.239.56.0/24 list=Youtube1
add address=216.239.55.0/24 list=Youtube1
add address=216.239.54.0/24 list=Youtube1
add address=216.239.36.0/24 list=Youtube1
add address=216.239.37.0/24 list=Youtube1
add address=216.239.38.0/24 disabled=yes list=Youtube1
add address=216.239.39.0/24 list=Youtube1
add address=216.239.40.0/24 list=Youtube1
add address=216.239.41.0/24 list=Youtube1
add address=216.239.42.0/24 list=Youtube1
add address=216.239.43.0/24 list=Youtube1
add address=216.239.46.0/24 list=Youtube1
add address=216.239.47.0/24 list=Youtube1
add address=216.239.48.0/24 list=Youtube1
add address=216.239.49.0/24 list=Youtube1
add address=216.239.51.0/24 list=Youtube1
add address=216.239.50.0/24 list=Youtube1
add address=216.239.35.0/24 list=Youtube1
add address=216.239.34.0/24 list=Youtube1
add address=216.239.52.0/24 list=Youtube1
add address=216.239.33.0/24 list=Youtube1
add address=216.239.32.0/24 list=Youtube1
add address=216.239.59.0/24 list=Youtube1
add address=216.239.58.0/24 list=Youtube1
add address=216.239.60.0/24 list=Youtube1
add address=216.239.61.0/24 list=Youtube1
add address=216.239.53.0/24 list=Youtube1
add address=216.239.63.0/24 list=Youtube1
add address=216.239.62.0/24 list=Youtube1
add address=31.13.64.51 list=WhatsApp
add address=31.13.65.49 list=WhatsApp
add address=31.13.66.49 list=WhatsApp
add address=31.13.67.51 list=WhatsApp
add address=31.13.68.52 list=WhatsApp
add address=31.13.69.240 list=WhatsApp
add address=31.13.70.49 list=WhatsApp
add address=31.13.71.49 list=WhatsApp
add address=31.13.72.52 list=WhatsApp
add address=31.13.73.49 list=WhatsApp
add address=31.13.74.49 list=WhatsApp
add address=31.13.75.52 list=WhatsApp
add address=31.13.76.81 list=WhatsApp
add address=31.13.77.49 list=WhatsApp
add address=31.13.78.53 list=WhatsApp
add address=31.13.80.53 list=WhatsApp
add address=31.13.81.53 list=WhatsApp
add address=31.13.82.51 list=WhatsApp
add address=31.13.83.51 list=WhatsApp
add address=31.13.84.51 list=WhatsApp
add address=31.13.85.51 list=WhatsApp
add address=31.13.86.51 list=WhatsApp
add address=31.13.87.51 list=WhatsApp
add address=31.13.88.49 list=WhatsApp
add address=31.13.90.51 list=WhatsApp
add address=31.13.91.51 list=WhatsApp
add address=31.13.92.52 list=WhatsApp
add address=31.13.93.51 list=WhatsApp
add address=31.13.94.52 list=WhatsApp
add address=31.13.95.63 list=WhatsApp
add address=50.22.198.204/30 list=WhatsApp
add address=50.22.210.32/30 list=WhatsApp
add address=50.22.210.128/27 list=WhatsApp
add address=50.22.225.64/27 list=WhatsApp
add address=50.22.235.248/30 list=WhatsApp
add address=50.22.240.160/27 list=WhatsApp
add address=50.23.90.128/27 list=WhatsApp
add address=50.97.57.128/27 list=WhatsApp
add address=75.126.39.32/27 list=WhatsApp
add address=108.168.171.224/27 list=WhatsApp
add address=108.168.174.0/27 list=WhatsApp
add address=108.168.176.192/26 list=WhatsApp
add address=108.168.177.0/27 list=WhatsApp
add address=108.168.180.96/27 list=WhatsApp
add address=108.168.254.65 list=WhatsApp
add address=108.168.255.224 list=WhatsApp
add address=108.168.255.227 list=WhatsApp
add address=157.240.0.53 list=WhatsApp
add address=157.240.1.53 list=WhatsApp
add address=157.240.2.53 list=WhatsApp
add address=157.240.3.53 list=WhatsApp
add address=157.240.6.53 list=WhatsApp
add address=157.240.7.54 list=WhatsApp
add address=157.240.8.53 list=WhatsApp
add address=157.240.9.53 list=WhatsApp
add address=157.240.10.53 list=WhatsApp
add address=157.240.11.53 list=WhatsApp
add address=157.240.12.53 list=WhatsApp
add address=158.85.0.96/27 list=WhatsApp
add address=158.85.5.192/27 list=WhatsApp
add address=158.85.46.128/27 list=WhatsApp
add address=158.85.48.224/27 list=WhatsApp
add address=158.85.58.0/25 list=WhatsApp
add address=158.85.61.192/27 list=WhatsApp
add address=158.85.224.160/27 list=WhatsApp
add address=158.85.233.32/27 list=WhatsApp
add address=158.85.249.128/27 list=WhatsApp
add address=158.85.254.64/27 list=WhatsApp
add address=169.44.23.192/27 list=WhatsApp
add address=169.44.36.0/25 list=WhatsApp
add address=169.44.57.64/27 list=WhatsApp
add address=169.44.58.64/27 list=WhatsApp
add address=169.44.80.0/26 list=WhatsApp
add address=169.44.82.96/27 list=WhatsApp
add address=169.44.82.128/27 list=WhatsApp
add address=169.44.82.192/26 list=WhatsApp
add address=169.44.83.0/26 list=WhatsApp
add address=169.44.83.96/27 list=WhatsApp
add address=169.44.83.128/27 list=WhatsApp
add address=169.44.83.192/26 list=WhatsApp
add address=169.44.84.0/24 list=WhatsApp
add address=169.44.85.64/27 list=WhatsApp
add address=169.44.87.160/27 list=WhatsApp
add address=169.44.167.0/27 list=WhatsApp
add address=169.45.71.32/27 list=WhatsApp
add address=169.45.71.96/27 list=WhatsApp
add address=169.45.87.128/26 list=WhatsApp
add address=169.45.169.192/27 list=WhatsApp
add address=169.45.182.96/27 list=WhatsApp
add address=169.45.210.64/27 list=WhatsApp
add address=169.45.214.224/27 list=WhatsApp
add address=169.45.219.224/27 list=WhatsApp
add address=169.45.237.192/27 list=WhatsApp
add address=169.45.238.32/27 list=WhatsApp
add address=169.45.248.96/27 list=WhatsApp
add address=169.45.248.160/27 list=WhatsApp
add address=169.46.52.224/27 list=WhatsApp
add address=169.46.111.144/28 list=WhatsApp
add address=169.47.5.192/26 list=WhatsApp
add address=169.47.6.64/27 list=WhatsApp
add address=169.47.33.128/27 list=WhatsApp
add address=169.47.35.32/27 list=WhatsApp
add address=169.47.37.128/27 list=WhatsApp
add address=169.47.40.128/27 list=WhatsApp
add address=169.47.42.96/27 list=WhatsApp
add address=169.47.42.160/27 list=WhatsApp
add address=169.47.42.192/26 list=WhatsApp
add address=169.47.47.160/27 list=WhatsApp
add address=169.47.130.96/27 list=WhatsApp
add address=169.47.192.192/27 list=WhatsApp
add address=169.47.194.128/27 list=WhatsApp
add address=169.47.198.128/27 list=WhatsApp
add address=169.47.212.160/27 list=WhatsApp
add address=169.53.29.128/27 list=WhatsApp
add address=169.53.48.32/27 list=WhatsApp
add address=169.53.71.224/27 list=WhatsApp
add address=169.53.81.64/27 list=WhatsApp
add address=169.53.250.128/26 list=WhatsApp
add address=169.53.252.64/27 list=WhatsApp
add address=169.53.255.64/27 list=WhatsApp
add address=169.54.2.160/27 list=WhatsApp
add address=169.54.44.224/27 list=WhatsApp
add address=169.54.51.32/27 list=WhatsApp
add address=169.54.55.192/27 list=WhatsApp
add address=169.54.193.160/27 list=WhatsApp
add address=169.54.210.0/27 list=WhatsApp
add address=169.54.222.128/27 list=WhatsApp
add address=169.55.67.224/27 list=WhatsApp
add address=169.55.69.128/26 list=WhatsApp
add address=169.55.74.32/27 list=WhatsApp
add address=169.55.75.96/27 list=WhatsApp
add address=169.55.100.160/27 list=WhatsApp
add address=169.55.126.64/26 list=WhatsApp
add address=169.55.210.96/27 list=WhatsApp
add address=169.55.235.160/27 list=WhatsApp
add address=173.192.162.32/27 list=WhatsApp
add address=173.192.219.128/27 list=WhatsApp
add address=173.192.222.160/27 list=WhatsApp
add address=173.192.231.32/27 list=WhatsApp
add address=173.193.205.0/27 list=WhatsApp
add address=173.193.230.96/27 list=WhatsApp
add address=173.193.230.128/27 list=WhatsApp
add address=173.193.230.192/27 list=WhatsApp
add address=173.193.239.0/27 list=WhatsApp
add address=174.36.208.128/27 list=WhatsApp
add address=174.36.210.32/27 list=WhatsApp
add address=174.36.251.192/27 list=WhatsApp
add address=174.37.199.192/27 list=WhatsApp
add address=174.37.217.64/27 list=WhatsApp
add address=174.37.243.64/27 list=WhatsApp
add address=174.37.251.0/27 list=WhatsApp
add address=179.60.192.51 list=WhatsApp
add address=179.60.195.51 list=WhatsApp
add address=208.43.122.128/27 list=WhatsApp
add address=208.43.117.79 list=WhatsApp
add address=208.43.115.192/27 list=WhatsApp
add address=198.23.80.0/27 list=WhatsApp
add address=198.11.251.32/27 list=WhatsApp
add address=198.11.193.182/31 list=WhatsApp
add address=192.155.212.192/27 list=WhatsApp
add address=185.60.219.53 list=WhatsApp
add address=185.60.218.53 list=WhatsApp
add address=185.60.216.53 list=WhatsApp
add address=184.173.179.32/27 list=WhatsApp
add address=184.173.173.116 list=WhatsApp
add address=184.173.161.64 list=WhatsApp
add address=184.173.147.32/27 list=WhatsApp
add address=184.173.136.64/27 list=WhatsApp
add address=192.168.20.0/24 list=local
add address=192.168.10.0/24 list=local
add address=192.168.1.0/24 list=local
add address=172.16.50.0/24 list=local
add address=172.22.22.0/30 list=local
add address=srv.mfw.ir comment=vpn-server disabled=yes list=IranianIP
add address=2.144.0.0/14 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=2.176.0.0/12 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.22.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.22.192.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.23.112.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.34.192.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.52.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.53.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.56.128.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.57.32.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.61.24.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.62.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.62.192.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.63.8.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.72.0.0/15 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.74.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.75.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.78.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.104.208.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.106.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.112.0.0/12 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.134.128.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.134.192.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.144.128.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.145.112.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.159.48.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.160.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.182.44.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.190.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.198.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.200.64.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.200.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.201.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.202.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.208.0.0/12 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.226.48.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.232.0.0/13 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.250.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.252.216.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.253.24.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=5.253.96.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.2.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.7.64.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.7.128.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.14.80.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.14.112.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.14.144.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.24.200.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.24.232.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.25.88.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.25.104.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.25.128.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.25.232.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.29.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.40.0.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.47.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.56.0.0/14 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.130.176.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.170.48.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.171.216.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.184.128.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.193.112.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.193.144.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.214.132.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.214.146.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.214.154.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.214.168.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.214.200.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.214.228.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.214.248.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=31.217.208.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.9.248.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.10.64.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.10.109.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.10.117.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.19.80.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.27.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.32.0.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.32.32.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.32.112.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.44.56.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.49.144.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.63.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.75.240.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.98.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.114.192.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.128.240.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.129.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.130.200.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.137.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.143.144.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.148.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.148.248.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.152.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.153.128.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.153.176.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.156.0.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.156.8.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.156.16.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.156.48.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.156.100.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.156.112.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.156.128.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.156.144.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.156.152.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.156.160.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.156.176.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.156.212.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.156.232.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.156.240.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.156.248.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.191.64.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.202.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.221.0.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.228.131.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.228.133.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.228.135.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.228.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.235.16.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.254.0.0/15 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=45.8.160.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=45.9.144.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=45.9.252.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=45.65.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.18.248.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.21.80.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.28.72.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.32.0.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.34.96.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.34.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.36.96.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.38.128.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.41.192.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.51.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.62.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.100.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.102.120.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.102.128.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.102.184.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.143.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.143.192.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.148.32.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.164.64.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.167.128.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.182.32.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.209.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.224.0.0/15 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.235.76.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.245.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.248.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.249.120.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.251.224.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.251.226.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.251.237.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=46.255.216.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=62.60.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=62.102.128.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=62.193.0.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=62.220.96.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=66.79.96.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=77.36.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=77.42.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=77.77.64.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=77.81.32.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=77.81.76.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=77.81.80.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=77.81.128.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=77.81.144.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=77.81.192.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=77.104.64.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=77.237.64.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=77.237.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=77.238.104.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=77.238.112.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=77.245.224.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=78.31.232.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=78.38.0.0/15 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=78.109.192.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=78.110.112.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=78.111.0.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=78.154.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=78.157.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=78.158.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=79.127.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=79.132.192.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=79.174.160.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=79.175.128.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=80.66.176.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=80.71.112.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=80.75.0.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=80.191.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=80.210.0.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=80.210.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=80.242.0.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=80.249.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=80.250.192.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=80.253.128.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=81.12.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=81.16.112.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=81.28.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=81.29.240.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=81.31.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=81.31.224.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=81.90.144.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=81.91.128.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=81.163.0.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=82.97.240.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=82.99.192.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=82.115.0.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=82.115.8.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=82.115.12.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=82.115.14.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=82.115.16.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=83.120.0.0/14 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=83.147.192.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=83.150.192.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=84.47.192.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=84.241.0.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=85.9.64.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=85.15.0.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=85.133.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=85.185.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=85.198.0.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=85.204.30.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=85.204.76.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=85.204.80.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=85.204.104.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=85.204.128.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=85.204.208.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=85.208.252.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=85.239.192.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.55.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.57.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.104.32.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.104.80.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.104.96.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.104.232.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.104.240.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.105.40.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.105.128.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.106.24.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.106.142.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.106.192.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.107.0.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.107.80.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.107.144.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.107.172.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.107.208.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=86.109.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=87.107.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=87.248.128.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=87.251.128.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=88.135.32.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.32.0.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.32.96.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.32.196.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.32.248.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.33.18.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.33.100.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.33.128.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.33.204.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.33.234.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.33.240.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.34.20.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.34.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.34.88.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.34.94.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.34.128.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.34.168.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.34.176.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.34.200.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.34.248.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.35.58.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.35.64.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.35.120.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.35.132.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.35.156.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.35.176.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.35.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.35.194.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.36.16.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.36.48.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.36.96.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.36.176.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.36.194.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.36.226.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.36.252.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.37.0.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.37.30.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.37.42.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.37.102.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.37.144.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.37.152.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.37.168.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.37.198.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.37.208.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.37.218.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.37.240.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.38.24.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.38.80.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.38.102.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.38.184.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.38.192.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.38.242.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.38.244.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.39.8.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.39.186.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.39.208.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.40.38.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.40.78.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.40.90.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.40.106.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.40.110.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.40.128.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.40.152.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.40.240.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.41.8.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.41.16.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.41.32.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.41.40.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.41.58.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.41.192.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.41.240.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.42.32.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.42.56.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.42.68.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.42.96.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.42.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.42.150.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.42.184.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.42.196.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.42.208.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.42.228.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.43.0.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.43.36.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.43.70.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.43.88.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.43.96.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.43.144.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.43.182.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.43.188.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.43.204.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.43.216.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.43.224.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.44.112.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.44.118.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.44.128.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.44.146.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.44.176.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.44.190.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.44.202.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.45.48.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.45.68.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.45.80.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.45.112.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.45.126.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.45.152.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.45.230.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.46.44.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.46.60.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.46.94.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.46.184.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.46.216.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.47.64.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.47.128.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.47.196.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.47.200.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.144.128.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.165.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.196.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.198.0.0/15 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.219.64.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.219.192.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.221.80.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=89.235.64.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.104.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.114.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.121.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.122.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.124.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.129.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.130.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.132.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.145.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.146.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.148.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.156.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.164.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.172.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.184.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.192.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.204.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.208.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.220.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.228.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.231.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.92.236.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.98.0.0/15 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.106.64.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.108.128.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.109.104.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.133.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.147.64.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.184.64.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.185.128.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.186.192.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.190.88.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.206.122.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.207.138.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.208.165.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.209.242.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.212.16.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.212.252.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.216.4.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.217.64.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.220.79.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.222.196.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.222.204.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.224.110.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.224.176.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.225.52.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.226.224.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.227.84.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.228.189.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.229.214.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.230.32.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.232.64.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.232.68.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.232.72.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.233.56.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.236.168.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.237.254.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.238.0.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.239.14.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.239.54.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.239.108.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.239.214.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.240.60.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.240.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.241.20.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.241.92.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.242.44.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.243.126.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.243.160.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.244.120.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.245.228.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.247.66.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.250.224.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=91.251.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=92.42.48.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=92.43.160.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=92.50.0.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=92.61.176.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=92.114.16.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=92.114.64.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=92.119.56.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=92.119.68.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=92.242.192.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=92.246.144.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=92.246.156.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=92.249.56.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.88.64.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.110.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.113.224.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.114.16.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.114.104.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.115.120.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.115.144.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.115.216.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.115.224.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.117.0.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.117.32.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.117.96.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.117.176.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.118.96.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.118.128.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.118.160.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.118.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.118.184.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.119.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.119.64.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.119.208.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.126.0.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=93.190.24.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.24.0.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.24.16.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.24.80.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.24.96.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.74.128.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.101.120.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.101.128.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.101.176.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.101.240.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.139.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.176.8.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.176.16.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.176.32.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.177.72.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.182.0.0/15 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.184.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.199.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.232.168.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=94.241.128.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.38.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.64.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.80.128.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.81.64.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.82.0.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.130.56.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.130.240.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.142.224.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.156.222.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.156.233.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.156.234.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.156.236.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.156.248.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.156.252.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.162.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.214.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.215.160.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=95.215.173.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=103.215.220.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=103.216.60.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=103.231.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.72.192.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.74.224.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.94.164.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.95.56.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.95.64.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.108.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.109.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.110.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.111.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.122.192.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.125.128.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.162.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.201.0.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.203.128.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.206.252.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.225.128.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.230.64.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.230.192.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.230.200.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.230.204.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.230.221.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.230.223.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.230.242.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.230.246.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.230.251.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.232.0.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.238.176.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=109.239.0.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=113.203.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=128.65.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=130.185.72.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=130.255.192.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=134.255.196.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=134.255.200.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=134.255.245.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=134.255.246.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=134.255.248.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=146.66.128.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=151.232.0.0/14 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=151.238.0.0/15 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=151.240.0.0/13 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=152.89.12.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=152.89.44.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=152.89.152.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=157.119.100.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=157.119.188.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=158.58.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=158.58.184.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=159.20.96.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=164.138.16.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=164.138.128.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=164.215.56.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=164.215.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=172.80.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.12.64.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.46.128.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.56.144.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.62.144.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.65.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.65.192.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.67.64.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.101.32.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.101.48.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.102.224.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.110.108.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.112.192.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.122.210.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.123.64.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.124.64.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.221.16.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.221.64.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=176.223.80.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.21.40.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.21.160.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.22.72.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.22.120.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.131.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.157.0.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.157.4.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.169.0.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.173.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.215.0.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.216.248.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.219.224.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.236.32.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.236.96.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.238.192.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.239.144.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.248.40.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.251.208.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.252.128.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=178.253.0.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.1.77.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.2.12.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.3.124.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.3.200.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.3.212.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.4.0.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.4.16.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.4.28.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.4.104.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.4.220.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.5.156.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.8.172.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.10.71.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.10.72.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.11.68.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.11.88.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.11.176.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.12.60.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.12.100.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.13.228.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.14.80.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.14.160.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.16.232.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.18.156.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.18.212.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.20.160.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.21.68.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.21.76.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.22.28.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.23.128.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.24.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.24.148.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.24.228.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.24.252.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.25.172.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.26.32.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.26.232.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.29.220.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.30.4.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.30.76.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.31.124.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.32.128.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.34.160.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.37.52.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.39.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.40.240.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.41.0.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.41.220.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.42.24.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.42.212.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.42.224.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.44.36.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.44.100.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.44.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.45.188.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.46.0.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.46.108.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.46.216.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.47.48.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.49.84.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.49.96.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.49.104.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.50.37.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.50.38.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.51.40.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.51.200.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.53.140.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.55.224.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.56.92.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.56.96.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.57.132.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.57.164.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.57.200.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.58.240.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.59.112.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.60.32.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.60.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.62.232.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.63.236.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.64.176.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.66.224.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.67.12.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.67.100.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.67.156.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.67.212.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.69.108.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.69.120.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.70.60.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.70.196.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.71.152.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.71.192.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.72.24.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.72.80.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.73.0.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.73.76.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.73.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.74.164.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.75.196.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.75.204.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.76.248.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.78.20.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.78.104.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.79.60.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.79.96.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.79.156.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.80.100.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.80.196.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.81.40.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.81.96.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.82.28.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.82.64.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.82.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.82.164.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.82.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.83.28.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.83.72.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.83.80.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.83.88.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.83.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.83.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.83.184.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.83.196.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.83.200.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.83.208.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.84.160.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.84.220.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.85.68.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.85.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.86.36.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.86.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.88.48.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.88.152.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.88.176.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.88.252.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.89.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.92.4.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.92.8.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.92.40.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.93.164.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.94.96.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.95.60.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.95.152.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.95.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.96.240.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.97.116.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.98.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.99.212.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.100.44.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.101.228.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.103.84.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.103.128.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.103.244.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.103.248.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.104.192.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.104.228.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.104.232.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.104.240.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.105.100.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.105.120.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.105.184.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.105.236.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.106.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.106.144.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.106.200.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.106.228.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.107.28.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.107.32.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.107.244.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.107.248.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.108.96.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.108.164.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.109.60.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.109.72.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.109.80.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.109.128.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.109.244.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.109.248.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.110.28.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.110.216.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.110.228.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.110.236.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.110.244.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.110.252.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.111.8.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.111.64.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.111.80.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.111.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.112.32.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.112.128.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.112.148.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.112.168.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.113.56.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.113.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.114.72.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.114.188.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.115.76.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.115.148.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.115.164.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.115.168.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.116.20.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.116.24.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.116.44.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.116.160.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.117.48.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.117.96.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.117.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.117.204.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.118.12.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.118.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.118.152.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.119.4.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.119.164.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.119.240.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.120.120.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.120.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.120.160.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.120.168.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.120.192.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.120.200.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.120.208.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.120.224.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.120.240.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.120.248.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.121.56.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.121.128.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.122.80.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.123.68.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.123.208.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.124.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.124.156.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.124.172.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.125.20.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.125.244.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.125.248.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.126.0.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.126.16.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.126.40.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.126.124.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.126.132.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.126.144.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.126.156.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.126.200.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.127.232.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.128.48.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.128.80.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.128.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.128.152.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.128.164.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.129.80.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.129.108.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.129.116.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.129.124.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.129.140.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.129.168.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.129.184.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.129.196.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.129.200.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.129.212.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.129.216.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.129.228.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.129.232.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.129.240.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.130.76.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.131.28.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.131.84.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.131.88.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.131.100.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.131.108.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.131.112.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.131.124.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.131.128.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.131.136.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.131.148.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.131.152.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.131.164.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.131.168.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.132.80.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.132.212.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.133.152.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.133.164.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.134.96.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.135.28.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.135.72.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.135.84.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.135.228.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.136.100.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.136.172.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.136.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.136.192.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.136.220.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.137.24.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.137.60.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.137.108.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.139.64.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.140.4.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.140.12.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.140.56.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.140.232.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.140.240.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.141.36.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.141.48.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.141.104.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.141.132.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.141.168.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.141.212.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.141.244.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.142.92.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.142.124.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.142.156.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.142.232.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.143.72.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.143.204.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.143.232.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.144.64.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.145.8.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.145.184.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.147.40.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.147.84.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.147.160.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.147.176.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.148.12.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.150.108.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.151.96.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.151.236.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.153.184.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.153.208.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.154.184.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.155.8.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.155.72.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.155.236.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.156.44.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.157.8.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.158.172.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.159.84.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.159.88.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.159.152.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.159.176.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.160.104.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.160.176.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.161.36.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.161.68.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.161.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.162.40.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.162.216.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.163.88.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.164.72.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.164.252.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.165.28.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.165.40.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.165.100.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.165.116.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.165.204.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.166.60.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.166.104.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.166.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.167.52.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.167.72.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.167.100.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.167.124.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.168.28.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.169.20.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.170.236.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.171.52.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.172.0.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.172.68.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.172.212.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.173.104.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.173.168.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.174.132.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.174.200.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.174.248.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.175.76.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.175.240.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.176.32.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.176.56.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.177.156.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.178.104.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.178.220.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.179.168.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.179.220.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.180.52.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.180.128.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.181.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.182.220.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.182.248.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.183.128.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.184.32.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.184.48.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.185.16.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.185.240.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.186.48.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.186.240.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.187.48.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.187.84.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.188.104.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.188.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.189.120.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.190.20.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.191.76.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.192.8.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.192.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.193.208.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.194.76.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.194.244.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.195.72.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.196.148.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.197.68.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.197.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.198.160.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.198.252.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.199.64.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.199.196.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.199.208.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.201.48.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.202.56.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.202.92.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.203.160.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.203.196.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.204.168.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.204.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.205.220.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.206.68.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.206.92.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.206.236.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.207.4.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.207.52.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.207.72.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.207.196.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.208.76.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.208.148.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.208.172.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.208.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.209.188.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.210.200.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.211.56.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.211.84.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.211.88.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.212.48.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.212.120.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.212.192.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.213.8.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.213.164.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.214.36.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.215.124.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.215.152.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.215.228.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.215.232.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.215.244.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.216.124.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.217.160.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.219.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.220.216.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.220.224.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.221.76.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.221.112.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.221.192.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.222.120.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.222.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.222.184.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.224.176.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.224.204.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.225.80.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.225.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.225.240.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.226.116.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.226.132.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.226.140.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.227.64.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.227.116.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.227.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.228.236.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.228.244.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.229.0.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.229.28.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.231.180.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.231.184.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.232.32.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.232.152.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.232.176.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.233.12.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.234.192.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.235.40.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.235.136.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.235.164.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.236.36.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.236.88.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.237.8.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.237.84.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.238.20.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.238.44.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.238.92.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.239.0.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.240.56.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.240.148.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.243.48.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.244.52.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.246.4.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.249.52.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.251.76.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.252.28.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.255.68.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.255.88.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=185.255.208.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.0.240.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.34.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.75.64.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.118.64.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.121.96.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.121.128.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.122.96.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.136.128.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.158.0.0/15 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.191.176.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.208.56.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.208.64.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.208.144.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.208.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.208.200.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.208.208.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.208.224.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.209.0.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.209.32.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.209.64.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.209.128.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.209.152.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.209.192.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.210.64.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.210.80.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.210.96.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.210.128.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.210.192.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.210.232.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.211.0.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.211.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.211.64.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.211.128.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.211.176.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.211.192.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.212.6.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.212.22.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.212.48.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.212.64.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.212.96.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.212.144.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.212.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.212.200.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.212.208.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.212.224.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.212.240.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.213.64.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.213.96.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.213.144.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.213.176.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.213.192.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.213.208.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.214.4.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.214.84.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.214.96.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.214.120.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.214.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.214.216.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.214.232.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.215.24.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.215.88.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.215.128.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.215.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.215.192.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.215.240.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.229.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.240.196.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.240.212.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.240.248.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.245.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.253.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=188.253.64.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=192.15.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.0.156.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.8.139.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.19.144.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.32.80.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.34.244.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.35.62.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.104.22.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.104.212.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.105.2.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.105.6.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.148.64.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.151.128.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.176.240.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.178.200.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.189.122.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.201.192.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.222.51.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.242.194.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=193.242.208.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.5.40.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.5.176.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.15.96.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.26.72.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.33.104.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.33.122.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.33.124.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.34.160.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.39.36.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.41.48.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.60.208.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.60.228.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.143.140.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.146.148.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.147.164.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.150.68.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.156.140.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=194.225.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=195.20.136.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=195.88.188.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=195.110.38.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=195.146.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=195.170.163.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=195.181.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=195.191.74.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=195.211.44.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=195.238.124.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=195.245.70.0/23 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=196.3.91.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=212.1.192.0/21 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=212.16.64.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=212.33.192.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=212.80.0.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=212.86.64.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=212.120.192.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=213.108.240.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=213.109.240.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=213.176.0.0/17 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=213.195.0.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=213.207.192.0/18 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=213.217.32.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=213.232.124.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=213.233.160.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=217.11.16.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=217.24.144.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=217.25.48.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=217.60.0.0/16 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=217.66.192.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=217.77.112.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=217.146.208.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=217.170.240.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=217.171.145.0/24 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=217.171.148.0/22 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=217.172.96.0/19 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=217.174.16.0/20 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=217.218.0.0/15 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=172.16.0.0/12 comment=IANA-reserved-private-IPv4 list=IranianIP
add address=192.168.0.0/16 comment=IANA-reserved-private-IPv4 list=IranianIP
add address=10.0.0.0/8 comment=IANA-reserved-private-IPv4 list=IranianIP
add address=192.168.50.0/24 list=local
add address=kroshd.com comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=parspack.com comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=tax.gov.ir comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=zhaket.com comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=10.3.1.0/30 list=IranianIP
add address=google.com comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=www.google.com comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=www.sarzamindownload.com comment=ipdeny-Iran-IP-Zone list=\
    IranianIP
add address=www.mihandownload.com comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=37.32.27.47 comment=ipdeny-Iran-IP-Zone list=IranianIP
add address=3dns-1.adobe.com list=Adobe
add address=192.150.14.69 list=Adobe
add address=192.150.18.101 list=Adobe
add address=192.150.18.108 list=Adobe
add address=192.150.22.40 list=Adobe
add address=192.150.8.100 list=Adobe
add address=192.150.8.118 list=Adobe
add address=199.7.52.190 list=Adobe
add address=199.7.54.72 list=Adobe
add address=209-34-83-73.ood.opsource.net list=Adobe
add address=209.34.83.67 list=Adobe
add address=209.34.83.73 list=Adobe
add address=18.207.85.246 list=Adobe
add address=52.6.155.20 list=Adobe
add address=52.10.49.85 list=Adobe
add address=23.22.30.141 list=Adobe
add address=34.215.42.13 list=Adobe
add address=52.84.156.37 list=Adobe
add address=65.8.207.109 list=Adobe
add address=3.220.11.113 list=Adobe
add address=3.221.72.231 list=Adobe
add address=3.216.32.253 list=Adobe
add address=3.208.248.199 list=Adobe
add address=3.219.243.226 list=Adobe
add address=13.227.103.57 list=Adobe
add address=34.192.151.90 list=Adobe
add address=34.237.241.83 list=Adobe
add address=44.240.189.42 list=Adobe
add address=52.20.222.155 list=Adobe
add address=52.208.86.132 list=Adobe
add address=54.208.86.132 list=Adobe
add address=63.140.38.120 list=Adobe
add address=63.140.38.160 list=Adobe
add address=63.140.38.169 list=Adobe
add address=63.140.38.219 list=Adobe
add address=18.228.243.121 list=Adobe
add address=18.230.164.221 list=Adobe
add address=54.156.135.114 list=Adobe
add address=54.221.228.134 list=Adobe
add address=54.224.241.105 list=Adobe
add address=100.24.211.130 list=Adobe
add address=162.247.242.20 list=Adobe
add address=3dns-2.adobe.com list=Adobe
add address=3dns-3.adobe.com list=Adobe
add address=3dns-4.adobe.com list=Adobe
add address=3dns-5.adobe.com list=Adobe
add address=3dns.adobe.com list=Adobe
add address=activate-sea.adobe.com list=Adobe
add address=activate-sea.adobe.de list=Adobe
add address=activate-sjc0.adobe.com list=Adobe
add address=activate-sjc0.adobe.de list=Adobe
add address=activate.adobe.com list=Adobe
add address=activate.adobe.de list=Adobe
add address=activate.wip.adobe.com list=Adobe
add address=activate.wip1.adobe.com list=Adobe
add address=activate.wip2.adobe.com list=Adobe
add address=activate.wip3.adobe.com list=Adobe
add address=activate.wip3.adobe.de list=Adobe
add address=activate.wip4.adobe.com list=Adobe
add address=adobe-dns-1.adobe.com list=Adobe
add address=adobe-dns-2.adobe.com list=Adobe
add address=adobe-dns-2.adobe.de list=Adobe
add address=adobe-dns-3.adobe.com list=Adobe
add address=adobe-dns-3.adobe.de list=Adobe
add address=adobe-dns-4.adobe.com list=Adobe
add address=adobe-dns.adobe.com list=Adobe
add address=adobe-dns.adobe.de list=Adobe
add address=adobe.activate.com list=Adobe
add address=adobeereg.com list=Adobe
add address=cmdls.adobe.com list=Adobe
add address=crl.verisign.net list=Adobe
add address=ereg.adobe.com list=Adobe
add address=ereg.adobe.de list=Adobe
add address=ereg.wip.adobe.com list=Adobe
add address=ereg.wip1.adobe.com list=Adobe
add address=ereg.wip2.adobe.com list=Adobe
add address=ereg.wip3.adobe.com list=Adobe
add address=ereg.wip4.adobe.com list=Adobe
add address=genuine.adobe.com list=Adobe
add address=hlrcv.stage.adobe.com list=Adobe
add address=hl2rcv.adobe.com list=Adobe
add address=hl2rcv.adobe.de list=Adobe
add address=ims-na1-prprod.adobelogin.com list=Adobe
add address=lm.licenses.adobe.com list=Adobe
add address=lmlicenses.wip4.adobe.com list=Adobe
add address=na1r.services.adobe.com list=Adobe
add address=na2m-pr.licenses.adobe.com list=Adobe
add address=na2m-stg2.licenses.adobe.com list=Adobe
add address=na4r.services.adobe.com list=Adobe
add address=ocsp.spo1.verisign.com list=Adobe
add address=ood.opsource.net list=Adobe
add address=practivate.adobe list=Adobe
add address=practivate.adobe.com list=Adobe
add address=practivate.adobe.de list=Adobe
add address=practivate.adobe.ipp list=Adobe
add address=practivate.adobe.newoa list=Adobe
add address=practivate.adobe.ntp list=Adobe
add address=prod-rel-ffc-ccm.oobesaas.adobe.com list=Adobe
add address=s-2.adobe.com list=Adobe
add address=s-3.adobe.com list=Adobe
add address=tss-geotrust-crl.thawte.com list=Adobe
add address=uds.licenses.adobe.com list=Adobe
add address=dxyeyf6ecy.adobe.io list=Adobe
add address=1hzopx6nz7.adobe.io list=Adobe
add address=ic.adobe.io list=Adobe
add address=p13n.adobe.io list=Adobe
add address=wip1.adobe.com list=Adobe
add address=wip2.adobe.com list=Adobe
add address=wip3.adobe.com list=Adobe
add address=wip4.adobe.com list=Adobe
add address=wwis-dubc1-vip100.adobe.com list=Adobe
add address=wwis-dubc1-vip101.adobe.com list=Adobe
add address=wwis-dubc1-vip102.adobe.com list=Adobe
add address=wwis-dubc1-vip103.adobe.com list=Adobe
add address=wwis-dubc1-vip104.adobe.com list=Adobe
add address=wwis-dubc1-vip105.adobe.com list=Adobe
add address=wwis-dubc1-vip106.adobe.com list=Adobe
add address=wwis-dubc1-vip107.adobe.com list=Adobe
add address=wwis-dubc1-vip108.adobe.com list=Adobe
add address=wwis-dubc1-vip109.adobe.com list=Adobe
add address=wwis-dubc1-vip110.adobe.com list=Adobe
add address=wwis-dubc1-vip111.adobe.com list=Adobe
add address=wwis-dubc1-vip112.adobe.com list=Adobe
add address=wwis-dubc1-vip113.adobe.com list=Adobe
add address=wwis-dubc1-vip114.adobe.com list=Adobe
add address=wwis-dubc1-vip115.adobe.com list=Adobe
add address=wwis-dubc1-vip116.adobe.com list=Adobe
add address=wwis-dubc1-vip117.adobe.com list=Adobe
add address=wwis-dubc1-vip118.adobe.com list=Adobe
add address=wwis-dubc1-vip119.adobe.com list=Adobe
add address=wwis-dubc1-vip120.adobe.com list=Adobe
add address=wwis-dubc1-vip121.adobe.com list=Adobe
add address=wwis-dubc1-vip122.adobe.com list=Adobe
add address=wwis-dubc1-vip123.adobe.com list=Adobe
add address=wwis-dubc1-vip124.adobe.com list=Adobe
add address=wwis-dubc1-vip125.adobe.com list=Adobe
add address=wwis-dubc1-vip30.adobe.com list=Adobe
add address=wwis-dubc1-vip31.adobe.com list=Adobe
add address=wwis-dubc1-vip32.adobe.com list=Adobe
add address=wwis-dubc1-vip33.adobe.com list=Adobe
add address=wwis-dubc1-vip34.adobe.com list=Adobe
add address=wwis-dubc1-vip35.adobe.com list=Adobe
add address=wwis-dubc1-vip36.adobe.com list=Adobe
add address=wwis-dubc1-vip37.adobe.com list=Adobe
add address=wwis-dubc1-vip38.adobe.com list=Adobe
add address=wwis-dubc1-vip39.adobe.com disabled=yes list=Adobe
add address=wwis-dubc1-vip40.adobe.com list=Adobe
add address=wwis-dubc1-vip41.adobe.com list=Adobe
add address=wwis-dubc1-vip42.adobe.com list=Adobe
add address=wwis-dubc1-vip43.adobe.com list=Adobe
add address=wwis-dubc1-vip44.adobe.com list=Adobe
add address=wwis-dubc1-vip45.adobe.com list=Adobe
add address=wwis-dubc1-vip46.adobe.com list=Adobe
add address=wwis-dubc1-vip47.adobe.com list=Adobe
add address=wwis-dubc1-vip48.adobe.com list=Adobe
add address=wwis-dubc1-vip49.adobe.com list=Adobe
add address=wwis-dubc1-vip50.adobe.com list=Adobe
add address=wwis-dubc1-vip51.adobe.com list=Adobe
add address=wwis-dubc1-vip52.adobe.com list=Adobe
add address=wwis-dubc1-vip53.adobe.com list=Adobe
add address=wwis-dubc1-vip54.adobe.com list=Adobe
add address=wwis-dubc1-vip55.adobe.com list=Adobe
add address=wwis-dubc1-vip56.adobe.com list=Adobe
add address=wwis-dubc1-vip57.adobe.com list=Adobe
add address=wwis-dubc1-vip58.adobe.com list=Adobe
add address=wwis-dubc1-vip59.adobe.com list=Adobe
add address=wwis-dubc1-vip60.adobe.com list=Adobe
add address=wwis-dubc1-vip60.adobe.de list=Adobe
add address=wwis-dubc1-vip61.adobe.com list=Adobe
add address=wwis-dubc1-vip62.adobe.com list=Adobe
add address=wwis-dubc1-vip63.adobe.com list=Adobe
add address=wwis-dubc1-vip64.adobe.com list=Adobe
add address=wwis-dubc1-vip65.adobe.com list=Adobe
add address=wwis-dubc1-vip66.adobe.com list=Adobe
add address=wwis-dubc1-vip67.adobe.com list=Adobe
add address=wwis-dubc1-vip68.adobe.com list=Adobe
add address=wwis-dubc1-vip69.adobe.com list=Adobe
add address=wwis-dubc1-vip70.adobe.com list=Adobe
add address=wwis-dubc1-vip71.adobe.com list=Adobe
add address=wwis-dubc1-vip72.adobe.com list=Adobe
add address=wwis-dubc1-vip73.adobe.com list=Adobe
add address=wwis-dubc1-vip74.adobe.com list=Adobe
add address=wwis-dubc1-vip75.adobe.com list=Adobe
add address=wwis-dubc1-vip76.adobe.com list=Adobe
add address=wwis-dubc1-vip77.adobe.com list=Adobe
add address=wwis-dubc1-vip78.adobe.com list=Adobe
add address=wwis-dubc1-vip79.adobe.com list=Adobe
add address=wwis-dubc1-vip80.adobe.com list=Adobe
add address=wwis-dubc1-vip81.adobe.com list=Adobe
add address=wwis-dubc1-vip82.adobe.com list=Adobe
add address=wwis-dubc1-vip83.adobe.com list=Adobe
add address=wwis-dubc1-vip84.adobe.com list=Adobe
add address=wwis-dubc1-vip85.adobe.com list=Adobe
add address=wwis-dubc1-vip86.adobe.com list=Adobe
add address=wwis-dubc1-vip87.adobe.com list=Adobe
add address=wwis-dubc1-vip88.adobe.com list=Adobe
add address=wwis-dubc1-vip89.adobe.com list=Adobe
add address=wwis-dubc1-vip90.adobe.com list=Adobe
add address=wwis-dubc1-vip91.adobe.com list=Adobe
add address=wwis-dubc1-vip92.adobe.com list=Adobe
add address=wwis-dubc1-vip93.adobe.com list=Adobe
add address=wwis-dubc1-vip94.adobe.com list=Adobe
add address=wwis-dubc1-vip95.adobe.com list=Adobe
add address=wwis-dubc1-vip96.adobe.com list=Adobe
add address=wwis-dubc1-vip97.adobe.com list=Adobe
add address=wwis-dubc1-vip98.adobe.com list=Adobe
add address=wwis-dubc1-vip99.adobe.com list=Adobe
add address=www.adobeereg.com list=Adobe
add address=cc-api-data.adobe.io list=Adobe
add address=prod.adobegenuine.com list=Adobe
add address=assets.adobedtm.com list=Adobe
add address=4vzokhpsbs.adobe.io list=Adobe
add address=69tu0xswvq.adobe.io list=Adobe
add address=5zgzzv92gn.adobe.io list=Adobe
add address=dyzt55url8.adobe.io list=Adobe
add address=gw8gfjbs05.adobe.io list=Adobe
add address=wip.adobe.com list=Adobe
add address=199.232.114.137 list=Adobe
add address=bam.nr-data.net list=Adobe
add address=www.wip.adobe.com list=Adobe
add address=www.wip1.adobe.com list=Adobe
add address=www.wip2.adobe.com list=Adobe
add address=www.wip3.adobe.com list=Adobe
add address=www.wip4.adobe.com list=Adobe
add address=k.sni.global.fastly.net list=Adobe
add address=workflow-ui-prod.licensingstack.com list=Adobe
add address=1b9khekel6.adobe.io list=Adobe
add address=adobe-dns-01.adobe.com list=Adobe
add address=adobe.demdex.net list=Adobe
add address=adobe.tt.omtrdc.net list=Adobe
add address=adobedc.demdex.net list=Adobe
add address=adobeid-na1.services.adobe.com list=Adobe
add address=auth-cloudfront.prod.ims.adobejanus.com list=Adobe
add address=auth.services.adobe.com list=Adobe
add address=cai-splunk-proxy.adobe.io list=Adobe
add address=cc-cdn.adobe.com list=Adobe
add address=cc-cdn.adobe.com.edgekey.net list=Adobe
add address=cclibraries-defaults-cdn.adobe.com list=Adobe
add address=cclibraries-defaults-cdn.adobe.com.edgekey.net list=Adobe
add address=cn-assets.adobedtm.com.edgekey.net list=Adobe
add address=crlog-crcn.adobe.com list=Adobe
add address=crs.cr.adobe.com list=Adobe
add address=edgeproxy-irl1.cloud.adobe.io list=Adobe
add address=ethos.ethos02-prod-irl1.ethos.adobe.net disabled=yes list=Adobe
add address=geo2.adobe.com list=Adobe
add address=lcs-cops.adobe.io list=Adobe
add address=lcs-robs.adobe.io list=Adobe
add address=pv2bqhsp36w.prod.cloud.adobe.io list=Adobe
add address=services.prod.ims.adobejanus.com list=Adobe
add address=ssl-delivery.adobe.com.edgekey.net list=Adobe
add address=sstats.adobe.com list=Adobe
add address=stls.adobe.com-cn.edgesuite.net list=Adobe
add address=stls.adobe.com-cn.edgesuite.net.globalredir.akadns.net list=Adobe
add address=use-stls.adobe.com.edgesuite.net list=Adobe
add address=9ngulmtgqi.adobe.io list=Adobe
add address=65.108.31.83 list=IranianIP
add address=cp68.netafraz.com list=IranianIP
add address=fdn.digiboy.ir list=IranianIP
add address=172.16.16.0/30 comment=kerio list=InterNetUsers
add address=172.16.17.0/30 list=local
add address=192.168.20.240 list=VPN-User-Acc
add address=speedcheck.ir list=IranianIP
add address=speedtest.net list=IranianIP
add address=192.168.20.40 list=VPN-User-Acc
add address=ticketing.cep-co.ir list=IranianIP
add address=anydesk.com list=IranianIP
add address=boot.net.anydesk.com list=IranianIP
add address=142.250.179.142 comment=temp disabled=yes list=IranianIP
add address=142.250.179.196 comment=tem disabled=yes list=IranianIP
add address=172.16.21.50-172.16.21.80 list=InterNetUsers
add address=web.whatsapp.com list=WhatsApp
add address=www.whatsapp.com list=WhatsApp
add address=skills.google disabled=yes list=IranianIP
add address=mofidonline.com list=IranianIP
add address=d.easytrader.ir list=IranianIP
add address=shahr-bank.ir list=IranianIP
add address=tg.mofidonline.com list=IranianIP
add address=login.emofid.com list=IranianIP
add address=BPM.shaparak.com list=IranianIP
add address=BPM.shaparak.ir list=IranianIP
add address=soft98.ir list=IranianIP
add address=192.168.20.50 list=Ovpn
add address=192.168.80.0/24 list=local
add address=192.168.60.0/24 list=local
add address=192.168.70.4/30 list=local
add address=192.168.40.4/30 list=local
add address=192.168.5.0/24 list=local
add address=192.168.30.0/24 list=local
add address=172.16.20.0/24 list=local
add address=192.168.20.240 list=VPN-User-CRM
add address=172.16.21.0/24 list=local
add address=192.168.20.40 list=VPN-User
add address=192.168.20.240 list=VPN-User
add address=192.168.20.50 list=VPN-User
add address=192.168.70.0/30 list=local
add address=192.168.40.0/30 list=local
add address=37.255.245.162 list=cepco-office
add address=5.202.196.215 list=cepco-office
add address=87.251.64.146 list=blacklist
add address=192.168.20.240 list=Ovpn
add address=192.168.20.50 list=Ovpn-Transport
/ip firewall filter
add action=accept chain=forward dst-address=192.168.20.50 src-address=\
    192.168.21.60
add action=accept chain=forward dst-address=192.168.21.60 src-address=\
    192.168.20.50
add action=accept chain=forward src-address=172.16.20.32
add action=accept chain=forward dst-address=172.16.20.32
add action=accept chain=forward dst-address-list=VPN-User-CRM src-address=\
    172.16.21.30-172.16.21.40
add action=accept chain=forward dst-address-list=VPN-User src-address=\
    172.16.21.48
add action=accept chain=forward dst-address-list=VPN-User-Acc src-address=\
    172.16.21.50-172.16.21.80
add action=accept chain=forward out-interface-list=WAN src-address=\
    172.16.21.0/24
add action=accept chain=forward comment=NVR disabled=yes dst-address=\
    192.168.60.11 dst-port=37777 in-interface=pppoe-out3 protocol=tcp
add action=accept chain=forward comment="Veeam monitoring agent" \
    dst-address-list=cepco-office dst-port=55000 protocol=tcp src-address=\
    192.168.20.251
add action=accept chain=forward comment="Veeam monitoring agent" \
    dst-address-list=cepco-office protocol=icmp src-address=192.168.20.251
add action=drop chain=forward dst-address-list=!VPN-User-Acc src-address=\
    172.16.21.50-172.16.21.80
add action=drop chain=forward dst-address-list=!VPN-User-CRM src-address=\
    172.16.21.30-172.16.21.40
add action=drop chain=forward dst-address-list=!VPN-User src-address=\
    172.16.21.48
add action=accept chain=forward dst-address=216.239.38.120
add action=accept chain=forward comment=Ovpn dst-address=192.168.20.240 \
    dst-port=800 protocol=tcp src-address=172.16.10.10-172.16.10.20
add action=accept chain=forward comment=Ovpn-Rahmani dst-address=\
    192.168.20.240 dst-port=800 protocol=tcp src-address=172.16.10.8
add action=accept chain=forward comment=Ovpn dst-address=192.168.20.50 \
    dst-port=9970 protocol=tcp src-address=172.16.10.10-172.16.10.20
add action=accept chain=forward comment=Ovpn-Transport dst-address=\
    192.168.20.50 dst-port=9970 protocol=tcp src-address=\
    172.16.20.10-172.16.20.20
add action=drop chain=forward comment=Ovpn-Transport dst-address-list=local \
    src-address=172.16.20.10-172.16.20.20
add action=drop chain=forward comment=Ovpn dst-address-list=local \
    src-address=172.16.10.10-172.16.10.20
add action=drop chain=forward comment=Ovpn-Rahmani dst-address-list=local \
    src-address=172.16.10.8
add action=drop chain=forward comment=Adobe dst-address-list=Adobe
add action=accept chain=forward disabled=yes dst-address=172.16.50.254 log=\
    yes log-prefix=------- src-address=192.168.21.105
add action=accept chain=forward disabled=yes log-prefix=11 out-interface=*1F \
    src-address=172.16.50.254
add action=accept chain=forward disabled=yes dst-address=172.16.50.254 \
    in-interface=*1F log-prefix=22
add action=drop chain=forward comment="Block Internet Acc" dst-address=\
    !195.28.168.72 out-interface-list=WAN src-address=192.168.20.251
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=accept chain=forward dst-address=192.168.20.106 src-address=\
    172.16.20.28
add action=drop chain=forward src-address=172.16.20.28
add action=drop chain=input comment="port scan" src-address=!37.255.245.162 \
    src-address-list="Port Scanner"
add action=add-src-to-address-list address-list="Port Scanner" \
    address-list-timeout=2w chain=input protocol=tcp psd=21,3s,3,1 \
    src-address-list=!cepco-office
add action=add-src-to-address-list address-list="Port Scanner" \
    address-list-timeout=2w chain=input comment="NMAP FIN Steal Scan" \
    protocol=tcp src-address-list=!cepco-office tcp-flags=\
    fin,!syn,!rst,!psh,!ack,!urg
add action=add-src-to-address-list address-list="Port Scanner" \
    address-list-timeout=2w chain=input comment="NMAP FIN/SYN Scan" protocol=\
    tcp src-address-list=!cepco-office tcp-flags=fin,syn
add action=add-src-to-address-list address-list="Port Scanner" \
    address-list-timeout=2w chain=input comment="NMAP SYN/RST Scan" protocol=\
    tcp src-address-list=!cepco-office tcp-flags=syn,rst
add action=add-src-to-address-list address-list="Port Scanner" \
    address-list-timeout=2w chain=input comment="NMAP ALL/ALL  Scan" \
    protocol=tcp src-address-list=!cepco-office tcp-flags=\
    fin,syn,rst,psh,ack,urg
add action=add-src-to-address-list address-list="Port Scanner" \
    address-list-timeout=2w chain=input comment="NMAP NUL  Scan" protocol=tcp \
    src-address-list=!cepco-office tcp-flags=!fin,!syn,!rst,!psh,!ack,!urg
add action=add-src-to-address-list address-list="Port Scanner" \
    address-list-timeout=2w chain=input comment="NMAP FIN/PSH/URG Scan" \
    protocol=tcp src-address-list=!cepco-office tcp-flags=\
    fin,psh,urg,!syn,!rst,!ack
/ip firewall mangle
add action=mark-routing chain=prerouting disabled=yes new-routing-mark=main \
    src-address=192.168.20.40
add action=mark-routing chain=prerouting new-routing-mark=main src-address=\
    192.168.21.121
add action=mark-routing chain=prerouting dst-address-list=!local \
    new-routing-mark=Fibr-internet src-address-list=InterNetUsers
add action=change-mss chain=forward disabled=yes new-mss=1350 protocol=tcp \
    src-address=192.168.20.25 tcp-flags=syn tcp-mss=1460-65535
add action=change-mss chain=forward disabled=yes new-mss=1350 protocol=tcp \
    src-address-list=InterNetUsers tcp-flags=syn tcp-mss=1460-65535
add action=mark-routing chain=prerouting disabled=yes dst-address-list=\
    !IranianIP new-routing-mark=vpn src-address=192.168.20.25
add action=mark-routing chain=prerouting dst-address-list=WhatsApp \
    new-routing-mark=vpn passthrough=no src-address-list=InterNetUsers
add action=mark-routing chain=prerouting dst-address-list=!IranianIP \
    new-routing-mark=vpn src-address-list=InterNetUsers
add action=mark-routing chain=prerouting disabled=yes dst-address-list=\
    WhatsApp new-routing-mark=vpn
add action=mark-routing chain=prerouting dst-address-list=telegram \
    new-routing-mark=vpn
add action=mark-routing chain=prerouting dst-address-list=Youtube1 \
    new-routing-mark=vpn
add action=mark-connection chain=prerouting in-interface=ether9 \
    new-connection-mark=Shatel
add action=mark-routing chain=output connection-mark=Shatel new-routing-mark=\
    Shatel
add action=mark-connection chain=prerouting in-interface=pppoe-out3 \
    new-connection-mark=Fibr-internet
add action=mark-routing chain=output connection-mark=Fibr-internet \
    new-routing-mark=Fibr-internet
/ip firewall nat
add action=dst-nat chain=dstnat comment=NVR dst-port=37777 in-interface=\
    pppoe-out3 protocol=tcp to-addresses=192.168.60.11 to-ports=37777
add action=masquerade chain=srcnat dst-address-list=cepco-office src-address=\
    192.168.20.251
add action=src-nat chain=srcnat comment="For web modem fibre" dst-address=\
    192.168.8.2 to-addresses=192.168.8.10
add action=src-nat chain=srcnat comment="For web modem Shatel" dst-address=\
    192.168.3.2 to-addresses=192.168.3.1
add action=masquerade chain=srcnat dst-address-list=!local src-address=\
    192.168.20.20
add action=masquerade chain=srcnat dst-address-list=!local out-interface=\
    pppoe-out3 src-address=192.168.20.25
add action=masquerade chain=srcnat dst-address-list=!local out-interface=\
    pppoe-out3 src-address=192.168.20.50
add action=masquerade chain=srcnat dst-address-list=!local src-address=\
    192.168.20.25
add action=dst-nat chain=dstnat comment=\
    "Temp publish Citrix for accounting clients" disabled=yes dst-address=\
    37.255.236.73 dst-port=80 in-interface=pppoe-out2-Fiber log=yes \
    log-prefix=citrix------- protocol=tcp to-addresses=192.168.20.40
add action=masquerade chain=srcnat disabled=yes out-interface=\
    pppoe-out2-Fiber src-address=192.168.20.40
add action=accept chain=srcnat disabled=yes dst-address=192.168.20.230 \
    src-address=172.16.17.2
add action=masquerade chain=srcnat comment="Ovpn Internet" disabled=yes \
    dst-address-list=!local src-address=172.16.10.0/24
add action=masquerade chain=srcnat comment="Access to internet kerio" \
    src-address=172.16.16.2
add action=src-nat chain=srcnat dst-address=172.16.50.0/24 src-address=\
    172.16.20.33 to-addresses=172.16.50.2
add action=masquerade chain=srcnat comment="Nat for Cepco VPN" out-interface=\
    pppoe-out3 src-address=172.16.20.32
add action=masquerade chain=srcnat comment="Nat for Cepco VPN" out-interface=\
    pppoe-out3 src-address=172.16.20.33
add action=masquerade chain=srcnat comment="masquerade hotspot network" \
    disabled=yes src-address=192.168.21.51
# pppoe-out2-Fiber not ready
add action=masquerade chain=srcnat comment="IP wifi CLOCK FOR NET " \
    out-interface=pppoe-out2-Fiber src-address=192.168.21.190
# pppoe-out2-Fiber not ready
add action=masquerade chain=srcnat comment=\
    "IP net card  Device CLOCK FOR NET " out-interface=pppoe-out2-Fiber \
    src-address=192.168.20.126
add action=masquerade chain=srcnat comment="Nat on internet outgoing" \
    out-interface=pppoe-out3 src-address-list=InterNetUsers to-addresses=\
    37.255.219.133
add action=masquerade chain=srcnat comment="Nat on internet outgoing" \
    out-interface=ipip-tunnel3 src-address-list=InterNetUsers to-addresses=\
    37.255.219.133
add action=masquerade chain=srcnat comment="Nat on internet outgoing" \
    out-interface=gre6-tunnel1 src-address-list=InterNetUsers to-addresses=\
    37.255.219.133
add action=masquerade chain=srcnat comment="Nat on internet outgoing" \
    disabled=yes out-interface=*24 src-address-list=InterNetUsers \
    to-addresses=37.255.219.133
add action=masquerade chain=srcnat comment="masquerade hotspot network" \
    disabled=yes dst-address=!172.16.50.254 src-address=192.168.21.0/24
add action=masquerade chain=srcnat comment="masquerade hotspot network" \
    disabled=yes src-address=192.168.20.230
add action=dst-nat chain=dstnat comment=\
    "Temp publish CRM for factory clients" disabled=yes dst-address=\
    37.255.236.73 dst-port=800 protocol=tcp src-address=46.148.34.39 \
    to-addresses=192.168.20.240 to-ports=800
add action=dst-nat chain=dstnat disabled=yes dst-address=37.255.219.133 \
    dst-port=11012 protocol=tcp to-addresses=192.168.20.230 to-ports=3000
add action=dst-nat chain=dstnat disabled=yes dst-address=37.255.219.133 \
    dst-port=11012 protocol=tcp to-addresses=192.168.20.230 to-ports=80
add action=dst-nat chain=dstnat disabled=yes dst-address=37.255.219.133 \
    dst-port=11012 protocol=tcp to-addresses=192.168.20.230 to-ports=554
add action=masquerade chain=srcnat comment="masquerade hotspot network" \
    disabled=yes src-address=192.168.21.0/24
add action=masquerade chain=srcnat comment="Nat on internet outgoing" \
    out-interface=ether2
add action=passthrough chain=unused-hs-chain comment=\
    "place hotspot rules here" disabled=yes
add action=masquerade chain=srcnat disabled=yes out-interface=*1B
add action=masquerade chain=srcnat comment="Nat on internet outgoing" \
    disabled=yes out-interface=*E src-address-list=InterNetUsers
add action=masquerade chain=srcnat comment="Nat on internet outgoing" \
    disabled=yes out-interface=ether7
add action=dst-nat chain=dstnat disabled=yes dst-address=94.183.170.242 \
    dst-port=6772 protocol=tcp to-addresses=172.16.50.189 to-ports=6772
add action=dst-nat chain=dstnat disabled=yes dst-address=192.168.168.254 \
    dst-port=37777 protocol=tcp to-addresses=192.168.168.254 to-ports=37777
add action=dst-nat chain=dstnat disabled=yes dst-address=94.183.170.242 \
    dst-port=1433 protocol=tcp to-addresses=192.168.20.110 to-ports=1433
add action=dst-nat chain=dstnat dst-address=37.255.219.133 dst-port=3000 \
    protocol=tcp to-addresses=192.168.20.230 to-ports=3000
add action=dst-nat chain=dstnat disabled=yes dst-address=94.183.170.242 \
    dst-port=9050 protocol=tcp to-addresses=192.168.20.110 to-ports=9050
add action=dst-nat chain=dstnat dst-address=37.255.219.133 dst-port=543 \
    protocol=tcp to-addresses=192.168.20.111 to-ports=543
add action=dst-nat chain=dstnat dst-address=37.255.219.133 dst-port=554 \
    protocol=tcp to-addresses=192.168.20.230 to-ports=554
add action=dst-nat chain=dstnat dst-address=37.255.219.133 dst-port=3000 \
    protocol=tcp to-addresses=192.168.20.230 to-ports=3000
add action=dst-nat chain=dstnat dst-address=37.255.219.133 dst-port=3001 \
    protocol=tcp to-addresses=192.168.20.230 to-ports=3001
add action=dst-nat chain=dstnat dst-address=37.255.219.133 dst-port=3000 \
    protocol=udp to-addresses=192.168.20.230 to-ports=3000
add action=dst-nat chain=dstnat dst-address=37.255.219.133 dst-port=1935 \
    protocol=tcp to-addresses=192.168.20.230 to-ports=1935
add action=dst-nat chain=dstnat disabled=yes dst-address=37.255.219.133 \
    dst-port=80 protocol=tcp to-addresses=192.168.20.230 to-ports=80
add action=dst-nat chain=dstnat disabled=yes dst-address=37.255.219.133 \
    dst-port=443 protocol=tcp to-addresses=192.168.20.230 to-ports=443
add action=dst-nat chain=dstnat disabled=yes dst-address=37.255.219.133 \
    dst-port=37777 protocol=tcp to-addresses=192.168.20.230 to-ports=37777
add action=dst-nat chain=dstnat dst-address=37.255.219.133 dst-port=5443 \
    protocol=tcp to-addresses=192.168.20.132 to-ports=5443
add action=dst-nat chain=dstnat disabled=yes dst-address=37.255.219.133 \
    dst-port=5443 protocol=tcp to-addresses=192.168.21.240 to-ports=5443
add action=dst-nat chain=dstnat disabled=yes dst-address=94.183.170.242 \
    dst-port=3000 protocol=tcp to-addresses=192.168.20.229 to-ports=3000
add action=masquerade chain=srcnat disabled=yes dst-address=172.16.50.254
add action=masquerade chain=srcnat disabled=yes dst-address-list=!local \
    out-interface=pppoe-out3 src-address=172.16.20.36
add action=masquerade chain=srcnat dst-address-list=!local out-interface=\
    pppoe-out3 src-address=172.16.20.36
add action=masquerade chain=srcnat comment="Mail server for Veeam backup" \
    dst-address=195.28.168.72
add action=dst-nat chain=dstnat disabled=yes dst-address=94.183.170.242 \
    dst-port=8998 protocol=tcp to-addresses=192.168.20.50 to-ports=8998
/ip firewall raw
# pppoe-out2-Fiber not ready
add action=drop chain=prerouting dst-port=21-23,53,443,8291 in-interface=\
    pppoe-out2-Fiber protocol=tcp
add action=drop chain=prerouting dst-port=21-23,53,443,8291 in-interface=\
    pppoe-out3 protocol=tcp
add action=drop chain=prerouting dst-port=21-23,443,8291,53 in-interface=\
    ether9 protocol=tcp
add action=drop chain=prerouting dst-port=21-23,53,80,443 in-interface=\
    WAN-TCI protocol=tcp
# pppoe-out2-Fiber not ready
add action=drop chain=prerouting dst-port=21-23,53,80,443,8291 in-interface=\
    pppoe-out2-Fiber protocol=udp
add action=drop chain=prerouting dst-port=21-23,53,80,443,8291 in-interface=\
    pppoe-out3 protocol=udp
add action=drop chain=prerouting dst-port=21-23,53,80,443,8291 in-interface=\
    ether9 protocol=udp
add action=drop chain=prerouting dst-port=21-23,53,80,443,8291 in-interface=\
    WAN-TCI protocol=udp
add action=drop chain=prerouting disabled=yes dst-port=53 in-interface=*E \
    protocol=udp
add action=accept chain=prerouting in-interface-list=WAN src-address-list=\
    cepco-office
add action=drop chain=prerouting in-interface-list=WAN src-address-list=\
    blacklist
/ip hotspot ip-binding
add address=192.168.21.190 mac-address=5C:C3:36:38:8C:89 server=hotspot1 \
    type=bypassed
add address=192.168.21.251 comment=AP01 disabled=yes type=bypassed
add address=192.168.20.230 comment=NVR type=bypassed
add address=192.168.20.0/24 type=bypassed
add address=172.16.50.0/24 type=bypassed
add address=192.168.21.249 comment=AP00 type=bypassed
add address=192.168.20.251 mac-address=00:0C:29:A2:34:EF server=hotspot1 \
    to-address=192.168.20.251 type=bypassed
add address=172.16.50.254 type=bypassed
add address=192.168.21.83 comment=farzad mac-address=D8:5E:D3:92:8A:40 \
    server=hotspot1 to-address=192.168.21.83 type=bypassed
add address=192.168.21.241 comment=seraj mac-address=2C:44:FD:21:1E:E0 \
    server=hotspot1 to-address=192.168.21.241 type=bypassed
add address=192.168.21.166 comment=sarami mac-address=C4:C6:E6:75:AB:63 \
    server=hotspot1 to-address=192.168.21.166 type=bypassed
add address=192.168.21.96 comment=taba mac-address=E8:9C:25:43:0A:50 server=\
    hotspot1 to-address=192.168.21.96 type=bypassed
add address=192.168.21.88 comment=elyas mac-address=E8:9C:25:43:08:28 server=\
    hotspot1 to-address=192.168.21.88 type=bypassed
add address=192.168.21.134 comment=heydari mac-address=A0:36:BC:28:51:35 \
    server=hotspot1 to-address=192.168.21.134 type=bypassed
add address=192.168.21.252 comment=ahmadi mac-address=F0:92:1C:E6:51:A7 \
    server=hotspot1 to-address=192.168.21.252 type=bypassed
add address=192.168.21.232 comment=kiani mac-address=A0:48:1C:87:45:24 \
    server=hotspot1 to-address=192.168.21.232 type=bypassed
add address=192.168.21.128 comment=rafat mac-address=C0:35:32:74:88:B1 \
    server=hotspot1 to-address=192.168.21.128 type=bypassed
add address=192.168.21.129 comment=rafat-wifi server=hotspot1 to-address=\
    192.168.21.129 type=bypassed
add address=192.168.21.112 comment=Janaki server=hotspot1 to-address=\
    192.168.21.112 type=bypassed
add address=192.168.21.148 comment="Mis Montazeri" mac-address=\
    D8:5E:D3:D9:3C:27 server=hotspot1 to-address=192.168.21.148 type=bypassed
/ip hotspot user
add name=admin profile=admins
add limit-bytes-total=6000000000 name=seraj
add limit-bytes-total=100000000000 name=ahmadi
add limit-bytes-total=50000000000 name=kiani
add limit-bytes-total=36000000000 name=abasi
add limit-bytes-total=10000000000 name=reza
add limit-bytes-total=42000000000 name=oliaeifar
add limit-bytes-total=3000000000 name=ramezani
add limit-bytes-total=63000000000 name=valehi
add limit-bytes-total=38000000000 name=firouznia
add disabled=yes limit-bytes-total=7000000000 name=tajedin
add limit-bytes-total=9000000000 name=akhlaghi
add limit-bytes-total=80000000000 name=rafat
add limit-bytes-total=15000000000 name=shiva
add limit-bytes-total=102000000000 name=negar
add limit-bytes-total=20000000000 name=heydari
add limit-bytes-total=27000000000 name=elahe
add limit-bytes-total=24000000000 name=ebrahimi
add limit-bytes-total=3000000000 name=mohamadi
add limit-bytes-total=6000000000 name=sarshough1
add limit-bytes-total=3000000000 name=test
add limit-bytes-total=6000000000 name=it
add limit-bytes-total=30000000000 name=bahar
add limit-bytes-total=45000000000 name=mah
add limit-bytes-total=36000000000 name=farzad
add limit-bytes-total=31000000000 name=taba
add limit-bytes-total=3000000000 name=elyas
add limit-bytes-total=12000000000 name=janaki
add limit-bytes-total=6000000000 name=farnaz
add limit-bytes-total=39000000000 name=ammeri
add limit-bytes-total=18000000000 name=nadia
add limit-bytes-total=21000000000 name=parisa
add limit-bytes-total=30000000000 name=zahra
add limit-bytes-total=12000000000 name=sarami
add limit-bytes-total=3000000000 name=nasim
add limit-bytes-total=28000000000 name=khanverdi
add limit-bytes-total=6000000000 name=amoushahi
add limit-bytes-total=6000000000 name=sara
add limit-bytes-total=53000000000 name=khani
add limit-bytes-total=24000000000 name=maziar
add limit-bytes-total=9000000000 name=asemi
add limit-bytes-total=3000000000 name=javad
add limit-bytes-total=20000000000 name=rasool
add limit-bytes-total=9000000000 name=nasim1
/ip hotspot walled-garden
add server=hotspot1 src-address=172.16.50.0/24
/ip ipsec profile
set [ find default=yes ] dpd-interval=2m dpd-maximum-failures=5
/ip route
add check-gateway=ping disabled=no distance=1 dst-address=192.168.10.0/24 \
    gateway=192.168.70.1 pref-src="" routing-table=main scope=30 \
    suppress-hw-offload=no target-scope=10
add disabled=yes distance=1 dst-address=0.0.0.0/0 gateway="" pref-src="" \
    routing-table=main scope=30 suppress-hw-offload=no target-scope=10
add disabled=yes distance=1 dst-address=0.0.0.0/0 gateway=10.3.1.1 pref-src=\
    "" routing-table=vpn scope=30 suppress-hw-offload=no target-scope=10
add disabled=yes distance=10 dst-address=0.0.0.0/0 gateway=pppoe-out2-Fiber \
    pref-src="" routing-table=main scope=30 suppress-hw-offload=no \
    target-scope=10
add disabled=no distance=1 dst-address=192.168.50.0/24 gateway=192.168.70.1 \
    pref-src="" routing-table=main scope=30 suppress-hw-offload=no \
    target-scope=10
add disabled=no distance=1 dst-address=192.168.100.0/24 gateway=\
    "ipip-tunnel Mashad" pref-src="" routing-table=main scope=30 \
    suppress-hw-offload=no target-scope=10
add check-gateway=ping disabled=no distance=1 dst-address=192.168.5.0/24 \
    gateway=192.168.40.1 routing-table=main scope=30 suppress-hw-offload=no \
    target-scope=10
add disabled=yes distance=1 dst-address=192.168.5.217/32 gateway=\
    "IP IP TO DipLomat Office" pref-src="" routing-table=main scope=30 \
    suppress-hw-offload=no target-scope=10
add disabled=no distance=1 dst-address=0.0.0.0/0 gateway=10.20.30.1 pref-src=\
    "" routing-table=vpn scope=30 suppress-hw-offload=no target-scope=10
add disabled=yes distance=1 dst-address=0.0.0.0/0 gateway=192.192.192.13 \
    pref-src="" routing-table=vpn scope=30 suppress-hw-offload=no \
    target-scope=10
add disabled=no distance=1 dst-address=192.168.21.0/24 gateway=172.16.17.2 \
    pref-src="" routing-table=main scope=30 suppress-hw-offload=no \
    target-scope=10
add disabled=no dst-address=8.8.8.8/32 gateway=10.20.30.1 routing-table=main \
    suppress-hw-offload=no
add disabled=no dst-address=185.73.1.0/24 gateway=172.24.53.225 \
    routing-table=main suppress-hw-offload=no
add disabled=no distance=1 dst-address=192.168.9.0/24 gateway=172.24.53.225 \
    routing-table=main scope=30 suppress-hw-offload=no target-scope=10
add disabled=no distance=1 dst-address=172.16.3.224/27 gateway=172.24.53.225 \
    routing-table=main scope=30 suppress-hw-offload=no target-scope=10
add disabled=no distance=1 dst-address=172.16.14.0/30 gateway=172.24.53.225 \
    routing-table=main scope=30 suppress-hw-offload=no target-scope=10
add disabled=no distance=2 dst-address=192.168.50.0/24 gateway=192.168.70.6 \
    pref-src="" routing-table=main scope=30 suppress-hw-offload=no \
    target-scope=10
add disabled=no distance=2 dst-address=192.168.10.0/24 gateway=192.168.70.6 \
    pref-src="" routing-table=main scope=30 suppress-hw-offload=no \
    target-scope=10
add disabled=no distance=2 dst-address=192.168.5.0/24 gateway=192.168.40.6 \
    routing-table=main scope=30 suppress-hw-offload=no target-scope=10
add disabled=no distance=1 dst-address=0.0.0.0/0 gateway=pppoe-out3 \
    routing-table=main scope=30 suppress-hw-offload=no target-scope=10
add disabled=no distance=5 dst-address=0.0.0.0/0 gateway=37.202.157.153 \
    routing-table=Shatel scope=30 suppress-hw-offload=no target-scope=10
add disabled=no distance=5 dst-address=0.0.0.0/0 gateway=pppoe-out3 \
    routing-table=Fibr-internet scope=30 suppress-hw-offload=no target-scope=\
    10
add disabled=no dst-address=46.148.34.39/32 gateway=pppoe-out3 routing-table=\
    main suppress-hw-offload=no
add disabled=no distance=2 dst-address=0.0.0.0/0 gateway=37.202.157.153 \
    routing-table=main scope=30 suppress-hw-offload=no target-scope=10
add disabled=no distance=1 dst-address=85.15.21.68/32 gateway=37.202.157.153 \
    routing-table=main scope=30 suppress-hw-offload=no target-scope=10
/ip service
set telnet disabled=yes
set ftp port=25
set www disabled=yes
set api address=37.255.245.162/32
set api-ssl address=37.255.245.162/32
set ssh address=37.255.245.162/32,5.202.196.215/32 port=20230
set winbox port=50005
/ip smb shares
set [ find default=yes ] directory=/pub
/ipv6 address
add address=fd22::115/127 advertise=no interface=6to4-tunnel1
/ppp profile
add dns-server=4.2.2.4 local-address=*3 name=L2TP-VPN remote-address=*3
add dns-server=8.8.8.8,8.8.4.4 local-address=10.10.10.1 name=admin \
    remote-address=*4
add local-address=10.1.1.1 name=L2TP--profile1 remote-address=*5 \
    use-encryption=yes use-mpls=yes
/ppp secret
add disabled=yes name=aa profile=default-encryption
add disabled=yes name=AA profile=default-encryption
add disabled=yes name=faradis profile=L2TP-VPN
add disabled=yes name=naser profile=L2TP-VPN
add disabled=yes name=Tehran profile=L2TP--profile1 routes=192.168.85.0/24 \
    service=l2tp
add disabled=yes name=sepehr profile=L2TP--profile1 service=l2tp
add disabled=yes name=admin profile=admin
add disabled=yes name=aaa profile=L2TP-VPN service=l2tp
add disabled=yes name=tehran2 profile=L2TP--profile1 service=l2tp
add disabled=yes local-address=172.16.20.22 name=amoushahi profile=\
    default-encryption remote-address=172.16.20.23 service=pptp
add disabled=yes local-address=172.16.20.24 name=safarian profile=\
    default-encryption remote-address=172.16.20.25 service=pptp
add name=ahmadi profile=Vpn-profile-User service=l2tp
add disabled=yes local-address=172.16.20.30 name=heidari profile=\
    default-encryption remote-address=172.16.20.31 service=pptp
add disabled=yes local-address=192.168.58.1 name=kimia profile=\
    default-encryption remote-address=192.168.58.2 service=sstp
add disabled=yes local-address=172.16.20.27 name=sarshogh profile=\
    default-encryption remote-address=172.16.20.28 service=pptp
add disabled=yes local-address=172.16.20.29 name=janaki profile=\
    default-encryption remote-address=172.16.20.30 service=pptp
add local-address=192.168.25.27 name=ahmadi2 profile=default-encryption \
    remote-address=192.168.25.28 service=l2tp
add local-address=172.16.20.30 name=cepco profile=default-encryption \
    remote-address=172.16.20.32
add local-address=172.16.20.30 name=ghafouri profile=default-encryption \
    remote-address=172.16.20.33 service=l2tp
add local-address=172.16.20.30 name=aghajani profile=default-encryption \
    remote-address=172.16.20.34 service=l2tp
add caller-id=5.202.196.215 disabled=yes local-address=172.16.20.30 name=\
    aghababaei profile=default-encryption remote-address=172.16.20.35 \
    service=l2tp
add local-address=172.16.20.30 name=soleymani profile=default-encryption \
    remote-address=172.16.20.36 service=l2tp
add local-address=172.16.21.1 name=rafat profile=default-encryption \
    remote-address=172.16.21.48 service=l2tp
add name=sarshogh profile=Vpn-Profile-CRM service=l2tp
add name=akhlaghi profile=Vpn-Profile-CRM service=l2tp
add name=khani profile=Vpn-profile-User service=l2tp
add name=heydari profile=Vpn-profile-User service=l2tp
add name=tabatabai profile=Vpn-profile-User service=l2tp
add name=shorshini profile=Vpn-profile-User service=l2tp
add name=sarami profile=Vpn-profile-User service=l2tp
add name=user1 profile=Ovpn-Profile-Transport service=ovpn
add name=user2 profile=Ovpn-Profile-Transport service=ovpn
add name=user3 profile=Ovpn-Profile-Transport service=ovpn
add name=user4 profile=Ovpn-Profile-Transport service=ovpn
add name=user5 profile=Ovpn-Profile-Transport service=ovpn
add name=oliaeifar profile=Vpn-profile-User service=l2tp
add disabled=yes name=m_abasi service=l2tp
add name=rahmani profile=Vpn-Profile-CRM
add name=amoshahi profile=Vpn-profile-User service=l2tp
add name=firooznia profile=Vpn-profile-User service=l2tp
add name=maziyar profile=Vpn-profile-User service=l2tp
add name=sara profile=Vpn-profile-User service=l2tp
add name=valehi profile=Vpn-profile-User service=l2tp
add name=rasan profile=Vpn-profile-User service=l2tp
add name=moradi profile=Vpn-profile-User service=l2tp
add name=montazeri profile=Vpn-profile-User service=l2tp
add name=ebrahimi profile=Vpn-profile-User service=l2tp
add name=oleiki profile=Vpn-profile-User service=l2tp
add name=ameri profile=Vpn-profile-User service=l2tp
add name=zeaei profile=Vpn-profile-User service=l2tp
add name=ghaderi profile=Vpn-profile-User service=l2tp
add name=sherbaf profile=Vpn-profile-User service=l2tp
add local-address=172.16.10.1 name=rahmani1 profile=default-encryption \
    remote-address=172.16.10.8 service=ovpn
add name=falakrafat profile=Ovpn service=ovpn
add name=montazeri2 profile=Ovpn service=ovpn
add name=hajiha profile=Ovpn-Profile-Transport service=ovpn
add name=amoshahi profile=Ovpn-Profile-Transport service=ovpn
add name=akhlagh profile=Ovpn-Profile-Transport service=ovpn
/routing bfd configuration
add disabled=no
/routing rule
add action=lookup disabled=no dst-address=1.0.0.0/8 table=vpn
add action=lookup disabled=no dst-address=4.0.0.0/8 table=vpn
add action=lookup disabled=no dst-address=9.0.0.0/8 table=vpn
add action=lookup disabled=no dst-address=8.0.0.0/8 table=vpn
/system clock
set time-zone-name=Asia/Tehran
/system identity
set name=KimiaRoshd-Core
/system logging
add action=cepcon8n topics=system,error
/system ntp client
set enabled=yes
/system ntp server
set broadcast=yes enabled=yes
/system ntp client servers
add address=ir.pool.ntp.org
add address=1.ir.pool.ntp.org
/tool romon
set enabled=yes
