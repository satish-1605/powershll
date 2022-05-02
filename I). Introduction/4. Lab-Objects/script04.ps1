#object -custom object

$course=[PSCustomObject]@{
    Course_ID = 'AZ400'
    Name= 'Azure Devops Engineer Expert'
    Rating= 4.9
}
$course
'The course id is ' + $course.Course_ID


#--------------Collection of arays---------------
$courselist=@(
    [PSCustomObject]@{
    Course_ID = 'AZ400'
    Name= 'Azure Devops Engineer Expert'
    Rating= 4.9
},
[PSCustomObject]@{
    Course_ID = 'AZ104'
    Name= 'Azure Administrator Associate'
    Rating= 4.8
},
[PSCustomObject]@{
    Course_ID = 'AZ900'
    Name= 'Azure Fundamentals'
    Rating= 4.7
},
[PSCustomObject]@{
    Course_ID = 'AZ204'
    Name= 'Azure developers Associate'
    Rating= 4.6
}
)
$courselist
$courselist[1].Rating