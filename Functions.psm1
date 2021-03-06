function Confirm-Installed {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true, 
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $programName
    )
    process {
        $installed =(Get-ChildItem -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
                        Get-ItemProperty -Name DisplayName -ErrorAction SilentlyContinue).DisplayName| 
                        Select-string -SimpleMatch $programName
        

        if($installed){
            $true
        }else{
            $false
        }

    }
}

function Get-BitLockerStatus{
    [CmdletBinding()]
    param()
    process{
        $BLactive = Get-Bitlockervolume -MountPoint "C:"
        if($BLactive.ProtectionStatus -eq 'On' -and $BLactive.EncryptionPercentage -eq '100'){
            $true
        }else{
            $false
        }
    }
}

function Add-LogonTask {
    #creates task that runs script after reboot and login
    [CmdletBinding()]
    param ( 
        [Parameter(Mandatory = $true,
                   ValueFromPipeline =$true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $Program,

        [parameter(Mandatory = $true)]
        [string]
        $arguments,

        [string]
        $taskname = "RunOnLogin"

    )
   
    process {
        $taskexist = Get-ScheduledTask -TaskName $taskname -ErrorAction Ignore

        if ($taskexist){
            #only skips because existing task could delete an already existing task
            write-Verbose -Message "Removing existing schedule test"
        }
        Write-Verbose -Message "Creating New Task"

        $task = New-ScheduledTaskAction -Execute $program -Argument $Arguments
        $trigger = New-ScheduledTaskTrigger -AtLogOn

        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
        
        $registerArguments = @{
            action = $task
            trigger = $trigger
            taskname = $taskname
            settings = $settings
            description = "runs on script on reboot"
            runlevel = "Highest"
        }

        Register-ScheduledTask @registerArguments           
        
        Write-Verbose -Message "task created"
        
       
    }
    
}

function Invoke-Download {
    #installs program from given weblocation to the directory it is in
    param (
        [parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [Alias('uri')]
        [string]
        $url,
        [string]
        $name = ""
    )
    
    begin {
        $ProgressPreference = 'silentlyContinue'    # removes the progress bar for download because slows downlaod  
    }
    
    process {
        #if no name varible it added it parses the name from the url
        
        if($name.Equals("")){
            Write-Verbose "No name inserted"
            $temp = $url.ToCharArray()  
            for ($i = $temp.Count; $i -gt 0; $i--) {
                $letter = $temp.Get($i)
                if($hold.Equals("/")){ 
                    break
                }
                $name = $letter + $name
            }
        }
        
        write-verbose "downloaded files name is $name"
        Invoke-WebRequest -outf $name -Uri $url


    }
    
    end {
        $ProgressPreference = 'continue'    #returns to normal operation
        write-verbose "Download finished for $name"

        #returns name as allow flexablility
        $name
    }
}




