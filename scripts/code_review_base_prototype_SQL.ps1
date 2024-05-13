
$CurrentQuery = New-Object -TypeName 'System.Collections.ArrayList';

$global:sqlFileCount += 1

$global:lineCount = 1

# Walk through most common SQL problems manually:
ForEach ($row in $global:FileContent) {
    $global:currentRowString = $row.Trim().ToLower()

    $global:characterPosition = findString "select *" $global:currentRowString
    if($global:characterPosition -ge 0) {
        $global:characterPosition += 7
        sqlWarningFoundWithColumn "Please avoid using 'SELECT *', use column names instead!"
    }

    $global:characterPosition = findStringButNotTheOtherString "poldat" "poldat_view" $global:currentRowString
    if($global:characterPosition -ge 0) {
        $global:characterPosition += 6
        sqlWarningFoundWithColumn "When qyerying 'poldat', it is often recommended to use 'poldat_view' instead if possible. Keep in mind that performance problems may appear with 'poldat_view'."
    }

    #$poldatOnlyFound = findValueForField "wh_id" $global:currentRowString

    
    # Note down current row in a larger query to analyze it:
    $CurrentQuery.Add($global:currentRowString) > $null
    
    
    $global:lineCount += 1
}

# Now we will analyze the SQL query on a query level:
showTypeCheckHeader "Analyzing query.."
AnalyzeQuery $CurrentQuery $global:FileContent

