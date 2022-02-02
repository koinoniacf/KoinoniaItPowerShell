Task default -depends UpdateMetadata, ExportToPsm1, FunctionsToExport, AddSignature, CompressModule, ImportModule

$ModuleName = "KoinoniaIT"
$ModuleFile = $ModuleName + ".psm1"
[System.Security.Cryptography.X509Certificates.X509Certificate]$Certificate = ((Get-ChildItem cert:currentuser\my\ -CodeSigningCert | Sort-Object NotBefore -Descending)[0])
$SourceModules = Get-ChildItem -Path *.psm1 -ErrorAction SilentlyContinue -Recurse | Where-Object Name -ne $ModuleFile
$SourceScripts = Get-ChildItem -Path *.ps1 -ErrorAction SilentlyContinue -Recurse | Where-Object { ($_.Name -ne "psakefile.ps1") -and ($_.Name -ne "KoinoniaITDefaults.ps1") -and ($_.Name -ne "Profile.ps1") }


Task UpdateMetadata {
    $SourceScripts[8] | ForEach-Object {
        (Get-Content $_.FullName) `
            -replace "^File Name  : .*$", "File Name  : $($_.Name.ToString())" `
            -replace "^Copyright \(c\) Koinonia Christian Fellowship(.*)$", "Copyright (c) Koinonia Christian Fellowship $((Get-Date).Year)" `
        | Out-File $_.FullName
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

    Clear-Content ".\$($ModuleName).psm1" -ErrorAction SilentlyContinue
    Add-Content $ModuleContent -Path ".\$($ModuleName).psm1"
}

Task FunctionsToExport {
    # RegEx matches files like Verb-Noun.ps1 only, not psakefile.ps1 or *-*.Tests.ps1
    $FunctionNames = (Get-ChildItem -Recurse | Where-Object { $_.Name -match "^[^\.]+-[^\.]+\.ps1$" }).BaseName
    $FunctionNames += $SourceModules | ForEach-Object {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref] $null, [ref] $null)
        if ($ast.EndBlock.Statements.Name) {
            $ast.EndBlock.Statements.Name
        }
    }
    Write-Output "Using functions $FunctionNames"
    Update-ModuleManifest -Path ".\$($ModuleName).psd1" -FunctionsToExport $FunctionNames
}

Task AddSignature {
    $SourceModules + $SourceScripts | ForEach-Object {
        Set-AuthenticodeSignature -FilePath $_.FullName -Certificate $Certificate
    } 
    Set-AuthenticodeSignature -FilePath ".\$($ModuleName).psd1" -Certificate $Certificate
    Set-AuthenticodeSignature -FilePath ".\$($ModuleName).psm1" -Certificate $Certificate
}

Task CompressModule {
    Compress-Archive -Path .\KoinoniaIT*.ps* -DestinationPath Release.zip -Update
}

Task ImportModule { Import-Module ".\$($ModuleName).psm1" -Force -Verbose:$false }