# Arrays

## Objective

Learn how to store and process multiple values using arrays.

By the end of this lesson you will be able to:

- Create arrays
- Access elements by index
- Retrieve the first and last element
- Count the number of elements
- Iterate through an array using `foreach`
- Generate arrays dynamically

---

## Why Arrays?

Variables store a single value.

Arrays store multiple related values in a single variable.

Example:

```powershell
$servers = @(
    "web-01"
    "web-02"
    "db-01"
)
```

---

## Key Concepts

### Create an array

```powershell
$servers = @(
    "web-01"
    "web-02"
)
```

### Access elements

```powershell
$servers[0]
$servers[1]
$servers[-1]
```

### Count elements

```powershell
$servers.Count
```

### Iterate through an array

```powershell
foreach ($server in $servers) {
    Write-Host $server
}
```

### Generate arrays dynamically

```powershell
$servers = foreach ($i in 1..1000) {
    "server$i"
}
```

---

## Mental Model

```
Collection

↓

Access

↓

Count

↓

foreach

↓

Process each item
```

---

## Files

- `exercise.ps1` - Practice exercises
- `solution.ps1` - Reference implementation
