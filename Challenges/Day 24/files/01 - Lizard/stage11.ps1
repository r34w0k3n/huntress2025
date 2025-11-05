Add-Type -AssemblyName System.Speech; Add-Type -AssemblyName System.Windows.Forms
$SpeechSynth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$SpeechSynth.SelectVoice('Microsoft Zira Desktop')
$lizard = Get-Date -Format tt
while ($true) {
    $SpeechSynth.Speak($lizard)
    [System.Windows.Forms.MessageBox]::Show($lizard, 'Alert', 'OK', 'Information')
}
$UniqueRebel = "TWpVeU9UWXlORGN3ZlE9PQ=="