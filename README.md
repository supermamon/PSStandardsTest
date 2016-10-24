PSStandardsTest
===============

## What is this?
Refer to [Tests/Standards.Tests.ps1](https://github.com/supermamon/PSStandardsTest/tree/master/Tests).

What the script does is to loop through all the modules and commands in your
project and perform some standards test on your naming and documentation.

A sample project structure is this whole repo, visualized below.

````
PSStandardsTest
│   LICENSE
│   README.md
│
├───AModule
│   │   AModule.Format.ps1xml
│   │   AModule.psd1
│   │   AModule.psm1
│   │
│   ├───Private
│   ├───Public
│   │       Invoke-Function1.ps1
│   │       Invoke-Function2.ps1
│   │
│   └───Resources
├───AnotherModule
│   │   AnotherModule.Format.ps1xml
│   │   AnotherModule.psd1
│   │   AnotherModule.psm1
│   │
│   ├───Private
│   ├───Public
│   │       Invoke-Function3.ps1
│   │
│   └───Resources
└───Tests
        Standards.Tests.ps1
````

## ChangeLog
* 2016-10-24: Very first draft.
