# Objects

## Problem

How do we discover what a value knows and what it can do?

PowerShell solves this by representing everything as objects.

Instead of memorizing commands, we can inspect objects and discover their capabilities.

---

## What is an object?

An object is an instance of a type that contains:

- Properties (information)
- Methods (actions)

Example:

```powershell
$name = "Lucian"
```

`$name` is not just text.

It is an object of type:

```text
System.String
```

---

## Properties

Properties describe an object.

They provide information without modifying the object.

Example:

```powershell
$name.Length
```

---

## Methods

Methods perform actions.

They usually return a new value or perform an operation.

Examples:

```powershell
$name.ToUpper()

$name.Replace("a", "X")

$name.Contains("ci")
```

---

## Inspecting objects

When working with an unknown object, always ask two questions.

### What type is it?

```powershell
.GetType()
```

### What can it do?

```powershell
Get-Member
```

These two commands are among the most important tools in PowerShell.

---

## Common object types

```text
System.String
```

Represents text.

```text
System.Int32
```

Represents a whole number.

```text
System.Boolean
```

Represents `True` or `False`.

```text
System.Array
```

Represents a collection of objects.

```text
System.DateTime
```

Represents a date and time.

---

## Cmdlets return objects

Objects are not limited to variables.

Cmdlets also return objects.

Example:

```powershell
Get-Date
```

returns a `System.DateTime` object.

This allows us to access properties such as:

```powershell
(Get-Date).Year

(Get-Date).Month

(Get-Date).Day
```

---

## Mental Model

```
Object
    │
    ├── Properties
    │      Read information
    │
    └── Methods
           Perform actions

Inspect
    │
    ├── GetType()
    └── Get-Member
```

---

## Real-world examples

Azure VM

```powershell
Get-AzVM
```

Processes

```powershell
Get-Process
```

Services

```powershell
Get-Service
```

Files

```powershell
Get-ChildItem
```

Date and Time

```powershell
Get-Date
```

All of them return objects.

---

## Interview Questions

- What is an object?
- What is the difference between a property and a method?
- How do you inspect an unknown object?
- What does `GetType()` return?
- What does `Get-Member` show?
- What is `System.String`?
- Why doesn't `Replace()` modify the original string?
- Why is PowerShell object-oriented?

---

## Key Takeaways

- Everything in PowerShell is an object.
- Objects contain properties and methods.
- Use `GetType()` to identify an object's type.
- Use `Get-Member` to discover an object's capabilities.
- PowerShell works with objects rather than plain text.
- Learn how to inspect objects instead of memorizing them.
