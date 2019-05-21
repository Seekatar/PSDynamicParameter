param( [switch] $test )

Import-Module (Join-Path $PSScriptRoot ..\GetAnimals.psm1) -Force

Describe "Get-Animal0" {
    It "Tests Positive" {
        Get-Animal0 -Animal cow | Should be 'cow'
    }
    It "TestsNegative" {
        {Get-Animal0 -Animal red} | Should throw
    }
    It "TestsNoParam" {
        {Get-Animal0} | Should not throw
    }
 }

 Describe "Get-Animal1" {
    It "Tests Positive" {
        Get-Animal1 -Animal cow | Should be 'cow'
    }
    It "TestsNegative" {
        {Get-Animal1 -Animal red} | Should throw
    }
    It "TestsNoParam" {
        {Get-Animal1} | Should not throw
    }
 }

 Describe "Get-Animal2" {
    It "Tests Positive" {
        Get-Animal2 -Animal cow | Should be 'cow'
    }
    It "Tests Positive Wild" {
        Get-Animal2 -Wild -Animal 'clouded leopard' | Should be 'clouded leopard'
    }
    It "TestsNegative" {
        {Get-Animal2 -Animal red} | Should throw
    }
    It "TestsNoParam" {
        {Get-Animal2} | Should not throw
    }
 }

 Describe "Get-Animal3" {
    It "Tests Positive" {
        Get-Animal3 -Animal cow | Should be 'cow'
    }
    It "TestsNegative" {
        {Get-Animal3 -Animal red} | Should throw
    }
    It "TestsNoParam" {
        {Get-Animal3} | Should not throw
    }
 }

 Describe "Get-Animal4" {
    It "Tests Positive" {
        Get-Animal4 -Animal cow | Should be 'cow'
    }
    It "Tests Positive Wild" {
        Get-Animal4 -Wild -Animal 'clouded leopard' | Should be 'clouded leopard'
    }
    It "TestsNegative" {
        {Get-Animal4 -Animal red} | Should throw
    }
    It "TestsNoParam" {
        {Get-Animal4} | Should not throw
    }
 }

 Describe "Get-AnimalAndColor" {
    It "Tests Positive" {
        Get-AnimalAndColor -Animal cow -Color red | Should be 'cow','red'
    }
    It "TestsNegativeBadParam1" {
        {Get-AnimalAndColor -Animal red -Color red} | Should throw
    }
    It "TestsNegativeBadParam2" {
        {Get-AnimalAndColor -Animal pig -Color pig} | Should throw
    }
 }


 Describe "Get-AnimalPipeline" {
    It "Tests Positive" {
        "pig","horse" | Get-AnimalFromPipeline | Should be 'pig','horse'
    }
    # Pester throws on this
    # It "TestsNegative" {
    #     {"pig","horse","owl" | Get-AnimalFromPipeline} | Should throw
    # }
}

Describe "test no param name" {
    It "Tests Positive" {
        Get-Animal4 pig | Should be 'pig'
    }
    It "Tests Positive Static" {
        Get-Animal4 'clouded leopard' -wild | Should be 'clouded leopard'
    }
    It "Tests Positive Static" {
        Get-Animal4 -wild 'tiger' | Should be 'tiger'
    }
}

Describe "test no bindings" {
    It "Tests no Cmdletbinding" {
        Get-AnimalNoBinding -Animal pig | Should be $null
    }
}

Describe "positional tests" {
    It "Tests Positive No ParamName" {
        Get-AnimalAndColor cow red | Should be 'cow','red'
    }
    It "Tests Negative No ParamName" {
        {Get-AnimalAndColor red cow} | Should throw
    }
    It "Tests Positive Dynamic First No ParamName" {
        Get-AnimalStaticColorDynamicFirst cow -Color red | Should be ('cow','red')
    }
    It "Tests Negative Dynamic First ParamName" {
        {Get-AnimalStaticColorDynamicFirst red cow} | Should throw
    }
    It "Tests Positive Static First ParamName" {
        Get-AnimalStaticColorStaticFirst red cow | Should be 'cow','red'
    }
    It "Tests Negative Static First ParamName" {
        {Get-AnimalStaticColorStaticFirst cow red} | Should throw
    }
}
