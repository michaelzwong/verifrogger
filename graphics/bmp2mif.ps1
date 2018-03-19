$files = Get-ChildItem -Filter "*.bmp";

ForEach ($file in $files) {
    Write-Output "### CONVERING $($file.BaseName).bmp ###";
    python bmp2mif.py $file.FullName;
}
