#if statements
$NoOfvideoes= 19

if ($NoOfvideoes -ge 20)
 {
  "Greater or equal to 20"  
}
else {
    "Less than 20"
}
$NoOfvideoes

#While stmnt- code block statement
$i =1
while($i -le 5)
{
    $i
    ++$i
}


#For  stmnt- code block statement multiple times
for ($i = 1; $i -lt 10; ++$i) {
    $i
}
  

# foreach sttmnt
$name ='Satish', 'Kumar', 'Gangwar'
foreach($naame in $name)
{
    $naame
}

#--------------------
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
foreach($course in $courselist)
{
    $course.Course_ID
    $course.Name
    $course.Rating
}

