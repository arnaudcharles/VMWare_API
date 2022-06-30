# Needed to avoid certificate issues
if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
{
$certCallback = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            if(ServicePointManager.ServerCertificateValidationCallback ==null)
            {
                ServicePointManager.ServerCertificateValidationCallback += 
                    delegate
                    (
                        Object obj, 
                        X509Certificate certificate, 
                        X509Chain chain, 
                        SslPolicyErrors errors
                    )
                    {
                        return true;
                    };
            }
        }
    }
"@
    Add-Type $certCallback
 }
[ServerCertificateValidationCallback]::Ignore()

# Token need to be requested from the API 
$token = 'Bearer MTY1NjUyMDc0OTYxMTpkMzBkYTQ1MWVjOWM0ODllYzlkZjp0ZW5hbnQ6bGd1c2VybmFtZTphY2hhcmxlc0Bjc2EuaW50ZXJuYWxleHBpcmF0aW9uOjE2NTY1NDk1NDkwMDA6ZDA3MmU4NjUxNjQ4NmMyYjkyZWRjMDAzZTU3ZGE4ZGE5MDc5ODM5ZDNkZjdiOGQxNzI0MWE2NDVjZDM5YjVmOTMxYmFhOTFiMjc2NzM1YTc4OGUzZTgxZjZjZDFmZjg1NTI3ZTY5MmZjNzg4MDRiZjdhOTgyZmQxNTAyMmQzMzE='
$Url = "https://PUTYOURAPPLIANCEIP/reservation-service/api/reservations?limit=1000" #Set your IP and limit based on the number of owned reservation

$headers = @{
    'Accept' = 'application/json'
    'Content-Type' = 'application/json'
    'Authorization' = $token
}

#Create an array with all reservation id
$json = Invoke-RestMethod -Method Get -Headers $headers -Uri $Url | ConvertTo-Json -Depth 15 
$ReservationID = @($json | jq '.content' | jq .[]  | jq '.id').Replace('"','')

#Process the array to get all name and bg
foreach($ID in $ReservationID )
{
    $UrlWithID = "https://PUTYOURAPPLIANCEIP/reservation-service/api/reservations/$ID"  #Set your IP

    $json = Invoke-RestMethod -Method Get -Headers $headers -Uri $UrlWithID | ConvertTo-Json -Depth 15 
    #Retrieve Reservation name
    $ReservationName = $json | jq '.name'
    $ReservationName = $ReservationName.Replace('"','')
    
    #Retrieve Compute Resource
    $ComputeResource = $json | jq '.extensionData.entries' | jq '.[3]' | jq '.value.label'
    $ComputeResource = $ComputeResource.Replace('"','')

    $ReservationName+" : "+$ComputeResource >> "C:\Users\github\CODE\VMWare\vRA\ExportBG.txt" #Change the location based on your need
}
