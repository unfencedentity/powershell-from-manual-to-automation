# Variables

## Objective

Learn how to store and reuse data using variables.

By the end of this lesson you will be able to:

- create variables
- use meaningful variable names
- build strings dynamically
- understand string interpolation
- avoid hardcoded values

---

## What is a variable?

A variable is a named container that stores data in memory.

Instead of writing the same value multiple times, we store it once and reuse it whenever needed.

---

## Why do variables exist?

Without variables:

```powershell
"rg-core-prod-weu"
```

Changing the environment requires editing every occurrence.

With variables:

```powershell
$app = "core"
$environment = "prod"
$region = "weu"

$resourceGroupName = "rg-$app-$environment-$region"
```

Changing one variable updates the final result automatically.

---

## Syntax

```powershell
$name = "Lucian"

$age = 33

$isAdmin = $true
```

---

## Variable naming

Good

```powershell
$resourceGroupName
$storageAccountName
$environment
```

Bad

```powershell
$a
$x
$temp
```

Use names that explain the purpose.

---

## String Interpolation

PowerShell replaces variables automatically inside double quotes.

```powershell
$app = "cloud-org"

Write-Host "Application: $app"
```

Output

```text
Application: cloud-org
```

---

## Enterprise Example

```powershell
$app = "core"
$environment = "prod"
$region = "weu"

$resourceGroupName = "rg-$app-$environment-$region"

Write-Host $resourceGroupName
```

Output

```text
rg-core-prod-weu
```

---

## Best Practices

- Use descriptive names.
- Avoid hardcoded values.
- Keep naming consistent.
- One purpose per variable.

---

## Common Mistakes

Using generic names

```powershell
$a = "prod"
```

Instead of

```powershell
$environment = "prod"
```

---

## Exercise

See:

- exercise.ps1

---

## Solution

See:

- solution.ps1

---

## Interview Questions

### What is a variable?

A variable is a named container that stores data in memory.

---

### Why should variables be preferred over hardcoded values?

Variables improve readability, maintainability and reusability.

---

### What is string interpolation?

PowerShell automatically replaces variables inside double quotes with their values.

---

## Key Takeaways

✅ Variables store data.

✅ Variables make scripts reusable.

✅ Use descriptive variable names.

✅ Prefer variables over hardcoded values.

✅ PowerShell supports string interpolation using double quotes.
