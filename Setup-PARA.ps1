<#
.SYNOPSIS
    Creates a full PARA development structure with README templates,
    starter files, and optional Git initialization.

.DESCRIPTION
    This script:
      - Builds an ordered PARA folder hierarchy
      - Creates README.md templates with metadata
      - Generates starter files based on folder semantics
      - Initializes Git repos only in Projects + Areas
      - Performs a silent Git capability check
      - Logs all actions cleanly and consistently

.PARAMETER RootPath
    The root directory where PARA will be created.
    Defaults to $HOME\Dev.

.EXAMPLE
    .\Setup-PARA.ps1
    .\Setup-PARA.ps1 -RootPath "C:\MyDev"
#>

param(
    [string]$RootPath = "$HOME\Dev"
)

# -----------------------------
# Utility: Timestamp
# -----------------------------
function New-Timestamp {
    return (Get-Date -Format "yyyy-MM-dd")
}

# -----------------------------
# Utility: Write formatted logs
# -----------------------------
function Log {
    param([string]$Message)
    Write-Host "[PARA] $Message"
}

# -----------------------------
# Git capability check
# -----------------------------
function Test-Git {
    try {
        git --version *>$null
        return $true
    } catch {
        Log "Git not found — skipping Git initialization."
        return $false
    }
}

$GitAvailable = Test-Git

# -----------------------------
# PARA Structure Definition
# -----------------------------
$Folders = [ordered]@{
    "1_Projects"  = @("Python", "JavaScript", "Web", "C++", "Docker")
    "2_Areas"     = @("Learning", "Career", "Systems")
    "3_Resources" = @("Notes", "References")
    "4_Archives"  = @("Old_Projects", "Old_Notes")
}

# -----------------------------
# README Template Generator
# -----------------------------
function New-Readme {
    param(
        [string]$Path,
        [string]$Category
    )

    $Content = @"
# $(Split-Path $Path -Leaf)
**Created:** $(New-Timestamp)  
**Category:** $Category  

## Purpose
Describe the purpose of this folder.

## Active Recall
- What is the main objective here?
- What is the next action?
"@

    Set-Content -Path (Join-Path $Path "README.md") -Value $Content -Encoding UTF8
}

# -----------------------------
# Starter File Generator
# -----------------------------
function New-StarterFiles {
    param([string]$Path)

    $Name = Split-Path $Path -Leaf

    switch -Regex ($Name) {

        # Python
        "(?i)python" {
            Set-Content -Path (Join-Path $Path "main.py") `
                -Value 'print("Hello from Python!")' -Encoding UTF8
            break
        }

        # JavaScript
        "(?i)javascript" {
            Set-Content -Path (Join-Path $Path "index.js") `
                -Value 'console.log("Hello from JavaScript!");' -Encoding UTF8
            break
        }

        # Web (HTML / CSS / Portfolio)
        "(?i)html|css|portfolio|web" {
            $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$Name</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>$Name</h1>
    <script src="script.js"></script>
</body>
</html>
"@
            $css = @"
/* $Name styles */
* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

body {
    font-family: sans-serif;
}
"@
            Set-Content -Path (Join-Path $Path "index.html") -Value $html -Encoding UTF8
            Set-Content -Path (Join-Path $Path "style.css")  -Value $css  -Encoding UTF8
            Set-Content -Path (Join-Path $Path "script.js")  -Value "// $Name scripts" -Encoding UTF8
            break
        }

        # C++
        "(?i)c\+\+|cpp" {
            $cpp = @"
#include <iostream>

int main() {
    std::cout << "Hello from $Name!" << std::endl;
    return 0;
}
"@
            Set-Content -Path (Join-Path $Path "main.cpp") -Value $cpp -Encoding UTF8
            break
        }

        # Docker
        "(?i)docker" {
            $dockerfile = @"
FROM ubuntu:22.04

WORKDIR /app

# Copy project files
# COPY . .

# Install dependencies
# RUN apt-get update && apt-get install -y <packages>

# Define entry point
# CMD ["bash"]
"@
            Set-Content -Path (Join-Path $Path "Dockerfile") -Value $dockerfile -Encoding UTF8
            break
        }
    }
}

# -----------------------------
# Main loop
# -----------------------------
Log "========================================="
Log "  PARA Development Environment Setup"
Log "========================================="

foreach ($Category in $Folders.Keys) {

    $CategoryPath = Join-Path $RootPath $Category

    if (-not (Test-Path $CategoryPath)) {
        New-Item -ItemType Directory -Path $CategoryPath | Out-Null
        Log "[+] Created category: $Category"
    } else {
        Log "[ ] Category exists:  $Category"
    }

    foreach ($Subfolder in $Folders[$Category]) {

        $SubfolderPath = Join-Path $CategoryPath $Subfolder

        if (-not (Test-Path $SubfolderPath)) {
            New-Item -ItemType Directory -Path $SubfolderPath | Out-Null
            Log "    [+] Created: $Subfolder"

            # README template
            New-Readme -Path $SubfolderPath -Category $Category

            # Context-aware starter files
            New-StarterFiles -Path $SubfolderPath

            # Git initialization for Projects and Areas only
            if ($GitAvailable -and ($Category -eq "1_Projects" -or $Category -eq "2_Areas")) {
                Push-Location $SubfolderPath
                git init --quiet
                Pop-Location
                Log "        [git] Repository initialized in $Subfolder"
            }

        } else {
            Log "    [ ] Exists:   $Subfolder"
        }
    }
}

Log "========================================="
Log "  Lexicon setup complete!"
Log "  Your PARA development environment"
Log "  is now aligned with your framework."
Log "========================================="
