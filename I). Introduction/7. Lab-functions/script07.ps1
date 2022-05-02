#functions

function Get-Appversion {
 $PSVersionTable
}
Get-Appversion


#---------------
function add-integers([int]$a, [int]$b) 
{
'The sum of the integers ' +($a+$b)
}
add-integers 10 25

#-------------------
function get-course {
    param (
        [Object[]] $courselist
    )
    
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
    $course.name
    $course.Rating
}
}

get-course $courselist