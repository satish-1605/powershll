$mobile =@(
[PSCustomObject]@{
    Brand = "Samsung"
    Model= "Galaxy S22"
    Storage=@("128 GB", "256 GB", "512 GB")
    Colors=@("Black", "Blue", "White", "Silver")
    Defaultapps=@(
        @{
            Name ="Assist App"
            Status ="Installed"
            Version=1.0
        },
       @{
            Name ="Browser App"
            Status ="Installed"
            Version=2.0
        }
       
    )},
    [PSCustomObject]@{
        Brand = "Samsung"
        Model= "Galaxy S22 ultra pro"
        Storage=@("128 GB",  "512 GB")
        Colors=@("Black", "White", "Silver")
        Defaultapps=@(
            @{
                Name ="Assist App"
                Status ="Installed"
                Version=1.1
            },
            @{
                Name ="Browser App"
                Status ="Installed"
                Version=2.1
            }
           
        )},
        [PSCustomObject]@{
            Brand = "Samsung"
            Model= "Galaxy S22 ultra"
            Storage=@("128 GB", "256 GB")
            Colors=@("Black", "Blue", "Silver")
            Defaultapps=@(
                @{
                    Name ="Assist App"
                    Status ="Installed"
                    Version=1.2
                },
                @{
                    Name ="Browser App"
                    Status ="Installed"
                    Version=2.2
                }
               
            )   
        }
)
$mobile

$mobile[0]
$mobile | Where-Object {$_.Model -eq "Galaxy S22"} | Select-Object -Property model, Brand

$mobile[0].Storage[1]

$mobile[1].Defaultapps.Item(1)

foreach($app in $mobile[0].Defaultapps)
{
    $app.Version
    $app.name
    $app.Status
}
