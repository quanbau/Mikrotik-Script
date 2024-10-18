 :for i from=0 to=44 do={
:local pppname [/interface/pppoe-client/get value-name=name number=$i]
:local rttable ("to-".$pppname)
:local connmark ("mark-conn-G".($i + 2))
/routing/table/add name=$rttable fib
/ip/route/add dst-address=0.0.0.0/0 gateway=$pppname routing-table=$rttable 
/ip/firewall/mangle/add chain=prerouting in-interface-list=LAN src-address-list=("G".($i +1)) dst-address-list=!LAN  connection-mark=no-mark action=mark-connection new-connection-mark=$connmark passthrough=yes
/ip/firewall/mangle/add chain=prerouting in-interface-list=LAN connection-mark=$connmark action=mark-routing new-routing-mark=$rttable
 }


 :global orgppp Viettel-vietnd42
 :for i from=1 to=9 do={
    :local wanether [/interface/pppoe-client get value-name=interface [find name=$orgppp]]
    :local pppname ($orgppp.".".$i)
    :local mvlinf ($wanether."mvl".$i)
    /interface/macvlan/add interface=$wanether name=$mvlinf mode=private disabled=yes
    /interface/pppoe-client/add name=$pppname copy-from=$orgppp interface=$mvlinf add-default-route=no use-peer-dns=no
 }

 :for i from=0 to=49 do={
    :local pppname [/interface/pppoe-client get value-name=name number=$i]
    :local rttable ("to-".$pppname)
    /routing/table/add name=$rttable fib
    /ip/route/add dst-address=0.0.0.0/0 gateway=$pppname routing-table=$rttable
 }

 :for i from=1 to=50 do={
    :local pppname [/interface/pppoe-client-get value-name=name number=($i - 1)]
    :local rttable ("to-".$pppname)
    /ip/firewall/mangle/add chain=prerouting in-interface-list=LAN src-address-list=("G".$i) dst-address-list=!Local connection-mark=nomark action=mark-connection new-connection-mark=("mark-conn-G".$i) passthrough=yes
    /ip/firewall/mangle/add chain=prerouting in-interface-list=LAN connection-mark=("mark-conn-G".$i) action=mark-routing new-routing-mark=$rttable passthrough=no
 }