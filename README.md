# PowerShell — From Manual to Automation

A practical PowerShell learning and engineering repository built around one progression:

> **Understand the language → automate real tasks → build reliable, reusable automation.**

The goal is not to memorize cmdlets. It is to understand how PowerShell works with objects, data, the pipeline, functions, systems, and external services — then use those concepts to turn manual administrative work into structured automation.

---

## Mission

Build PowerShell skills from first principles and progressively apply them to real-world IT, cloud, and systems administration scenarios.

The repository moves from individual language concepts toward complete automation workflows:

```text
Manual Task
    ↓
Understand the Data
    ↓
PowerShell Objects
    ↓
Pipeline & Filtering
    ↓
Reusable Functions
    ↓
Validated Input
    ↓
Files & Structured Data
    ↓
Error Handling
    ↓
APIs & Remote Systems
    ↓
Reusable Modules
    ↓
Production-Style Automation
```

---

## Learning Principles

This repository follows a few simple rules:

- Understand **why** something works before relying on it.
- Work with **objects**, not just command output.
- Prefer practical exercises over isolated syntax memorization.
- Build reusable functions instead of repeating manual steps.
- Validate assumptions and inputs.
- Treat errors as part of automation design.
- Produce structured output that can be consumed by other tools.
- Progress from small scripts toward maintainable automation.

---

## Roadmap

### 01 — Variables
Values, types, assignment, interpolation, and basic state management.

### 02 — Arrays
Collections, indexing, iteration, and working with multiple values.

### 03 — Objects
Properties, methods, object inspection, `PSCustomObject`, and structured data.

### 04 — Pipeline
Passing objects between commands and composing operations.

### 05 — Filtering
Selecting objects based on conditions using `Where-Object` and comparison/logical operators.

### 06 — Selecting and Sorting
Shaping output with `Select-Object` and ordering data with `Sort-Object`.

### 07 — Functions
Encapsulating logic into reusable commands.

### 08 — Parameters
Typed parameters, validation, switches, pipeline input, and advanced function behavior.

### 09 — Files
Paths, file objects, reading and writing content, filesystem operations, and script-relative paths.

### 10 — CSV
Importing tabular data as objects, processing it through the pipeline, and exporting structured results.

### 11 — JSON
Working with nested structured data and converting between JSON and PowerShell objects.

### 12 — Error Handling
`try`, `catch`, `finally`, terminating errors, `throw`, and predictable failure handling.

### 13 — REST APIs
Sending HTTP requests, working with API responses, authentication concepts, and integrating external services.

### 14 — Remoting
Executing PowerShell against remote systems and designing automation beyond the local machine.

### 15 — Modules
Organizing reusable functions into maintainable PowerShell modules.

### 16 — Automation
Combining the previous concepts into complete real-world automation workflows.

---

## From Scripts to Automation

The roadmap is intentionally cumulative.

A real automation task may eventually combine:

```powershell
Input
  |
  v
Validate
  |
  v
Import / Discover
  |
  v
Filter & Transform
  |
  v
Execute Logic
  |
  v
Handle Errors
  |
  v
Return Structured Objects
  |
  v
Log / Export / Integrate
```

The individual chapters are building blocks. The end goal is being able to look at a manual operational task, decompose it into steps, and engineer a reliable PowerShell solution.

---

## Repository Structure

```text
powershell-from-manual-to-automation/
│
├── 01-variables/
├── 02-arrays/
├── 03-objects/
├── 04-pipeline/
├── 05-filtering/
├── 06-selecting-and-sorting/
├── 07-functions/
├── 08-parameters/
├── 09-files/
├── 10-csv/
├── 11-json/
├── 12-error-handling/
├── 13-rest-apis/
├── 14-remoting/
├── 15-modules/
├── 16-automation/
│
├── resource-group-scripts/
└── README.md
```

Each chapter can contain theory, exercises, solutions, and practical examples while remaining part of the same chronological learning path.

---

## End Goal

The destination is not simply knowing PowerShell syntax.

It is being able to move from:

> **“I can perform this task manually.”**

to:

> **“I can model the task, validate its inputs, automate it safely, handle failures, and produce reusable structured output.”**

That is the transition from **manual administration to automation engineering**.
