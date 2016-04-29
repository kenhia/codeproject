class Task {
  [string] $Title
  [ValidateSet("small", "medium", "large", "x-large", "unknown")]
  [string] $Size
  [guid] $Id
  [ValidateSet("proposed", "backlog", "active", "sideburner", "closed", "rejected")]
  [string] $State
  [string[]] $Description
  [string[]] $Notes


   # Constructor
   Task ([string] $t) {
     if ($t.StartsWith('{')) {
       $tmp = $t | ConvertFrom-Json
       $this.Title = $tmp.Title
       $this.Size = $tmp.Size
       $this.Id = $tmp.Id
       $this.State = $tmp.State
       $this.Description = $tmp.Description
       $this.Notes = $tmp.Notes
     } else {
       $this.Title = $t
       $this.Id = [guid]::NewGuid()
     }    
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

$t1 = New-Object -TypeName Task -ArgumentList "Write a CodeProject Article on PS and C#"
$t1.AddNote('Just playing around')
Start-Sleep 2
$t1.AddNote('a second note')
