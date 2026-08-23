# Chapter 10 — CSV

## Status

Not started.

This chapter will be completed progressively through guided practice.
`exercise.ps1` and `solution.ps1` are intentionally scaffolds until the
practical work is complete.

---

## Objective

Learn how to export PowerShell objects to CSV, import CSV data back into the
pipeline, validate tabular input, and build reliable inventory and reporting
workflows for enterprise automation.

---

## Planned practical order

1. PowerShell objects versus CSV text
2. Rows, columns, headers, and properties
3. Creating sample `PSCustomObject` collections
4. `Export-Csv` and `-NoTypeInformation`
5. Inspecting exported files with `Get-Content`
6. `Import-Csv` and imported `PSCustomObject` instances
7. The fact that imported CSV field values are strings
8. Filtering, selecting, and sorting imported rows
9. Delimiters and encoding
10. Safe overwrite and append behavior
11. Validating paths and required CSV columns
12. Transforming imported rows into typed output objects
13. A cumulative enterprise inventory/reporting function
14. Interview and live-coding recap
15. Final chapter files

---

## Enterprise focus

The chapter will use scenarios such as:

- exporting server and service inventory;
- importing deployment targets;
- validating required columns before automation;
- filtering operational reports;
- preparing structured data for later JSON and REST API workflows.

---

## Safety rules

- Perform all practical file operations inside a dedicated temporary lab.
- Build exact paths with `Join-Path`.
- Validate input and output paths with `Test-Path`.
- Do not overwrite existing files without understanding the intended behavior.
- Do not use `Force` without a specific requirement and exact target validation.

---

## Files

- `README.md` — chapter documentation, completed after guided practice;
- `exercise.ps1` — exercise requirements, completed after guided practice;
- `solution.ps1` — reviewed reference solutions, completed last.

---

## Completion criteria

To be defined and finalized after the practical chapter is complete.
