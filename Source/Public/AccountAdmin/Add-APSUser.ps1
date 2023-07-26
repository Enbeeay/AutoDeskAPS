<#
.SYNOPSIS
Create a new user in the BIM 360 member directory.

.DESCRIPTION
Creates a new user with parameters for every data column that is tracked about a user

.PARAMETER AccountID
The ID of the account that contains the users

.PARAMETER email
User’s email

.PARAMETER Company_ID
The user’s default company ID in BIM 360

.PARAMETER nickname
Nick name for user

.PARAMETER first_name
User’s first name

.PARAMETER last_name
User’s last name

.PARAMETER image_url
URL for user’s profile image

.PARAMETER address_line_1
User’s address line 1

.PARAMETER address_line_2
User’s address line 2

.PARAMETER city
City in which user is located

.PARAMETER state_or_province
State or province in which user is located

Max length: 255

Note that the state_or_province value depends on the selected country value

.PARAMETER postal_code
Postal code for the user’s location

.PARAMETER country
Country for this user

.PARAMETER phone
Contact phone number for the user

.PARAMETER company
Contact phone number for the user

.PARAMETER job_title
User’s job title

.PARAMETER industry
Industry information for user

.PARAMETER about_me
Short description about the user

.EXAMPLE
Add-APSUser -AccountID $AccountID -email $testEmail -first_name "Buggs" -last_name "Bunny" -nickname "Doc"

.NOTES
Email is required
#>
function Add-APSUser{
    Param(
        [Parameter(Mandatory = $true)]
        [string]$AccountID,


        [Parameter(Mandatory = $true)]
        [string]$email,


        [string]$Company_ID,
        [string]$nickname,
        [string]$first_name,
        [string]$last_name,
        [string]$image_url,
        [string]$address_line_1,
        [string]$address_line_2,
        [string]$city,
        [string]$state_or_province,
        [string]$postal_code,
        [string]$country,
        [string]$phone,
        [string]$company,
        [string]$job_title,
        [string]$industry,
        [string]$about_me

    )
    # Autodesk API Documentation - https://aps.autodesk.com/en/docs/acc/v1/reference/http/users-POST/

    # Retrieve access token information stored in the PasswordState API
    $2LegTok = Get-APS2LegAuth -scope "account:write"

    # Replace all mandatory/optional parameter placeholders with the chosen parameter names

    # Craft POST message
    # Set the URL per APS docs
    $POSTUrl = "https://developer.api.autodesk.com/hq/v1/accounts/$AccountID/users"

    # Initialize the header of the POST request
    $Header = @{ "Authorization" = "Bearer $($2LegTok)" }
    $Header["Content-Type"] = "application/json"

    # Initialize the Body of the POST request
    $Body = @{}

    # Add query string parameters
    if ($force) { $Body["force"] = $force
    }

    # Set all mandatory parameters
    $Body["email"] = $email

    # Initialize all optional parameters
    if ($company_id) { $Body["company_id"] = $company_id
    }
    if ($nickname) { $Body["nickname"] = $nickname
    }
    if ($first_name) { $Body["first_name"] = $first_name
    }
    if ($last_name) { $Body["last_name"] = $last_name
    }
    if ($image_url) { $Body["image_url"] = $image_url
    }
    if ($address_line_1) { $Body["address_line_1"] = $address_line_1
    }
    if ($address_line_2) { $Body["address_line_2"] = $address_line_2
    }
    if ($city) { $Body["city"] = $city
    }
    if ($state_or_province) { $Body["state_or_province"] = $state_or_province
    }
    if ($postal_code) { $Body["postal_code"] = $postal_code
    }
    if ($country) { $Body["country"] = $country
    }
    if ($phone) { $Body["phone"] = $phone
    }
    if ($company) { $Body["company"] = $company
    }
    if ($job_title) { $Body["job_title"] = $job_title
    }
    if ($industry) { $Body["industry"] = $industry
    }
    if ($about_me) { $Body["about_me"] = $about_me
    }

    # Convert the hashtable into JSON
    $Body = $Body | ConvertTo-Json

    # Send off the POST request using the created header and Body
    Invoke-Restmethod -Method POST -Uri $POSTUrl -Header $Header -Body $Body
}