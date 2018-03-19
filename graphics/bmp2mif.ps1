$files = Get-ChildItem -Filter "*.bmp";

ForEach ($file in $files) {
    Write-Output "`n   ### CONVERING $($file.BaseName).bmp ###";
    .\bmp2mif.exe $file.FullName;
    $mifName = $file.BaseName + ".mif";
    Move-Item "image.colour.mif" $mifName -Force;
}

Remove-Item "image.mono.mif";
