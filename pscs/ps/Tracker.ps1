#Requires -Version 5

enum TaskState {
  Proposed
  Backlog
  Active
  Sideburner
  Closed
  Rejected
}

enum TaskSize {
  Small
  Medium
  Large
  XLarge
  Unknown
}

class Task {
  [string] $Title
  [TaskSize] $Size
  [guid] $Id
  [TaskState] $State
  [string[]] $Description
  [string[]] $Notes


   # Constructor
   Task ([string] $t) {
     $this.Title = $t
     $this.Id = [guid]::NewGuid()
   }

   Task([PSCustomObject]$tJson) {
     $this.Title = $tJson.Title
     $this.Size = $tJson.Size
     $this.Id = $tJson.Id
     $this.State = $tJson.State
     $this.Description = $tJson.Description
     $this.Notes = $tJson.Notes
   }

   [int] AddNote([string]$note) {
     $utcRoundTripTimestamp = (Get-Date).ToUniversalTime().ToString("o")

     $this.Notes += "$utcRoundTripTimestamp $note"
     return $this.Notes.Count - 1
   }

   ShowNotes() {
     $this.ShowNotes(-1)
   }

   ShowNotes([int]$n) {
     if ($n -eq -1) {
       $n = $this.Notes.Count
     }
     for($i = $this.Notes.Count - 1; ($i -ge 0) -and ($n -gt 0); $i--, $n--)
     {
       $note = $this.Notes[$i]
       $iSpace = $note.IndexOf(' ') 
       $ts = $note.Substring(0, $iSpace)
       $noteText = $note.Substring($iSpace + 1)
       $localTimestamp = [DateTime]::Parse($ts)
       Write-Host $localTimestamp -NoNewline -ForegroundColor Gray
       Write-Host ' - ' -NoNewline -ForegroundColor DarkGray
       Write-Host $noteText
     }
   }
}

function Import-SingleTask {
  Param(
  [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
  $Path
  )

  if (-not (Test-Path -Path $Path -PathType Leaf)) {
    Write-Warning "Path not found, $Path"
    return
  }
  $tmp = ConvertFrom-Json -InputObject (Get-Content -Path $Path -Raw)
  New-Object -TypeName Task -ArgumentList $tmp
}

function Export-SingleTask {
  Param(
  [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
  [Task]$InputObject,
  [Parameter(Mandatory=$true)]
  $Path
  )
  $InputObject | ConvertTo-Json | Set-Content -Path $Path
}

$t1 = New-Object -TypeName Task -ArgumentList "Write a CodeProject Article on PS and C#"
$t1.AddNote('Just playing around')
#Start-Sleep 2
$t1.AddNote('a second note')
