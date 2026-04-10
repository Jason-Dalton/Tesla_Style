# Setup-PARA.ps1
# Automates creation of a PARA-structured development environment with
# directory scaffolding, README templates, starter files, and Git initialization.

param(
    [string]$RootPath = "$HOME\Dev"
)

# ---------------------------------------------------------------------------
# PARA structure definition
# ---------------------------------------------------------------------------
$folders = [ordered]@{
    "1_Projects"  = @(
        "EdX_Python_Course",
        "Personal_AI_Lexicon",
        "Portfolio_Website"
    )
    "2_Areas"     = @(
        "Automation_Scripts",
        "Snippets_HTML_CSS",
        "DevOps_Docker"
    )
    "3_Resources" = @(
        "Learning\Python_Fundamentals",
        "Learning\Algorithms",
        "Learning\JavaScript_Active_Recall",
        "Sandboxes\Throwaway_Code",
        "Libraries\Components"
    )
    "4_Archive"   = @(
        "Legacy_Tutorials",
        "Old_Experiments"
    )
}

# ---------------------------------------------------------------------------
# Git availability check
# ---------------------------------------------------------------------------
$gitAvailable = $false
try {
    git --version 2>&1 | Out-Null
    $gitAvailable = $true
} catch {
    Write-Host "Git not found – repository initialization will be skipped." -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# Helper: Generate README.md
# ---------------------------------------------------------------------------
function New-ReadMe {
    param(
        [string]$FolderPath,
        [string]$FolderName,
        [string]$ParaCategory
    )

    $date    = Get-Date -Format "yyyy-MM-dd"
    $content = @"
# $FolderName

**Created:** $date  
**PARA Category:** $ParaCategory

---

## Purpose

<!-- Describe the goal of this project / resource here. -->

## Notes / Active Recall

<!-- Add key takeaways, questions, and reminders here. -->
"@
    Set-Content -Path (Join-Path $FolderPath "README.md") -Value $content -Encoding UTF8
}

# ---------------------------------------------------------------------------
# Helper: Generate context-aware starter files
# ---------------------------------------------------------------------------
function New-StarterFiles {
    param(
        [string]$FolderPath,
        [string]$FolderName
    )

    switch -Regex ($FolderName) {

        # Python
        "(?i)python|algo" {
            $py = @"
def main():
    print("Hello from $FolderName!")

if __name__ == "__main__":
    main()
"@
            Set-Content -Path (Join-Path $FolderPath "main.py") -Value $py -Encoding UTF8
            break
        }

        # JavaScript
        "(?i)javascript|js|recall" {
            $js = 'console.log("' + $FolderName + ' initialized.");'
            Set-Content -Path (Join-Path $FolderPath "index.js") -Value $js -Encoding UTF8
            break
        }

        # Web (HTML / CSS / Portfolio)
        "(?i)html|css|portfolio|web|snippet" {
            $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$FolderName</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>$FolderName</h1>
    <script src="script.js"></script>
</body>
</html>
"@
            $css = @"
/* $FolderName styles */
* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

body {
    font-family: sans-serif;
}
"@
            $js = "// $FolderName scripts"

            Set-Content -Path (Join-Path $FolderPath "index.html")  -Value $html -Encoding UTF8
            Set-Content -Path (Join-Path $FolderPath "style.css")   -Value $css  -Encoding UTF8
            Set-Content -Path (Join-Path $FolderPath "script.js")   -Value $js   -Encoding UTF8
            break
        }

        # C++
        "(?i)cpp|c\+\+" {
            $cpp = @"
#include <iostream>

int main() {
    std::cout << "Hello from $FolderName!" << std::endl;
    return 0;
}
"@
            Set-Content -Path (Join-Path $FolderPath "main.cpp") -Value $cpp -Encoding UTF8
            break
        }

        # Docker
        "(?i)docker|devops|container" {
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
            Set-Content -Path (Join-Path $FolderPath "Dockerfile") -Value $dockerfile -Encoding UTF8
            break
        }
    }
}

# ---------------------------------------------------------------------------
# Main loop – create directories, README, starter files, and Git repos
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PARA Development Environment Setup   " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($category in $folders.Keys) {

    $categoryPath = Join-Path $RootPath $category

    if (-not (Test-Path $categoryPath)) {
        New-Item -ItemType Directory -Path $categoryPath | Out-Null
        Write-Host "[+] Created category: $category" -ForegroundColor Green
    } else {
        Write-Host "[ ] Category exists:  $category" -ForegroundColor DarkGray
    }

    foreach ($subfolder in $folders[$category]) {

        $subfolderPath = Join-Path $categoryPath $subfolder
        $leafName      = Split-Path $subfolder -Leaf

        if (-not (Test-Path $subfolderPath)) {
            New-Item -ItemType Directory -Path $subfolderPath | Out-Null
            Write-Host "    [+] Created: $subfolder" -ForegroundColor Green

            # README template
            New-ReadMe -FolderPath $subfolderPath -FolderName $leafName -ParaCategory $category

            # Context-aware starter files
            New-StarterFiles -FolderPath $subfolderPath -FolderName $leafName

            # Git initialization for Projects and Areas only
            if ($gitAvailable -and ($category -eq "1_Projects" -or $category -eq "2_Areas")) {
                Push-Location $subfolderPath
                git init --quiet
                Pop-Location
                Write-Host "        [git] Repository initialized in $leafName" -ForegroundColor Magenta
            }

        } else {
            Write-Host "    [ ] Exists:   $subfolder" -ForegroundColor DarkGray
        }
    }

    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Lexicon setup complete!              " -ForegroundColor Cyan
Write-Host "  Your PARA development environment    " -ForegroundColor Cyan
Write-Host "  is now aligned with your framework.  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
