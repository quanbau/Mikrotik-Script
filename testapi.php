<?php

$newipurl = 'http://10.254.254.1/rest/system/script/run';
$port = $_GET['port'];
//if ($port < 20000) { $port = $port + 10000 }
$username = 'testapi';
$password = '123abc456';
$scriptId = 'newip'.$port;

$data = array(
  ".id" => $scriptId
);

$ch = curl_init($newipurl);

curl_setopt($ch, CURLOPT_URL, $newipurl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); // Capture response
curl_setopt($ch, CURLOPT_POST, true); // Set POST request

// Set authentication
curl_setopt($ch, CURLOPT_USERPWD, "$username:$password");

// Set request content and type
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));

// Ignore SSL verification (not recommended for production)
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

curl_close($ch);

if ($httpCode === 200) {
  echo "Script '$scriptId' run successfully.";
} else {
  echo "Error running script '$scriptId' (code: $httpCode)";
}
