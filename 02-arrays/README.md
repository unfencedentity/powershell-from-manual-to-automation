# Chapter 02 — Arrays

## Objective

Learn how to store, inspect, and process multiple related values as one collection.

The objective is not only to create an array. It is to understand when a requirement describes one value, when it describes many values, and how PowerShell processes each item safely and predictably.

By the end of this chapter, you should be able to:

- create arrays;
- distinguish a single value from a collection;
- access elements by index;
- retrieve the first and last elements;
- count elements;
- iterate with `foreach`;
- generate a new array dynamically;
- recognize empty and single-item collection edge cases;
- explain how arrays support enterprise automation.

## Why arrays exist

A variable can reference one value:

```powershell
$environment = "dev"
```

Automation often needs to work with several related values:

```text
dev
test
prod
```

An array stores those values as one collection:

```powershell
$environments = "dev", "test", "prod"
```

The collection can then be counted, indexed, iterated, passed to commands, or transformed into another collection.

## Mental model

```text
Several related values
        ↓
Store one collection
        ↓
Access or count its elements
        ↓
Process each element
        ↓
Produce results
```

Conceptually:

```text
$environments
├── [0] dev
├── [1] test
└── [2] prod
```

Each element has a zero-based index.

## Creating arrays

Use commas to create an array:

```powershell
$environments = "dev", "test", "prod"
```

The array subexpression syntax is also useful for a multiline collection:

```powershell
$servers = @(
    "web-01"
    "web-02"
    "db-01"
)
```

PowerShell writes each value inside `@(...)` into the resulting collection.

Inspect the value:

```powershell
$environments
$environments.GetType().FullName
$environments | Get-Member
```

## Accessing elements by index

Array indexes start at zero:

```powershell
$environments[0]
$environments[1]
$environments[2]
```

Output:

```text
dev
test
prod
```

Use `-1` for the final element:

```powershell
$environments[-1]
```

Output:

```text
prod
```

Multiple indexes can be requested:

```powershell
$environments[0, 2]
```

Output:

```text
dev
prod
```

## Counting elements

Use the `Count` property:

```powershell
$environments.Count
```

Output:

```text
3
```

`Count` describes how many elements are currently in the collection. It does not describe the highest index.

For three elements:

```text
Count         = 3
Valid indexes = 0, 1, 2
Last index    = Count - 1
```

## Processing every element with foreach

A `foreach` statement repeats a block once for every element:

```powershell
foreach ($environment in $environments) {
    "Environment: $environment"
}
```

Output:

```text
Environment: dev
Environment: test
Environment: prod
```

Read the statement as:

> For each value in `$environments`, temporarily store the current value in `$environment` and execute the block.

The variable roles are different:

```text
$environments → complete collection
$environment  → current element
```

Choose a plural name for the collection and a singular name for the current item.

## Returning values from foreach

Uncaptured values produced inside `foreach` enter the success output stream:

```powershell
foreach ($environment in $environments) {
    "rg-core-$environment-weu"
}
```

The loop produces three strings.

Capture those strings to create a new collection:

```powershell
$resourceGroupNames = foreach ($environment in $environments) {
    "rg-core-$environment-weu"
}

$resourceGroupNames
```

Output:

```text
rg-core-dev-weu
rg-core-test-weu
rg-core-prod-weu
```

This pattern transforms one collection into another:

```text
environment values
        ↓
foreach transformation
        ↓
resource group names
```

## Arrays can contain objects

An array does not need to contain only strings:

```powershell
$values = @(
    "dev"
    3
    $true
    (Get-Date)
)
```

PowerShell arrays can contain objects of different types. Enterprise automation is usually easier to reason about when elements have a consistent purpose and shape.

Commands can also return collections of objects:

```powershell
$processes = Get-Process
$services = Get-Service
```

The collection may contain process objects or service objects rather than plain strings.

## One value versus multiple values

This is one string:

```powershell
$environment = "prod"
```

This is an array of three strings:

```powershell
$environments = "dev", "test", "prod"
```

This distinction affects:

- indexing;
- iteration;
- parameter design;
- pipeline behavior;
- the number of output objects;
- validation and error handling.

Chapter 08 revisits this distinction when choosing between `[string]` and `[string[]]` parameters.

## Empty and single-item results

PowerShell may represent command output differently depending on how many objects were produced:

```text
No output       → $null
One output      → one scalar object
Several outputs → a collection
```

Use the array subexpression operator when the result must always behave like a collection:

```powershell
$services = @(Get-Service -Name "Win*")

$services.Count
```

Now `Count` can be interpreted consistently even if the command returns zero, one, or several objects.

Do not add `@(...)` automatically everywhere. Use it when a stable collection shape is part of the requirement.

## Arrays versus pipeline input

An array can be passed through the pipeline:

```powershell
"dev", "test", "prod" |
    ForEach-Object {
        "Environment: $_"
    }
```

The pipeline enumerates the array and sends its elements individually.

This differs from passing one array as a single command argument. Parameter binding and pipeline behavior are covered in Chapters 04, 07, and 08.

## Common mistakes

### Using an invalid index

```powershell
$environments[3]
```

An array with a `Count` of `3` has valid indexes `0`, `1`, and `2`.

### Confusing Count with the last index

```powershell
$environments[$environments.Count]
```

Use:

```powershell
$environments[$environments.Count - 1]
```

or:

```powershell
$environments[-1]
```

### Reusing plural and singular names incorrectly

Unclear:

```powershell
foreach ($environments in $environments) {
    $environments
}
```

Clear:

```powershell
foreach ($environment in $environments) {
    $environment
}
```

### Printing instead of capturing generated values

```powershell
foreach ($environment in $environments) {
    "rg-core-$environment-weu"
}
```

This produces output but does not store it for later reuse.

Capture the loop output when another operation needs the collection:

```powershell
$resourceGroupNames = foreach ($environment in $environments) {
    "rg-core-$environment-weu"
}
```

### Assuming every command result is always an array

A command that produces one object may return a scalar. Use `@(...)` when the consumer requires a predictable collection.

## Enterprise applications

Arrays commonly represent:

- server names;
- service names;
- Azure subscriptions;
- environments and regions;
- resource identifiers;
- file paths;
- users or groups;
- objects returned by infrastructure commands or REST APIs.

Example:

```powershell
$environments = "dev", "test", "prod"

$resourceGroupNames = foreach ($environment in $environments) {
    "rg-core-$environment-weu"
}
```

The same automation logic is applied consistently to every approved environment.

## Interview recap

### What is an array?

An array is a collection that stores multiple objects and allows them to be accessed or processed as one value.

### What index does the first element use?

PowerShell arrays are zero-indexed, so the first element uses index `0`.

### How do you access the last element?

Use index `-1`, or use `Count - 1` as the final zero-based index.

### What does the Count property represent?

`Count` returns the number of elements in the collection.

### What is the difference between the collection variable and the foreach variable?

The collection variable references all elements. The `foreach` variable references the current element during one iteration.

### How can foreach create a new array?

Assign the output of the entire `foreach` statement to a variable. Every value written to the success stream by the loop becomes part of the result.

### Why might you wrap command output in `@(...)`?

It forces the result into a collection so zero, one, and many output objects can be handled consistently when that shape is required.

## Exercises

The practical files contain exercises for:

1. creating an environment array;
2. retrieving the first and final elements;
3. counting the elements;
4. processing each environment with `foreach`;
5. generating one Azure resource group name per environment.

Files:

- `exercise.ps1` — independent practice;
- `solution.ps1` — reference implementation.

## Key takeaway

```text
Collection
    ↓
Index or count
    ↓
Process each element
    ↓
Capture reusable results
```

Arrays let one piece of automation work consistently with multiple related values instead of duplicating logic for every item.
