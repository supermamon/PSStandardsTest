[CmdletBinding()]
param()

Function Invoke-ModuleStandardsTest {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
    $Module
  )

  $ModuleName = (Get-Item $Module).Name

  # Unload the module. Useful when developing new modules to make sure your new 
  # changes are loaded
  Get-Module $ModuleName | Remove-Module

  <#
  Assuming the folder structure is:
  PROJECTNAME
  ├───SampleModule
  │   │   SampleModule.Format.ps1xml
  │   │   SampleModule.psd1
  │   │   SampleModule.psm1
  │   │
  │   ├───Private
  │   │
  │   ├───Public
  │   │       Invoke-Function1.ps1
  │   │       Invoke-Function2.ps1
  │   │
  │   └───Resources
  └───Tests
          Standards.Tests.ps1

  Import the module using it's path
  #>
  Import-Module (Join-Path $PSScriptRoot ..\$ModuleName)
  $ModuleVersion = (Get-Module $ModuleName).Version

  $IsBelowPS3 = $PSVersionTable.PSVersion -lt '3.0';

  Write-Output ""
  Write-Output "***************************************************************"
  Write-Output "* Performing Standards test on $ModuleName v$ModuleVersion"
  Write-Output "***************************************************************"


  Describe "Module $ModuleName" {
    Context "Module Documentation" {
      $Module = Get-Module $ModuleName

      It "Has properties populated" {

        #Properties
        $Module.Description | Should Not BeNullOrEmpty
        $Module.Description.Length  | Should BeGreaterThan 0

        # Count words
        $Module.Description | 
        Measure-Object -Word | 
        Select-Object -ExpandProperty Words | Should BeGreaterThan 5

        if (!$IsBelowPS3) {

          $Module.Author      | Should Not BeNullOrEmpty  
          $Module.CompanyName | Should Not BeNullOrEmpty
          $Module.Copyright   | Should Not BeNullOrEmpty

          $Module.Author.Length       | Should BeGreaterThan 5
          $Module.CompanyName.Length  | Should BeGreaterThan 5
          $Module.Copyright.Length    | Should BeGreaterThan 35

        }
        
        

      }

    }

    Get-Command -Module $ModuleName | 
    ForEach-Object {

      $Command = $_
      $FunctionName = $_.Name
      $HelpInfo = Get-Help $Command.Name -Full

      Context "Command Naming Standards > $Command" {

        if ($IsBelowPS3) {
          $Parts = $FunctionName -split '-',2
          $Command | Add-Member -MemberType NoteProperty -Name 'Verb' -Value $Parts[0]
          $Command | Add-Member -MemberType NoteProperty -Name 'Noun' -Value $Parts[1]
        } 

        It "Command $($Command.Name) has a verb." {
          ($Command).Verb | Should Not BeNullOrEmpty  
        }
        It "Command $($Command.Name) has an accepted verb." {
          (Get-Verb | Select-Object -ExpandProperty Verb) -contains ($Command).Verb | Should Be $True
        }
        It "Command $($Command.Name) has a noun." {
          ($Command).Noun | Should Not BeNullOrEmpty
        }

      } #Context "Command Naming Standards 


      Context "Command Documentation > $Command" {

        It "Command $($Command.Name) has a synopsis that is not the syntax." {
          $HelpInfo.Synopsis.Trim() | Should Not BeLike "$FunctionName*"
        }

        $CommandDescription = $HelpInfo.Description | Select-Object -ExpandProperty Text 

        It "Command $($Command.Name) has a description." {
          $CommandDescription | Should Not BeNullOrEmpty
        }

        It "Command $($Command.Name) has a description with at least 5 words." {
          $CommandDescription | 
          Measure-Object -Word | 
          Select-Object -ExpandProperty Words | Should BeGreaterThan 5
        }

        $HasExamplesProperty = !!(Get-Member -InputObject $HelpInfo -Name examples -MemberType NoteProperty)      

        if ($HasExamplesProperty) {
          $Examples = (Select-Object -InputObject $HelpInfo -ExpandProperty examples)
          if ($Examples) {
            $Example = (Get-Member -InputObject $Examples -MemberType NoteProperty -Name example)  
          }
          
        }

        It "Command $($Command.Name) has example(s)." {
          $HasExamplesProperty | Should Be $true
          $Examples | Should Not BeNullOrEmpty 
          $Example | Should Not BeNullOrEmpty
        }

        It "Command $($Command.Name) has notes with Author/Email/Created/Updated." {
          $Notes = ($HelpInfo.alertSet | Select-Object -ExpandProperty alert).Text
          $Notes | Should BeLike '*Author*'
          $Notes | Should BeLike '*Email*'
          $Notes | Should BeLike '*Created*'
          $Notes | Should BeLike '*Updated*'
          $Notes | Should BeLike '*Changelog*'
        }

      } #Context "Command Documentation

    } #ForEach-Object

  } #Describe

} #Invoke-ModuleStandardsTest

#-------------------------------------------------------------------------------

if ($PSVersionTable.PSVersion -eq '2.0') {
  Write-Warning 'PS v2.0. Creating $PSScriptRoot'
  $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}
Write-Verbose $PSScriptRoot

$ProjectRoot = Get-Item (Join-Path $PSScriptRoot '..\')

Push-Location $ProjectRoot | Out-Null

Get-ChildItem -Path $ProjectRoot -Exclude Tests |
Where-Object {$_.PSIsContainer} |
ForEach-Object {

  Write-Verbose "Processing folder $($_.Name)"
  $_ | Invoke-ModuleStandardsTest

}

Pop-Location | Out-Null
