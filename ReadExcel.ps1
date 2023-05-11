# Set log path
$LogPath = "C:\temp\demosetup\read_excel.log"

try {
    # Create an Excel.Application COM object
    $Excel = New-Object -ComObject Excel.Application

    # Set Excel visibility to False (you can set it to $true if you want to see the Excel application)
    $Excel.Visible = $false

    # Open the Excel file
    $FilePath = "C:\temp\demosheet5.xlsm"
    $Workbook = $Excel.Workbooks.Open($FilePath)

    # Log file open event
    "Opened file $FilePath at $(Get-Date)" | Out-File $LogPath -Append

    # Read the content from the first worksheet
    $Worksheet = $Workbook.Worksheets.Item(1)
    $Range = $Worksheet.UsedRange

    # Loop through the rows and columns and display the content in the PowerShell console
    for ($row = 1; $row -le $Range.Rows.Count; $row++) {
        for ($col = 1; $col -le $Range.Columns.Count; $col++) {
            $CellValue = $Worksheet.Cells.Item($row, $col).Value2
            Write-Host -NoNewline "$CellValue       "
        
            # Log cell value
            "Cell[$row, $col] value: $CellValue" | Out-File $LogPath -Append
        }
        Write-Host ""
    }
}
catch {
    "Error: $_" | Out-File $LogPath -Append
}
finally {
    # Close and release the Excel objects
    if ($Workbook) {
        $Workbook.Close($false)
    }
    if ($Excel) {
        $Excel.Quit()
    }

    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Worksheet) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Workbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel) | Out-Null

    # Log completion
    "Script completed at $(Get-Date)" | Out-File $LogPath -Append
}
