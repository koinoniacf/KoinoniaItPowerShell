Task default -depends TestScriptFileInfo, UpdatePSScriptInfo, TestScriptFileInfo, ExportToPsm1, IncrementManifestBuild, FunctionsToExport

$ModuleName = "KoinoniaIT"
$ModuleFile = $ModuleName + ".psm1"
$ModuleManifest = $ModuleName + ".psd1"
try { [System.Security.Cryptography.X509Certificates.X509Certificate]$Certificate = ((Get-ChildItem cert:currentuser\my\ -CodeSigningCert | Sort-Object NotBefore -Descending)[0]) } catch { $Certificate = $null } 
$SourceModules = Get-ChildItem -Path *.psm1 -ErrorAction SilentlyContinue -Recurse | Where-Object Name -ne $ModuleFile
$SourceScripts = Get-ChildItem -Path *.ps1 -ErrorAction SilentlyContinue -Recurse | Where-Object { ($_.Name -ne "psakefile.ps1") -and ($_.Name -ne "KoinoniaITDefaults.ps1") -and ($_.Name -ne "Profile.ps1") }

Task UpdatePSScriptInfo {
    $SourceScripts | ForEach-Object {
        $GitStatus = git status $_.FullName -s --ignored
        if ($null -ne $GitStatus) {
            Write-Verbose "$($_.Name) was modified. Incrementing build number."
            #Increment build numver
            [version]$Version = (Test-ScriptFileInfo -Path $_.FullName).Version
            [version]$Version = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1) 
            
            #Update copyright year to current year
            $Copyright = (Test-ScriptFileInfo  $_.FullName).Copyright -replace "^Copyright \(c\) Koinonia Christian Fellowship(.*)$", "Copyright (c) Koinonia Christian Fellowship $((Get-Date).Year)"
            $CopyrightString = $Copyright -join "`n"
            
            #Update script info
            Update-ScriptFileInfo -Path $_.FullName -Version $Version -Copyright $CopyrightString
        }
        $Result = @{
            Name      = $_.Name
            Version   = $Version
            Copyright = $Copyright
            Status    = $GitStatus
        }
        Write-Verbose $Result.Name
    }
}

Task TestScriptFileInfo {
    $ScriptFileInfo = @()
    $SourceScripts | ForEach-Object {
        $Result = New-Object PSObject
        $Result | Add-Member -NotePropertyName Name -NotePropertyValue ([System.IO.Path]::GetFileNameWithoutExtension($_.Name))
        try { $Result = Test-ScriptFileInfo -Path $_.FullName }
        catch { $Result | Add-member -NotePropertyName Error -NotePropertyValue $_.Exception.Message }
        finally { 
            if ($null -eq (Test-ScriptFileInfo  $_.FullName).Copyright) {
                $Result | Add-Member -NotePropertyName Error -NotePropertyValue "Missing copyright statement"
            }
            $ScriptFileInfo += $Result 
        }
    }

    $ScriptsWithErrors = @()
    $ScriptFileInfo | ForEach-Object { 
        $DuplicateGuids = ($ScriptFileInfo.Guid -match $_.Guid).count
        if ($_.Error -or $DuplicateGuids -gt 1 ) {
            $Result = New-Object PSObject
            $Result | Add-Member -NotePropertyName Name -NotePropertyValue $_.Name
            $Result | Add-Member -NotePropertyName Error -NotePropertyValue $_.Error 
            $Result | Add-Member -NotePropertyName Guid -NotePropertyValue $_.Guid
            if ($DuplicateGuids -gt 1) { $Result | Add-Member -NotePropertyName DuplicateGuid -NotePropertyValue $DuplicateGuids }
            $ScriptsWithErrors += $Result
            
        }
    }
    if ($ScriptsWithErrors) {
        Write-Output "The following scripts have errors or duplicate guids:"
        $ScriptsWithErrors | Select-Object -Property Name, Error, Guid, DuplicateGuid | Format-Table
        throw "Scripts with errors or duplicate guids"
    }
}

Task ExportToPsm1 {
    $ModuleContent = ""

    #Export psm1 files
    $SourceModules | ForEach-Object { $ModuleContent += ((Get-Content $_ -Raw) -replace "\n# .*").Trim() }

    #Export ps1 files
    $SourceScripts | ForEach-Object { 
        $ModuleContent += "function $($_.basename) {`n"
        $ModuleContent += ((Get-Content $_ -Raw) -replace "\n# .*").Trim()
        $ModuleContent += "`n}`n"
    }

    Clear-Content $ModuleFile -ErrorAction SilentlyContinue
    Add-Content $ModuleContent -Path $ModuleFile
}

Task FunctionsToExport {
    # RegEx matches files like Verb-Noun.ps1 only, not psakefile.ps1 or *-*.Tests.ps1
    $FunctionNames = (Get-ChildItem -Recurse | Where-Object { $_.Name -match "^[^\.]+-[^\.]+\.ps1$" }).BaseName
    $FunctionNames += (Get-ChildItem -Path Private -Recurse | Where-Object { $_.Name -match "^^[^\.]+\.ps1$" }).BaseName
    $FunctionNames += $SourceModules | ForEach-Object {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref] $null, [ref] $null)
        if ($ast.EndBlock.Statements.Name) {
            $ast.EndBlock.Statements.Name
        }
    }
    Write-Verbose "Using functions $FunctionNames"
    Update-ModuleManifest -Path $ModuleManifest -FunctionsToExport $FunctionNames
}

Task IncrementManifestBuild {
    [version]$Version = (Import-PowerShellDataFile $ModuleManifest).ModuleVersion
    [version]$Version = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1) 
    Update-ModuleManifest -Path $ModuleManifest -ModuleVersion $Version
}

Task RemoveSignature {
    $SourceModules + $SourceScripts | ForEach-Object {
        Remove-AuthenticodeSignature -FilePath $_.FullName | Write-Verbose
    } 
    Remove-AuthenticodeSignature -FilePath $ModuleManifest | Write-Verbose
    Remove-AuthenticodeSignature -FilePath $ModuleFile | Write-Verbose
}

Task AddSignature {
    $SourceModules + $SourceScripts | ForEach-Object {
        Set-AuthenticodeSignature -FilePath $_.FullName -Certificate $Certificate | Write-Verbose
    } 
    Set-AuthenticodeSignature -FilePath $ModuleManifest -Certificate $Certificate | Write-Verbose
    Set-AuthenticodeSignature -FilePath $ModuleFile -Certificate $Certificate | Write-Verbose
}

Task CompressModule {
    Compress-Archive -Path .\KoinoniaIT*.ps* -DestinationPath Release.zip -Update
}

Task ImportModule { Import-Module $ModuleFile -Force -Verbose:$false }