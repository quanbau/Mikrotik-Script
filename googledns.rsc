#This script was adapted from the script that updates entryDNS. tested on routerOS 6.x
# Variables
:local GoogleDNSUsername "E6d3Aze1NVgBF5zV"
:local GoogleDNSPassword "TIQy84OjTjiVrTGg"
:local hostName "ngoc.jackbui.net"
:global GoogleDNSForceUpdate false
:global currentIP ""
:global previousIP
:global waninterface "pppoe-out1"
:set currentIP [/ip address get [find interface=$waninterface] address]

   :for i from=( [:len $currentIP] - 1) to=0 do={
       :if ( [:pick $currentIP $i] = "/") do={ 
           :set currentIP [:pick $currentIP 0 $i]
       } 
 }
# Script

/#tool fetch url="http://myip.dnsomatic.com/" mode=http dst-path="publicip.txt"
#:set currentIP [/file get "publicip.txt" contents]
#/file remove "publicip.txt"

:if ([:typeof $previousIP] = "nothing") do={ :set previousIP "" }

:if ($currentIP != $previousIP) do={
:set GoogleDNSForceUpdate true
:set previousIP $currentIP
}
#/file add name="publicip.txt" contents=$currentIP
:if ($GoogleDNSForceUpdate) do={
:do {
/tool fetch url=("https://".$GoogleDNSUsername.":".$GoogleDNSPassword."@domains.google.com/nic/update?hostname=".$hostName."&myip=".$currentIP) mode=https keep-result=no
:log info ("GoogleDNS Updated: current IP = $currentIP")
} on-error={
:log error ("GoogleDNS: Failed Updating")
}
}