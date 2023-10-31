# Decode a chunk of compressed data from SNES game Tower Dream
# Using Haruhiko Okumura's 1989 public domain implementation of LZSS
# Control bytes: LSB describes *first* symbol
# Reference words: 12 bits for buffer index, 4 bits for length
# Data Header (little endian): 2 bytes raw size, 2 bytes compressed size 

$global:buffer_size = 4096
 # range of 12 bits
$global:threshold = 2 
 # encode as reference only if longer than this, so 4 bits can encode (0+3) to (15+3) length

# little endian
function Fuse-Bytes ($lowbyte, $highbyte) {
	return (($highbyte -shl 8) -bor $lowbyte)  
}

#is next symbol a BYTE literal or a WORD reference
function isLiteral ([byte]$byte,$bitpos) { 
	return (($byte -shr $bitpos) -band 1)
}

# order of bits in reference word:
# IIIIIIII IIIILLLL
# 76543210 BA983210

function getIndex ([int]$i, [int]$j) {
	$r= ($j -shr 4) -shl 8
	$result = $r -bor $i
	return $result 
}

function getLength ($i, $j) {
	$result =  ($j -band 0x0F)
	$result += $global:threshold
	return $result
}
# *** Begin***
# Load file
$rompath = "..\output.sfc"
if ($args.count -eq 0)
	{write-host "Error: Hexadecimal file offset expected"
	return}

$fileaddress = [Int32]("0x"+$args[0])
$romfile = Get-Item $rompath
$instream = $romfile.OpenRead()
$instream.Seek($fileaddress, [System.IO.SeekOrigin]::Begin)

# Load Header
$lo=$instream.ReadByte()
$hi=$instream.ReadByte()
$raw_length=Fuse-Bytes $lo $hi
write-host "Uncompressed size: $raw_length"

$lo=$instream.ReadByte()
$hi=$instream.ReadByte()
$code_length=Fuse-Bytes $lo $hi
write-host "Compressed size: $code_length"

if ($raw_length -lt 1 -or $code_length -lt 1)
	{write-host "Error: Unexpected end of file"
	return}

#Load Data
[byte[]]$code_data = @(0) * $code_length	
$instream.Read($code_data, 0, $code_length)
$instream.Dispose()

# *** Buffer initialization ***
[byte[]]$buffer = @(0) * $global:buffer_size
for ($i=4060; $i -lt 4078 ; $i++) {
	$buffer[$i]=0x20 # ASCII Space, blindly copying Okumura. He wants to clear with a byte that occurs often, but he's considering English text
}
$buffer_pos = 4078

[byte[]]$raw_data = @(0) * $raw_length
$raw_pos = 0
$code_pos = 0

#*** Process data ***
while ($code_pos -lt $code_length) {
	[byte]$Ctrl=$code_data[$code_pos]
	$code_pos++
	if ($code_pos -gt $code_length) { #end of data
		break
	}
	for ($bitnum = 0; $bitnum -lt 8; $bitnum++) {
		if (isLiteral $Ctrl $bitnum) {
			$write = $code_data[$code_pos]
			$raw_data[$raw_pos]=$write
			$buffer[$buffer_pos]=$write
			$raw_pos++
			$code_pos++
			if ($code_pos -gt $code_length) {
				break
			}
			$buffer_pos++
			if ($buffer_pos -eq $global:buffer_size) { #loop buffer
				$buffer_pos = 0
			}
		} else {
			$lo=$code_data[$code_pos]
			$code_pos++
			$hi=$code_data[$code_pos]
			$code_pos++
			if ($code_pos -gt $code_length) {
				break
			}
			$ref_index=getIndex $lo $hi
			$ref_length=getLength $lo $hi
			for ($i=0; $i -le $ref_length; $i++) {
				$write=$buffer[($ref_index+$i) -band ($global:buffer_size-1)] #loop buffer
				$raw_data[$raw_pos]=$write
				$buffer[$buffer_pos]=$write
				$raw_pos++
				$buffer_pos++
				if ($buffer_pos -eq $global:buffer_size) {
					$buffer_pos = 0
				}
			}
		}
	}
}

#***Write result to file***
#Data_001ab456 (418).til
$outname = $args[0].PadLeft(8,"0")
$outfile=$pwd.Path+"\Data_"+$outname+" ("+$code_length+").til"
[System.IO.File]::WriteAllBytes($outfile, $raw_data)
write-host "Wrote $raw_pos bytes to $outfile"






