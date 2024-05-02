#Thay các thông số trước khi chạy https://youtu.be/AfkudWHMmPM
:delay 5
:local wanip [/ip address get [/ip address find where interface=pppoe-outXXX] address];
:set wanip [:pick $wanip 0 ([:len $wanip]-3)];
:put $wanip;
/tool fetch http-data="{\"type\":\"A\",\"name\":\"nstlmik01.mmo-job.com\",\"content\":\"$wanip\",\"ttl\":60,\"proxied\":false}" url="https://api.cloudflare.com/client/v4/zones/05ed5adacaaab3f46f9b4c9209fc3aab/dns_records/yyyyyy" http-method=put mode=https keep-result=no http-header-field="Authorization: Bearer afcda9849734cd16136de7efa14ff5265c417, Content-Type: application/json"

#Thay proxied thành true để bật tính năng proxy của bản ghi A (là cái ẩn IP sau cloudflare)