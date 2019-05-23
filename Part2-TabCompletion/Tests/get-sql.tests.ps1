param( [switch] $test )

if ((Get-Module pester).Version -lt '4.0.0.0')
{
    throw 'This required Pester 4+.  Use Install-Module -Name Pester -Force'
}

Import-Module (Join-Path $PSScriptRoot ..\RegisterArgumentCompleter.psm1)

# We can't use Pester to test the Register-ArgumentCompleter interaction, but can make sure the functions work

Describe "Get-Localhost" {
    It "Tests Positive" {
        Get-LocalHost localhost | Should be localhost
    }
 }

 Describe "Get-SQLTable" {
    It "Tests Positive" {
        'Customers' | Should -BeIn (Get-SQLTable -Database Northwind | Select-Object -expand name)
    }
 }

 Describe "Get-SQLColumn" {
    It "Tests Positive" {
        'Address' | Should -BeIn (Get-SQLColumn -Database Northwind -Table Customers | Select-Object -expand NAME)
    }
 }

 Describe "Get-SQLRow" {
    It "Tests Select *" {
        'BLAUS' | Should -BeIn (Get-SQLRow -Database Northwind -Table Customers -Column * | Select-Object -expand CustomerID)
    }

    It "Tests Select and sort" {
        $rows = Get-SQLRow -Database Northwind -Table Customers -Column CustomerID,CompanyName -OrderBy CompanyName
        $rows | Select-Object -expand CustomerID -First 1 | Should -Be 'ALFKI'
    }
 }

