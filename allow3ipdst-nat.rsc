:local listtocheck "test1"
:local testlist [/ip/firewall/address-list/print as-value proplist=address where list=$listtocheck]
:local ipcount [:len $testlist]
:local allowedipcount 3
# kiểm tra và xoá những ip không có kết nối trong list
:if ($ipcount > 2) do={
    /ip/firewall/filter/disable [find action=add-src-to-address-list address-list=$listtocheck]
    :for i from=0 to=($ipcount - 1) do={
        :local checkip (($testlist->$i)->"address")
        :local conncount [/ip/firewall/connection/print count-only where src-address=$checkip]
        :if ($conncount = 0) do={
            /ip/firewall/address-list remove [find address=$checkip list=$listtocheck]
            :log
        }
    }
}

# kiểm tra lại số lượng ip trong list, xoá những ip mới thêm vào, giữ lại 3 ip cũ nhất
:set testlist [/ip/firewall/address-list/print as-value proplist=address where list=$listtocheck]
:set ipcount [:len $testlist]

:if ($ipcount > 2) do={
    # Tạo danh sách địa chỉ và thời gian tương ứng
    :local addressWithTime
    :for i from=0 to=($ipcount - 1) do={
        :local address ($testlist->$i->"address")
        :local time ($testlist->$i->"dynamic")
        :set addressWithTime ($addressWithTime . "$address $time;")
    }

    # Sắp xếp lại list ip theo thứ tự thời gian
    :set addressWithTime [:toarray $addressWithTime]
    :set addressWithTime [:sort $addressWithTime value]

    # Chỉ giữ lại 3 địa chỉ cũ nhất
    :local keepAddresses [:pick $addressWithTime 0 3]

    # Xóa tất cả các địa chỉ trong danh sách ban đầu
    :foreach address in=$testlist do={
        /ip firewall address-list remove [find address=($address->"address") list=$listtocheck]
    }

    # Thêm lại 3 địa chỉ cũ nhất
    :foreach address in=$keepAddresses do={
        :local addr [:pick $address " " 0]
        /ip firewall address-list add list=$listtocheck address=$addr
    }

} else={/ip/firewall/filter/disable [find action=add-src-to-address-list address-list=$listtocheck]}
