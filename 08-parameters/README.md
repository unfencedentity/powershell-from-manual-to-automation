# Parameters

> Status: Work in progress. Practical exercises will begin after Chapter 07 is completed.

## Purpose

Parameters give scripts and functions a predictable interface.

They allow callers to provide input without modifying the internal implementation of the automation. A well-designed parameter interface makes PowerShell code easier to reuse, validate, test, maintain, and integrate into enterprise workflows.

## Core mental model

```powershell
Get-ServiceReport -Name "Win*"
```

In this invocation:

* `Get-ServiceReport` is the command being invoked;
* `-Name` is the parameter;
* `"Win*"` is the argument supplied by the caller;
* `$Name` is the variable used inside the function.

The general flow is:

```text
caller argument
→ public parameter
→ internal parameter variable
→ function logic
→ output
```

## Learning objectives

By the end of this chapter, I should be able to:

* explain the difference between a parameter and an argument;
* declare parameters using `param()`;
* use clear named parameters during invocation;
* select appropriate parameter types;
* define optional and mandatory parameters;
* assign default values;
* accept single values and collections;
* use switch parameters;
* validate input before the main function logic runs;
* explain basic pipeline parameter binding;
* inspect command syntax when I do not remember it;
* design predictable interfaces for reusable automation.

## Planned topics

### Parameter declarations

```powershell
param(
    [string]$Name
)
```

### Typed parameters

High-value parameter types include:

* `[string]`
* `[int]`
* `[bool]`
* `[switch]`
* `[string[]]`
* `[object]`

### Default values

```powershell
param(
    [string]$Name = "*"
)
```

### Mandatory parameters

```powershell
param(
    [Parameter(Mandatory = $true)]
    [string]$Name
)
```

### Switch parameters

```powershell
param(
    [switch]$IncludeStopped
)
```

### Validation

Planned validation attributes include:

* `ValidateSet`
* `ValidateRange`
* `ValidatePattern`
* `ValidateNotNullOrEmpty`

### Pipeline binding

This chapter will reinforce the distinction between:

```powershell
ValueFromPipeline
```

and:

```powershell
ValueFromPipelineByPropertyName
```

### Parameter discovery

Useful discovery commands include:

```powershell
Get-Command Get-Service -Syntax
Get-Help Get-Service -Parameter Name
Get-Help Get-Service -Examples
```

## Engineering relevance

Parameters are used to create reusable automation for scenarios such as:

* querying Windows services;
* generating system reports;
* filtering processes;
* building Azure resource names;
* selecting tenants, subscriptions, and environments;
* validating infrastructure configuration;
* safely controlling optional behavior;
* integrating scripts with GitHub Actions and enterprise pipelines.

## Interview focus

Interview exercises may require me to:

* identify the inputs required by a function;
* distinguish parameters from arguments;
* add a parameter to repeated logic;
* choose an appropriate parameter type;
* make a parameter mandatory or optional;
* provide a sensible default value;
* accept multiple values;
* validate allowed input;
* diagnose why parameter binding failed;
* explain how the interface could be used in enterprise automation.

## Planned repository files

* `README.md` — concepts, reasoning, examples, and troubleshooting;
* `exercise.ps1` — practical and interview-style exercises;
* `solution.ps1` — reviewed reference implementations.

The exercise and solution files will be created only after the concepts have been practised interactively.

## Completion criteria

This chapter will be considered complete when I can:

* design a parameter interface from a written requirement;
* write the corresponding `param()` block independently;
* invoke the function correctly;
* explain how each argument reaches its parameter variable;
* validate and troubleshoot the interface using PowerShell discovery tools.

