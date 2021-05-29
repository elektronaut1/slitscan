param
(
    [string]$inputVideo = $(throw 'Specify input video'),
	[string]$orientation = 'horizontal'
)
# Get Start Time
$startTimeStamp = (Get-Date)


# Slistscan creation script by elektronaut1 2017, 2018
# requires ImageMagick and ffmpeg (which is included in the Imagemagick Windows binary Download)
# Use at your own risk
Write-Host Slitscan script v1.1 by Elektronaut.at

# get width and height of input video using ffprobe
Write-Host "Reading input video dimmensions (ffprobe)"
$ffprobeOutput = ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries "stream=height,width" $inputVideo

$wStr = $ffprobeOutput | Select-String "streams_stream_0_width=" 
$hStr = $ffprobeOutput | Select-String "streams_stream_0_height=" 
$w0 = $wStr.Line.split("=")
$h0 = $hStr.Line.split("=")

Write-Host Input video dimmensions are: $w0[1] x $h0[1]



if ($orientation -eq "horizontal") {
	#setting parameters
	$xsize = $w0[1]
	$ysize = 1
	$xpos = 0
	$ypos = $h0[1] / 2
}
elseif ($orientation -eq "vertical") {
	#setting parameters
	$xsize = 1
	$ysize = $h0[1]
	$xpos = $w0[1] / 2
	$ypos = 0
} else { $(throw 'Error') }


Write-Host Using default paramters crop=${xsize}:${ysize}:${xpos}:${ypos}

$tempOutputFile = "line"
$timeStamp = $(get-date -f yyyyMMdd_HHmmss)
#$tempDirName = $timeStamp
$tempDirName = [guid]::newguid()
$outputDir = (Get-Item $inputVideo).DirectoryName 
$inputVideoBasename = (Get-Item $inputVideo).BaseName
$outputTemp =  $outputDir + "\temp_${tempDirName}"

#Createing temporary Directory
mkdir $outputTemp > $null

#cropping input video frames
Write-Host "Processing input video (ffmpeg)"
#ffmpeg -i $inputVideo -filter "format=rgb24,crop=${xsize}:${ysize}:${xpos}:${ypos}"  $outputTemp\$tempOutputFile%06d.png
ffmpeg -i $inputVideo -filter "format=rgb24,crop=${xsize}:${ysize}:${xpos}:${ypos}" -loglevel panic $outputTemp\$tempOutputFile%08d.png

#assembling frame slices to output image
Write-Host "Creating output image (ImageMagick)"

if ($orientation -eq "horizontal") {
	montage $outputTemp\${tempOutputFile}*.png -geometry +0+0  -tile 1x  "$outputDir\Slitscan_${timeStamp}_${inputVideoBasename}.png"	
	# Flip Image due to windows  *.png sort order being in the wrong direction
	Write-Host "Flipping and rotating image (ImageMagick)"
	convert  "$outputDir\Slitscan_${timeStamp}_${inputVideoBasename}.png" -flip -rotate 270 "$outputDir\Slitscan_${timeStamp}_${inputVideoBasename}.png" # "$outputDir\SlitscanM_${timeStamp}_${inputVideoBasename}.png"
}
elseif ($orientation -eq "vertical") {
	
	montage $outputTemp\${tempOutputFile}*.png -geometry +0+0  -tile x1  "$outputDir\Slitscan_${timeStamp}_${inputVideoBasename}.png"
#	Write-Host "Flopping image (ImageMagick)"
#	convert  "$outputDir\Slitscan_${timeStamp}_${inputVideoBasename}.png" -flop   "$outputDir\Slitscan_${timeStamp}_${inputVideoBasename}.png"
} else { $(throw 'Error') }

Write-Host Removing temporary files and temporaty folder 
#del $outputTemp -Force -Recurse

# Get End Time
$endTimeStamp = (Get-Date)



Write-Host "Slitscan image creation completed in" $(($endTimeStamp-$startTimeStamp).totalseconds) seconds
Write-Host Opening output file with system default viewer

Start-Sleep -s 1

Invoke-Item "$outputDir\Slitscan_${timeStamp}_${inputVideoBasename}.png"

# Write-Host output: $outputDir
# Close PowerShell after 5 seconds
Start-Sleep -s 5
#Stop-Process -Id $PID