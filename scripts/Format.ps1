function Format-UnixList
{
    param
    (
        [Parameter(ParameterSetName = 'Files', Position = 0, ValueFromPipeline)]
        [System.IO.FileSystemInfo[]]
        $Files,

        [Parameter(ParameterSetName = 'Path', Position = 0, Mandatory)]
        [string]
        $Path,

        [switch]
        $Legend,

        [switch]
        $Long
    )

    begin
    {
        if ($Files -eq $null -and -not $PSCmdlet.MyInvocation.ExpectingInput)
        {
            $Files = Get-Files $Path
        }

        $allFiles = @()

        Write-Host
    }

    process
    {
        if ($Long)
        {
            Write-FileDetails $Files
        }
        else
        {
            if ($Files.Count -gt 0)
            {
                $allFiles += $Files
            }
        }
    }

    end
    {
        if ($allFiles.Count -gt 0)
        {
            Write-ShortList $allFiles
        }

        if ($Legend)
        {
            Write-Legend
        }
    }
}

function Format-UnixListLong
{
    param
    (
        [Parameter(ParameterSetName = 'Files', Position = 0, ValueFromPipeline)]
        [System.IO.FileSystemInfo[]]
        $Files,

        [Parameter(ParameterSetName = 'Path', Position = 0, Mandatory)]
        [string]
        $Path,

        [switch]
        $Legend
    )

    begin
    {
        if ($Files -eq $null -and -not $PSCmdlet.MyInvocation.ExpectingInput)
        {
            $Files = Get-Files $Path
        }

        Write-Host
    }

    process
    {
        Write-FileDetails $Files
    }

    end
    {
        if ($Legend)
        {
            Write-Legend
        }
    }
}

#Set-Alias ll Format-UnixListLong -Force
#Set-Alias ls Format-UnixList -Force
