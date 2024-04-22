:local noipuser "xxxxxxx@gmail.com"
:local noippass "1234567890"
:local noiphost "xxx.ddns.net"
:local waninterface "pppoe-out1"

#------------------------------------------------------------------------------------

:global previousIP

:local currentIP [/ip address get [find interface=$waninterface] address]

# Strip the net mask off the IP address
   :for i from=( [:len $currentIP] - 1) to=0 do={
       :if ( [:pick $currentIP $i] = "/") do={ 
           :set currentIP [:pick $currentIP 0 $i]
       } 
 }

   :if ($currentIP != $previousIP) do={
       :log info "No-IP: Current ip $currentIP is not the same as previous IP, update required"
       :set previousIP $currentIP

# The update URL. Note the "\3F" is hex for question mark (?). Required since ? is a special character in commands.
       :local url "http://dynupdate.no-ip.com/nic/update\3Fmyip=$currentIP"
       :local noiphostarray
       :set noiphostarray [:toarray $noiphost]
       :foreach host in=$noiphostarray do={
           :log info "No-IP: Sending update for $host"
           /tool fetch url=($url . "&hostname=$host") user=$noipuser password=$noippass mode=http dst-path=("no-ip_ddns_update-" . $host . ".txt")
           :log info "No-IP: Server $host updated with IP $currentIP"
       }
   }  else={
      :log info "No-IP: Previous IP $previousIP equals current IP, update not required."
   }