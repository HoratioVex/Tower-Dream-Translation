$rompath = "..\output.sfc"
$romfile = Get-Item $rompath

$infile = Get-Item "Font_Latin.bin"
$input = [System.IO.File]::ReadAllBytes($infile.FullName)

$filestream = $romfile.OpenWrite()
$filepos = 0x030B0A #Letter A
$filestream.Seek($filepos, [System.IO.SeekOrigin]::Begin)

foreach ($i in 0..(26*2+4))
{
	$filestream.Write($input,$i*16,16)
	$filestream.WriteByte(0xFF)
	$filestream.WriteByte(0xFF)
	
}
$filestream.Dispose()
write-host "Done"