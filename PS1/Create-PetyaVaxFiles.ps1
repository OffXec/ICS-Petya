
# 
# https://www.shellandco.net/deploy-petya-vaccination-files-ad-domain-members/
#

clear

# Make a list of the files that we will be creating
$perfc_FilesList = @("c:\windows\perfc", "c:\windows\perfc.dat", "c:\windows\perfc.dll")

# Set the contents of the files we will create
$perfc_content = "Petya vaccination file - DO NOT REMOVE"

function VerifyFiles
{
    Param(
        [parameter(position=0)]
        $file,
        [parameter(position=1)]
        $checkcontent
        )

		Write-Host "Verifying $file"

		#If the file exists, check the contents
		$content = Get-Content -Path $file
		
		if($content -eq $checkcontent)
		{
			Write-Host "$file exists and contents of the file are as expected." -ForegroundColor Green
			
			#Check to see if the file is Read-Only
			if(Get-ItemPropertyValue -Path $file -Name IsReadOnly)
			{
				Write-Host "$file is properly set to Read-Only" -ForegroundColor Green
			}
			else
			{
				# Set to Read-Only if it is not already Read-Only
				Write-Host "$file is not set to Read-Only.  Setting the file to Read-Only" -BackgroundColor Black -ForegroundColor Yellow
				set-itemproperty -path $file -Name IsReadOnly -Value $true
			}
		}
		else
		{
			#The file already exists but the contents were unexpected.  This might indicate 
			Write-Host "$file exists but does not have expected contents." -BackgroundColor White -ForegroundColor Red
			Write-Host "This might indicate an existing infection. You should investigate further." -BackgroundColor White -ForegroundColor Red
			Write-Host "Suggested course of action is to attempt to open the file with a text editor to inspect the contents."  -BackgroundColor White -ForegroundColor Red			
		}
}


#Loop through all of the files in the list
foreach($file in $perfc_FilesList)
{
    # Does the file exist
	if((Test-Path -Path $file) -eq $false)
	{
		#The file doesn't exist so create it and write the standard text
		Write-Host "Creating $file with proper contents $perfc_content" -ForegroundColor Blue
		
		Set-Content $perfc_content -Path $file
		
		# Also set the file to Read-Only
		Write-Host "Setting $file to Read-Only"  -ForegroundColor Blue
		set-itemproperty -path $file -Name IsReadOnly -Value $true	
	}
		
		#Run a verification
		VerifyFiles -file $file -checkcontent $perfc_content
}