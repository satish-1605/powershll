$name ='Satish', 'Kumar', 'Gangwar'
$name

$count= 1, 2, 3
$count

$name1= @(
    'Satish'
    'Kumar'
    'Gangwar'
)
$name1

$name1[2]

$name1[1]='Kumaarr'


<# HAsh Tables
#key/values- comments
#>

$servername =@{
development='server1'
Testing='server2'
Production='server3'
}
$servername
$servername['development']
$servername.development
$servername.Add('preprod', 'server4')
$servername