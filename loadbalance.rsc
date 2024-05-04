:set $pppcnt [/interface/pppoe-client/print count-only]

/interface list add name=LAN
/interface list member add interface=BridgeLAN list=LAN
/ip firewall address-list add address=10.0.0.0/8 list=LAN
/ip firewall address-list add address=172.16.0.0/12 list=LAN
/ip firewall address-list add address=192.168.0.0/16 list=LAN
/ip firewall address-list add address=224.0.0.0/4 list=LAN
/ip firewall address-list add address=255.255.255.255 list=LAN
/ip firewall nat add chain=srcnat action=masquerade out-interface=all-ppp
/ip firewall mangle add action=accept chain=prerouting dst-address-list=LAN in-interface-list=LAN
/ipv6 settings set accept-redirects=no accept-router-advertisements=no disable-ipv6=yes forward=no
:for i from=0 to=($pppcnt - 1) do={
    :local pppname [/interface/pppoe-client/get value-name=name number=$i]
    :local pppname1
    :if ($i = ($pppcnt - 1)) do={
        :set pppname1 [/interface/pppoe-client/get value-name=name number=0]
        } else={
        :set pppname1 [/interface/pppoe-client/get value-name=name number=($i + 1)]
        }
    :local rttbl ("WAN".($i + 1))
    :local inp ("INP".($i + 1))
    /routing table add disabled=no fib name=$rttbl
    /ip route add disabled=no distance=1 dst-address=0.0.0.0/0 gateway=$pppname pref-src="" routing-table=$rttbl scope=30 suppress-hw-offload=no target-scope=10
    /ip route add disabled=no distance=2 dst-address=0.0.0.0/0 gateway=$pppname1 pref-src="" routing-table=$rttbl scope=30 suppress-hw-offload=no target-scope=10
    /ip firewall mangle add action=mark-connection chain=input connection-mark=no-mark in-interface=$pppname new-connection-mark=$inp passthrough=yes
    /ip firewall mangle add action=mark-connection chain=forward connection-mark=no-mark src-address-list=!LAN in-interface=$pppname new-connection-mark=$inp passthrough=yes
    /ip firewall mangle add action=mark-connection chain=prerouting connection-mark=no-mark dst-address-type=!local in-interface-list=LAN new-connection-mark=$rttbl passthrough=yes per-connection-classifier=("both-addresses-and-ports:".$pppcnt."/".$i)
    /ip firewall mangle add action=mark-routing chain=prerouting connection-mark=$rttbl in-interface-list=LAN new-routing-mark=$rttbl passthrough=no
    /ip firewall mangle add action=mark-routing chain=output connection-mark=$inp new-routing-mark=$rttbl passthrough=no
    /ip firewall mangle add action=mark-routing chain=prerouting connection-mark=$inp src-address-list=LAN new-routing-mark=$rttbl passthrough=no
    :put (($i + 1)."/".$pppcnt)
}