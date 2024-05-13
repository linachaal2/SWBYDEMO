
# ========================================================================
#           Starware Code Review Files Quick Check Script                |
# ========================================================================


# Base variables:
$ScriptName = "Starware BY WMS Code Review"
$SettingsFile = "Code-Review.json"

$ErrorMessageNoConfiguration= "No configuration file found, exiting.."
$ErrorMessageNoSearchPath= "Search path does not exist. Exiting.."

$global:filecount = 0
$global:ignoredFileCount = 0
$global:csvFileCount = 0
$global:csvErrorCount = 0
$global:csvWarningCount = 0
$global:sqlFileCount = 0
$global:fileErrorCount = 0
$global:sqlErrorCount = 0
$global:sqlWarningCount = 0
$global:xmlFileCount = 0
$global:xmlErrorCount = 0
$global:jsonFileCount = 0
$global:jsonErrorCount = 0
$global:pofFileCount = 0
$global:pofWarningCount = 0
$global:pofErrorCount = 0
$global:currentFileErrorCount = 0
$global:currentFileWarningCount = 0
$global:characterPosition = 0
$global:currentFileIsEmptyOrIgnored = 0



$TableNamesFound = New-Object -TypeName 'System.Collections.ArrayList';

# Set to current path for running inside ISE:
cd $PSScriptRoot

# Clear screen:
cls

Write-Output " Search path: $($Args[0])" 

# Check for existence configuration file:
$ScriptSettingsFile = join-path $PSScriptRoot $SettingsFile
if (-not(Test-Path -Path $ScriptSettingsFile -PathType Leaf)) {
    Write-Output ""
    Write-Output " $($ErrorMessageNoConfiguration)" | errorLineColour
    Write-Output ""
    exit
}
else {
    $SettingsObject = Get-Content -Raw $ScriptSettingsFile | ConvertFrom-Json
}

function scriptLineColour {process {Write-Host $_ -ForegroundColor $SettingsObject.SW_BYWMS_CODE_REVIEW.SCRIPT_SETTINGS.COLOR_SETTINGS.SCRIPT_LINES}}
function headerLineColour {process {Write-Host $_ -ForegroundColor $SettingsObject.SW_BYWMS_CODE_REVIEW.SCRIPT_SETTINGS.COLOR_SETTINGS.HEADER_LINES}}
function codeLineColour {process {Write-Host $_ -ForegroundColor $SettingsObject.SW_BYWMS_CODE_REVIEW.SCRIPT_SETTINGS.COLOR_SETTINGS.CODE_LINES}}
function warningLineColour  {process {Write-Host $_ -ForegroundColor $SettingsObject.SW_BYWMS_CODE_REVIEW.SCRIPT_SETTINGS.COLOR_SETTINGS.WARNING_LINES}}
function errorLineColour  {process {Write-Host $_ -ForegroundColor $SettingsObject.SW_BYWMS_CODE_REVIEW.SCRIPT_SETTINGS.COLOR_SETTINGS.ERROR_LINES}}
function checkTypeColour  {process {Write-Host $_ -ForegroundColor $SettingsObject.SW_BYWMS_CODE_REVIEW.SCRIPT_SETTINGS.COLOR_SETTINGS.CHECKTTYPE_LINES}}
function informationTypeColour  {process {Write-Host $_ -ForegroundColor $SettingsObject.SW_BYWMS_CODE_REVIEW.SCRIPT_SETTINGS.COLOR_SETTINGS.INFORMATION_LINES}}

function showError([string]$errorToShow) {
    Write-Output "   - $errorToShow " | errorLineColour
}

function showErrorWithColumn([int]$global:lineCount, [int]$columnCount, [string]$global:currentRowString,[string]$errorToShow) {
    Write-Output "   - LN $($global:lineCount): $($errorToShow)" | warningLineColour
    Write-Output "        [ $($global:currentRowString) ]" | codeLineColour
    $spaces = ' ' * ($columnCount) 
    Write-Output "          $($spaces)^ "
}
function showErrorWithRow([int]$global:lineCount, [string]$global:currentRowString,[string]$errorToShow) {
    Write-Output "   - LN $($global:lineCount): $($errorToShow)" | warningLineColour
}

function showWarning([string]$warningToShow) {
    Write-Output "   - $warningToShow " | warningLineColour
}

function showWarningWithRow([int]$global:lineCount,[string]$warningToShow) {
    Write-Output "   - LN $($global:lineCount): $($warningToShow)" | warningLineColour
}

function showWarningWithColumn([int]$global:lineCount, [int]$columnCount, [string]$global:currentRowString,[string]$warningToShow) {
    Write-Output "   - LN $($global:lineCount): $($warningToShow)" | warningLineColour
    Write-Output "        [ $($global:currentRowString) ]" | codeLineColour
    $spaces = ' ' * ($columnCount) 
    Write-Output "          $($spaces)^ "
}

function findRowColumnPosition([object]$global:FileContent,[string]$stringToSearchFor) {
    $foundLineNumber = 0
    $foundColumnPosition = 0
    ForEach ($row in $global:FileContent) {
        $global:currentRowString = $row.Trim().ToLower()
        $foundColumnPosition = findString $stringToSearchFor $global:currentRowString
        if($foundColumnPosition -ge 0) {
            $global:lineCount = $foundLineNumber + 1
            $global:characterPosition = $foundColumnPosition
            $global:currentRowString = $row
            return
        }
        $foundLineNumber += 1
    }
}

function fileWarningFound([string]$warningFound) {
    showWarning $warningFound
    $global:fileWarningCount +=1
    $global:currentFileWarningCount +=1
}

function fileErrorFound([string]$errorFound) {
    showError $errorFound
    $global:fileErrorCount +=1
    $global:currentFileErrorCount +=1
}


function csvErrorFound([string]$errorFound) {
    showError $errorFound 
    $global:csvErrorCount +=1
    $global:currentFileErrorCount +=1
}

function csvErrorFoundWithRow([string]$errorFound) {
    showErrorWithRow $global:lineCount $global:currentRowString $errorFound 
    $global:csvErrorCount +=1
    $global:currentFileErrorCount +=1
}
function csvWarningFoundWithRow([string]$errorFound) {
    showWarningWithRow $global:lineCount $errorFound
    $global:csvErrorCount +=1
    $global:currentFileErrorCount +=1
}

function csvErrorFoundWithColumn([string]$errorFound) {
    showErrorWithColumn $global:lineCount $global:characterPosition $global:currentRowString $errorFound
    $global:csvErrorCount +=1
    $global:currentFileErrorCount +=1
}
function csvWarningFound([string]$errorFound) {
    showWarning $errorFound
    $global:csvWarningCount +=1
    $global:currentFileWarningCount +=1
}
function csvWarningFoundWithColumn([string]$errorFound) {
    showWarningWithColumn $global:lineCount $global:characterPosition $global:currentRowString $errorFound
    $global:csvWarningCount +=1
    $global:currentFileWarningCount +=1
}

function sqlErrorFound([string]$errorFound) {
    showError $errorFound
    $global:sqlErrorCount +=1
    $global:currentFileErrorCount +=1
}
function sqlErrorFoundWithColumn([string]$errorFound) {
    showErrorWithColumn $global:lineCount $global:characterPosition $global:currentRowString $errorFound
    $global:sqlErrorCount +=1
    $global:currentFileErrorCount +=1
}
function sqlWarningFound([string]$errorFound) {
    showWarning $errorFound
    $global:sqlWarningCount +=1
    $global:currentFileWarningCount +=1
}
function sqlWarningFoundWithColumn([string]$errorFound) {
    showWarningWithColumn $global:lineCount $global:characterPosition $global:currentRowString $errorFound
    $global:sqlWarningCount +=1
    $global:currentFileWarningCount +=1
}

function xmlErrorFound([string]$errorFound) {
    showError $errorFound
    $global:xmlErrorCount +=1
    $global:currentFileErrorCount +=1
}

function jsonErrorFound([string]$errorFound) {
    showError $errorFound
    $global:jsonErrorCount +=1
    $global:currentFileErrorCount +=1
}
function pofWarningFound([string]$warningFound) {
    showWarning $warningFound
    $global:pofWarningCount +=1
    $global:currentFileWarningCount +=1
}
function pofWarningFoundWithColumn([string]$warningFound) {
    showWarningWithColumn $global:lineCount $global:characterPosition $global:currentRowString $warningFound
    $global:pofWarningCount +=1
    $global:currentFileWarningCount +=1
}

function pofErrorFound([string]$errorFound) {
    showError $errorFound
    $global:pofErrorCount +=1
    $global:currentFileErrorCount +=1
} 
function pofErrorFoundWithColumn([string]$errorFound) {
    showErrorWithColumn $global:lineCount $global:characterPosition $global:currentRowString $errorFound
    $global:pofErrorCount +=1
    $global:currentFileErrorCount +=1
}

function showHeader() {
    Write-Output "" 
    Write-Output " ========================================================================" | headerLineColour
    Write-Output " $($ScriptName) - v$($SettingsObject.SW_BYWMS_CODE_REVIEW.SCRIPT_SETTINGS.VERSION_ID)" | headerLineColour
    Write-Output " ========================================================================" | headerLineColour
    Write-Output ""
    Write-Output "" 
    #Write-Output " Header line " | headerLineColour
    #Write-Output " Script line " | scriptLineColour
    #Write-Output " Code line " | codeLineColour
    #Write-Output " Fake Warning! " | warningLineColour
    #Write-Output " Fake Error!! " | errorLineColour
    #Write-Output ""
    #Write-Output ""
}

function showTypeCheckHeader([string]$typeCheckHeader) {
    Write-Output " "
    Write-Output "   $($typeCheckHeader)" | checkTypeColour
}

function showEndAnalysis() {
    Write-Output " "
    Write-Output " ========================================================================" | scriptLineColour
    Write-Output "  ANALYSIS: " | scriptLineColour
    Write-Output " ========================================================================" | scriptLineColour
    Write-Output " "
    Write-Output "  Files checked: $($global:fileCount)" | scriptLineColour
   
    if ($global:ignoredFileCount -gt 0) { Write-Output "   - Ignored files: $($global:ignoredFileCount)" | errorLineColour }
    else {                              Write-Output "   - Ignored files: 0 " | scriptLineColour }

    
    if ($global:fileErrorCount -gt 0) { Write-Output "   - Errors found: $($global:fileErrorCount)" | errorLineColour }
    else {                              Write-Output "   - Errors found: 0 " | scriptLineColour }

    Write-Output " "
    Write-Output "  CSV Files checked: $($global:csvFileCount)" | scriptLineColour
    if ($global:csvFileCount -gt 0) { Write-Output "   - Warnings found: $($global:csvFileCount)" | warningLineColour }
    else {                              Write-Output "   - Warnings found: 0 " | scriptLineColour }
    if ($global:csvFileCount -gt 0) { Write-Output "   - Errors found: $($global:csvFileCount)" | errorLineColour }
    else {                              Write-Output "   - Errors found: 0 " | scriptLineColour }
    
    Write-Output " "
    Write-Output "  SQL Files checked: $($global:sqlFileCount)" | scriptLineColour
    if ($global:sqlWarningCount -gt 0) { Write-Output "   - Warnings found: $($global:sqlWarningCount)" | warningLineColour }
    else {                              Write-Output "   - Warnings found: 0 " | scriptLineColour }
    if ($global:sqlErrorCount -gt 0) { Write-Output "   - Errors found: $($global:sqlErrorCount)" | errorLineColour }
    else {                              Write-Output "   - Errors found: 0 " | scriptLineColour }
    
    Write-Output " "
    Write-Output "  XML Files checked: $($global:xmlFileCount)" | scriptLineColour
    if ($global:xmlErrorCount -gt 0) { Write-Output "   - Errors found: $($global:xmlErrorCount)" | errorLineColour }
    else {                             Write-Output "   - Errors found: 0 " | scriptLineColour }
    
    Write-Output " "
    Write-Output "  JSON Files checked: $($global:jsonFileCount)" | scriptLineColour
    if ($global:jsonErrorCount -gt 0) { Write-Output "   - Errors found: $($global:jsonErrorCount)" | errorLineColour }
    else {                             Write-Output "   - Errors found: 0 " | scriptLineColour }
    
    Write-Output " "
    Write-Output "  POF Files checked: $($global:pofFileCount)" | scriptLineColour
    if ($global:pofWarningCount -gt 0) { Write-Output "   - Warnings found: $($global:pofWarningCount)" | warningLineColour }
    else {                              Write-Output "   - Warnings found: 0 " | scriptLineColour }
    if ($global:pofErrorCount -gt 0) { Write-Output "   - Errors found: $($global:pofErrorCount)" | errorLineColour }
    else {                              Write-Output "   - Errors found: 0 " | scriptLineColour }
    
    Write-Output " "
    Write-Output " ========================================================================" | scriptLineColour
    Write-Output " "
    Write-Output " "
} 

function AnalyzeQuery([System.Collections.ArrayList]$Query) {
    
    $CurrentTableNamesFound = New-Object -TypeName 'System.Collections.ArrayList';
    $CurrentTableNamesInJoinesFound = New-Object -TypeName 'System.Collections.ArrayList';
    $AlternateTableNamesLookup = New-Object -TypeName 'System.Collections.ArrayList';

    $FormattedQuery = New-Object -TypeName 'System.Collections.ArrayList';

    # Since the queries are hard to check when there are line breaks and strange layout differences,
    # it is better to first format the query into a specific format.
    ForEach ($queryRow in $Query) {

        if($queryRow.Contains("with ") -and $queryRow.Contains("as (")) {
            $withAsStart = $queryRow.IndexOf("with ")
            $withAsEnd = $queryRow.IndexOf("as (")+3
            if (($withAsEnd - $withAsStart) -gt 30) {}
            else {
                $StringToReplace = $queryRow.Substring($withAsStart,$withAsEnd)
                $queryRow = $queryRow.Replace($StringToReplace,"")
            } 
        #Still need to remove the extra ) from the with
        }
        
        $queryRow = $queryRow.Replace(" select ","`nselect ")
        $queryRow = $queryRow.Replace(" select ","`nselect ")
        $queryRow = $queryRow.Replace(" from ","`nfrom ")
        $queryRow = $queryRow.Replace(" inner join ","`ninner join ")
        $queryRow = $queryRow.Replace(" left join ","`nleft join ")
        $queryRow = $queryRow.Replace(" right join ","`nright join ")
        $queryRow = $queryRow.Replace(" where ","`nwhere ")
        $queryRow = $queryRow.Replace(" group by ","`ngroup by ")
        $queryRow = $queryRow.Replace(" order by ","`norder by ")
        $queryRow = $queryRow.Trim()

        if($queryRow -eq "") {}
        else {
           $FormattedQuery.Add(" $($queryRow) ") > $null
        }
    } 

    # Check code:
    $validateShipmentWh_idExistence = 0
    $validateWh_idExistence = 0
    $currentlySelecting = 1
    $currentlyJoining = 0
    $currentlyRestricting = 0

    $currentSelectString = ""
    $currentJoinString = ""
    $currentWhereString = ""

    $fromNonAnsiJoinsFound = 0

    $tempFileContent = $($FormattedQuery -join [Environment]::NewLine)

    $JoinsFound = New-Object -TypeName 'System.Collections.ArrayList';
    
    ForEach ($queryRow in $FormattedQuery) {

        $querylines = ($queryRow -split "\r?\n|\r") 

        foreach($line in $querylines) {
            $row = $line.Trim().ToLower()

            if($currentlySelecting -eq 1) {
                if ($row -like "*from *") {}
                else {$currentSelectString = $currentSelectString + " " + $row}
            }
            if ($currentlyJoining -eq 1) {
                if ($row -like "*join *") {}
                else {$currentJoinString = $currentJoinString + " " + $row}
            }
            if($currentlyRestricting -eq 1) {
                $currentWhereString = $currentWhereString + " " + $row
            }


            if ($SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.SQL.LEFT_JOIN_USAGE_WARNING -eq 1) {
                $findLeftJoin = findString "left join" $line 
                if ($findLeftJoin  -ge 0) {
                    findRowColumnPosition $global:FileContent "left join"
                    sqlWarningFoundWithColumn("Is this left join needed? Can it maybe be changed into an inner join?")
                }
            }

            if ($row -like "* @wh_id*" -Or $row -like "*wh_id *") {
                $validateWh_idExistence = 1
            }
    
            if ($row -like "*from shipment*" -Or $row -like "*join shipment*") {
                if ($row -like "*from shipment_*" -Or $row -like "*join shipment_*") {} 
                else {
                    $validateShipmentWh_idExistence = 1
                } 
            }

            if ($row -like "*from *") {
                $currentlySelecting = 0

                $currentSelectString = $currentSelectString.TrimStart()

                $fromPart = $row

                if($row.Contains(",")){   
                    if($row.Contains("join ")){   
                        $fromPart = $row.Substring(0,$row.IndexOf("join "))
                    } 
                    if($row.Contains("where ")){   
                        $fromPart = $row.Substring(0,$row.IndexOf("where "))
                    }
                    if($row.Contains("select ")){   
                        $fromPart = $row.Substring(0,$row.IndexOf("select "))
                    }
                    if($fromPart.Contains(",")){   
                        $fromNonAnsiJoinsFound = 1
                    }
                }

                if($currentSelectString.Length -gt 6) {
                    $currentSelectString = $currentSelectString.Substring(7).Replace(" distinct "," ")
                }

                $indexOfFrom = $row.IndexOf("from ")
                if ($indexOfFrom -Gt 0) {
                    $indexOfFrom = $indexOfFrom - 1 
                }
                $smallerString = $row.Substring($indexOfFrom) 

                $nextSpace = $smallerString.IndexOf(" ")
                if ($nextSpace -eq -1) {
                    $nextSpace = 4
                }
                $tableString = $smallerString.Replace("from "," ")
                if ($tableString.StartsWith(" ")) {
                    $tableString = $tableString.TrimStart()
                    $nextSpace = $tableString.IndexOf(" ")
                    if ($nextSpace -eq -1) {
                        $nextSpace = $tableString.Length
                    }
                    $tableName = $tableString.substring(0,$nextSpace)

                    if($CurrentTableNamesFound.Contains($tableName)) {}
                    else {
                        $CurrentTableNamesFound.add($tableName) > $null 
                    }
                    if($TableNamesFound.Contains($tableName)) {}
                    else {
                        $TableNamesFound.add($tableName) > $null
                    }
                    
                    $alternateNameString = $tableString.substring($nextSpace)
                    $alternateNameString = $alternateNameString.Replace("as ","")
                    $alternateNameString = $alternateNameString.TrimStart()

                    if(    $AlternateTableNamesLookup.Contains("$($alternateNameString)-$($tableName)")) {}
                    else { $AlternateTableNamesLookup.add("$($alternateNameString)-$($tableName)") > $null }

                    if($alternateNameString -eq ""){
                        if($CurrentTableNamesInJoinesFound.Contains($tableName)) {}
                        else {
                            $CurrentTableNamesInJoinesFound.add($tableName) > $null 
                        }
                    }
                    else {
                        $nextSpace = $alternateNameString.IndexOf(" ")
                        if ($nextSpace -eq -1) {
                            if($CurrentTableNamesInJoinesFound.Contains($alternateNameString)) {}
                            else {
                                $CurrentTableNamesInJoinesFound.add($alternateNameString) > $null 
                            }
                        }
                        else {
                            $alternateNameString = $tableString.substring(0,$nextSpace)
                            if($CurrentTableNamesInJoinesFound.Contains($alternateNameString)) {}
                            else {
                                $CurrentTableNamesInJoinesFound.add($alternateNameString) > $null 
                            }
                        }
                        $tempFileContent = $tempFileContent.Replace($alternateNameString + ".",$tableName + ".")
                    }
                }
            }

            if ($row -like "*join *") {
                if($currentlyJoining -eq 1) {
                    $JoinsFound.Add($currentJoinString ) > $null
                }

                $currentlyJoining = 1
                $currentJoinString = $row

                $indexOfFrom = $row.IndexOf("join ")
                if ($indexOfFrom -Gt 0) {
                    $indexOfFrom = $indexOfFrom - 1 
                }
                $smallerString = $row.Substring($indexOfFrom) 

                $nextSpace = $smallerString.IndexOf(" ")
                if ($nextSpace -eq -1) {
                    $nextSpace = 4
                }
                $tableString = $smallerString.Replace("join "," ")
                if ($tableString.StartsWith(" ")) {
                    $tableString = $tableString.TrimStart()
                    $nextSpace = $tableString.IndexOf(" ")
                    if ($nextSpace -eq -1) {
                        $nextSpace = $tableString.Length
                    }
                    $tableName = $tableString.substring(0,$nextSpace)

                    if($CurrentTableNamesFound.Contains($tableName)) {}
                    else {
                        $CurrentTableNamesFound.add($tableName) > $null 
                    }
                    if($TableNamesFound.Contains($tableName)) {}
                    else {
                        $TableNamesFound.add($tableName) > $null
                    }

                    if ($alternateNameString.Contains(" on ")) {
                        $nextSpace = $alternateNameString.IndexOf(" ")
                    }
                    
                    $alternateNameString = $tableString.substring($nextSpace)
                    $alternateNameString = $alternateNameString.TrimStart()


                    if($alternateNameString -eq ""){
                        if($CurrentTableNamesInJoinesFound.Contains($alternateNameString)) {}
                        else {
                            $CurrentTableNamesInJoinesFound.add($alternateNameString) > $null 
                        }
                    }
                    else {
                        if($alternateNameString.TrimStart().StartsWith("on ")){ }
                        else {
                            if($tableString.Contains(" on ")){
                                $nextSpace = $alternateNameString.IndexOf(" ")
                                $alternateNameString = $alternateNameString.substring(0,$nextSpace)
                            }
                            if($alternateNameString.EndsWith(" on")){
                                $alternateNameString = $alternateNameString.Replace(" on","").Trim()
                            }
                            if(    $AlternateTableNamesLookup.Contains("$($alternateNameString)-$($tableName)")) {}
                            else { $AlternateTableNamesLookup.add("$($alternateNameString)-$($tableName)") > $null }
                            
                            $nextSpace = $alternateNameString.IndexOf(" ")
                            if ($nextSpace -eq -1) {
                                if($CurrentTableNamesInJoinesFound.Contains($alternateNameString)) {}
                                else {
                                    $CurrentTableNamesInJoinesFound.add($alternateNameString) > $null 
                                }
                            }
                            else {
                                $alternateNameString = $tableString.substring(0,$nextSpace)
                                if($CurrentTableNamesInJoinesFound.Contains($alternateNameString)) {}
                                else {
                                    $CurrentTableNamesInJoinesFound.add($alternateNameString) > $null 
                                }
                            }
                            $tempFileContent = $tempFileContent.Replace($alternateNameString + ".",$tableName + ".")
                        }
                    }
                }
            }
            
          
            if ($row -like "*where *" -or $row -like "*union *") {
                if ($currentlyJoining -eq 1) {
                    $onlyJoin = $currentJoinString.Substring(0,$currentJoinString.IndexOf("where "))
                    $JoinsFound.Add($onlyJoin) > $null
                }
                $currentlyJoining = 0
                $currentlyRestricting = 1
                $currentWhereString = $currentWhereString + " " + $row
                $currentWhereString = $currentWhereString.Replace("where ","")
            }
            
            $global:lineCount = $global:lineCount + 1
        }
    }
    #End of query lines


    #Analyze whole query:
    if($fromNonAnsiJoinsFound -gt 0) {
        if ($SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.SQL.ANSI_JOIN_WARNING -eq 1) {
            sqlWarningFound "Please avoid using Non-Ansi joins in the query (example: from table1, table2)! "
        }
    }

    if($SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.SQL.UNUSED_TABLE_USAGE_WARNING -eq 1 -or $SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.SQL.UNUSED_TABLE_USAGE_ERROR -eq 1) {
        $UnusedTables = 1
    }    

    if ($CurrentTableNamesInJoinesFound.Count -gt 1 -and $UnusedTables -eq 1) {
        ForEach ($table in $CurrentTableNamesInJoinesFound) {

            $countJoins = 0
            ForEach ($join in $JoinsFound) {
                if($join.Contains($table + ".")) {
                    $countJoins = $countJoins + 1
                }
            }
            if($countJoins -eq 1) {
                if ($currentSelectString.Contains($table + ".")) {}
                else {
                    if ($currentWhereString.Contains($table + ".")) {}
                    else {
                        $global:lineCounter = 0
                        $rowNumber = 0
                        $columnCount = 0
                        $rowData = ""

                        ForEach ($row in $tempFileContent) {
                            $string = $row.Trim().ToLower()
                            if($string.Contains($table)) {
                                $rowNumber = $global:lineCounter
                                if($string.Contains("from " + $table)) {
                                    $columnCount = $string.IndexOf(("from " + $table))
                                    $rowData = $string 
                                }
                                elseif($string.Contains("join " + $table)) {
                                    $columnCount = $string.IndexOf(("join " + $table))
                                    $rowData = $string 
                                }
                            }
                            $global:lineCounter = $global:lineCounter + 1
                        }

                        # Find table name:
                        $ActualTableName = $table

                        foreach ($tableName in $AlternateTableNamesLookup) {
                            if($tableName.StartsWith($table+"-")) {
                                $ActualTableName = $tableName.Replace("$($table)-","")
                            }
                        }
                        if ($ActualTableName -eq "invsub") {   }

                        # Check if other content contains the field, sometimes there are multiple queries and it
                        # becomes too complex:
                        # inner join invsub isub on i.subnum = isub.subnum

                        # Find line number of join

                        $global:lineCount = 1
                        $showUnusedTableCode = ""

                        ForEach ($fileRow in $global:FileContent) {
                            $fileRow = $fileRow.ToLower().Trim()
                            if($fileRow.Contains("join $($ActualTableName)")) {
                                $columnnumber = $fileRow.IndexOf("join $($ActualTableName)")+5
                                $SpaceString = ' ' * $columnnumber 
                                $showUnusedTableCode = $fileRow  
                                break
                            }
                            $global:lineCount+=1
                        }

                        # Find other mentions that are not close to the join
                        $joinsLineNumbersWithTable = New-Object -TypeName 'System.Collections.ArrayList';
                        $mentionsLineNumbersWithTable = New-Object -TypeName 'System.Collections.ArrayList';

                        $lineNumberTableMentions = 1
                        $currentlyJoining = 0

                        # Find join lines:
                        ForEach ($fileRow in $global:FileContent) {
                            $fileRow = $fileRow.ToLower().Trim()
                            if($fileRow.Contains("join $($ActualTableName)")) {
                                $joinsLineNumbersWithTable.Add($lineNumberTableMentions) > $null
                                $currentlyJoining = 1
                            }
                            elseif($currentlyJoining -eq 1) {
                                if($fileRow.Contains("join ")) { $currentlyJoining = 0 }
                                if($fileRow.Contains("select ")) { $currentlyJoining = 0 }
                                if($fileRow.Contains("where ")) { $currentlyJoining = 0 }
                                if($fileRow.Contains("group ")) { $currentlyJoining = 0 }
                                if($fileRow.Contains("having ")) { $currentlyJoining = 0 }
                                if($fileRow.Contains("]")) { $currentlyJoining = 0 }
                                if($currentlyJoining -eq 1) {
                                    $joinsLineNumbersWithTable.Add($lineNumberTableMentions) > $null
                                }
                            }
                            $lineNumberTableMentions+=1
                        }

                        # Find mentions:
                        $lineNumberTableMentions = 1
                        ForEach ($fileRow in $global:FileContent) {
                            $fileRow = $fileRow.ToLower().Trim()
                            if($fileRow.Contains("$($table).")) {
                                $mentionsLineNumbersWithTable.Add($lineNumberTableMentions) > $null
                            }
                            $lineNumberTableMentions+=1
                        }

                        $tableUsed = 0
                        ForEach ($mention in $mentionsLineNumbersWithTable) {
                            if($joinsLineNumbersWithTable.Contains($mention)) {}
                            else {
                                $tableUsed = 1
                                break
                            }
                        }

                        if($tableUsed -eq 0) {
                            if ($SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.SQL.UNUSED_TABLE_USAGE_ERROR -eq 1) {
                                findRowColumnPosition $global:FileContent $ActualTableName
                                sqlWarningFoundWithColumn "Possibly unused table: $($ActualTableName)!"
                            }
                            elseif ($SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.SQL.UNUSED_TABLE_USAGE_WARNING -eq 1) {
                                findRowColumnPosition $global:FileContent $ActualTableName
                                sqlWarningFoundWithColumn "Possibly unused table: $($ActualTableName)!"
                            }
                        }
                    }
                }
            }
        }
    }

    if($validateShipmentWh_idExistence -eq 1) {
        if ($global:FileContent -like "*nvl(@wh_id, @@wh_id)*") {}
        else {
            findRowColumnPosition $global:FileContent "@wh_id"
            $global:characterPosition += 6
            sqlWarningFoundWithColumn "When using the shipment table, please add 'nvl(@wh_id, @@wh_id)' to the query."
        }
    }
    elseif($validateWh_idExistence -eq 1) {
        if ($global:FileContent -like "*nvl(@wh_id, @@wh_id)*") {}
        elseif ($global:FileContent -like "*@wh_id*") {
            findRowColumnPosition $global:FileContent "@wh_id"
            $global:characterPosition += 6
            sqlWarningFoundWithColumn "When using the warehouse ID, please replace it with: 'nvl(@wh_id, @@wh_id)'."
        }
    }

          
    foreach ($join in $JoinsFound) {
        $tableJoinedStart = $join.Substring($join.IndexOf("join ") + 5)
        $tableJoined = $tableJoinedStart.Substring(0,$tableJoinedStart.IndexOf(" "))
        $UsedTableName = $tableJoined

        foreach ($tableName in $AlternateTableNamesLookup) {
            if($tableName.EndsWith("-" + $tableJoined)) {
                $UsedTableName = $tableName.Replace("-$($tableJoined)","")
            }
        }

        $joinsRequired = $SettingsObject.SW_BYWMS_CODE_REVIEW.JOINS_NEEDED."table-$($tableJoined)"

        if($joinsRequired) {
            $fieldsToCheckFor = $joinsRequired.Split(",")
            foreach ($field in $fieldsToCheckFor) {
                $checkName = $UsedTableName + "." + $field
                if($join.Contains($checkName)) {}
                else {
                    $global:lineCount = 1
                    ForEach ($fileRow in $global:FileContent) {
                        $fileRow = $fileRow.ToLower().Trim()
                        if($fileRow.Contains("join $($tableJoined)")) {
                            $columnnumber = $fileRow.IndexOf("join $($tableJoined)") + 5
                            $SpaceString = ' ' * $columnnumber 
                            if ($UsedTableName -eq $tableJoined) {}
                            else {
                                $SpaceString = $SpaceString + ' ' + (' ' * $tableJoined.Length)
                            }
                            if ($fileRow.Length -lt 30 -and $fileRow.EndsWith(" on")) {
                                $SpaceString = ' ' * $fileRow.Length
                            }

                            findRowColumnPosition $global:FileContent "join $($tableJoined)"
                            $global:characterPosition += 5 + $tableJoined.Length
                            sqlErrorFoundWithColumn "Required field missing in the joins: $($tableJoined).$($field)"
                            break
                        }
                        $global:lineCount+=1
                    }

                }
            }
        }
    }
}

# Returns 0 if file does not match extensions.
# Returns 1 if file matches one of the extensions.
function fileMatchesExtention([string]$FileExtentions) {
    $extentionsToCheckFor = $FileExtentions.Split(",")
    ForEach ($extention in $extentionsToCheckFor) {
        if($global:FileExtention -eq $extention){
            return 1
        }
    }
    return 0
}

# Returns 1 if the folder matches one of the folders in the parameter.
# Returns 0 if the folder does not match any of the folders in the parameter.
function folderMatchesFolder([string]$FolderNames) {
    $folderToCheck = $global:FileFolderName.ToLower()
    $foldersToCheckFor = $FolderNames.Split(",")
    if($folderToCheck.Contains("/")) {
        if ($folderToCheck.StartsWith("/")) {
            $folderToCheck = $folderToCheck.Substring(1)
        }
        $folderPathToCheck = $folderToCheck.Split("/")
    }
    else {
        if ($folderToCheck.StartsWith("/")) {
            $folderToCheck = $folderToCheck.Substring(1)
        }
        $folderPathToCheck = $folderToCheck.Split("\")
    }

    ForEach ($folder in $foldersToCheckFor) {
        if($folder -eq "") {}
        else {
            if($folder.Contains("/")) { if($folderToCheck.ToLower().Contains($folder.ToLower())) { return 1 } }
            if($folder.Contains("\")) { if($folderToCheck.ToLower().Contains($folder.ToLower())) { return 1 } }
            ForEach ($folderInPath in $folderPathToCheck) {
            if($folder.ToLower() -eq $folderInPath.ToLower()){
                    return 1
                }
            }
        }
    }
    return 0
}

# Return 1 if file matches pattern.
# Return 0 if file does not match pattern.
function fileMatchesFileNamePattern([string]$FileNamePatterns) {
    $fileName = $global:FileName.ToLower()

    if($FileNamePatterns.Trim() -eq "") {}
    else {
        $filePatterns = $FileNamePatterns.Split(",")
        ForEach ($pattern in $filePatterns) {
            
            $pattern = $pattern.Replace("*","%").ToLower()
            
            # 'test*.lo%g*d'
            # Not for now.

            # Exact match
            if($pattern -eq $fileName) {
                return 1
            }

            # '*.log%'
            if($pattern.StartsWith("%") -and $pattern.EndsWith("%")) {
                if($fileName.Contains($pattern.Replace("%",""))){
                    return 1
                }   
            }

            # '%.log'
            if($pattern.StartsWith("%")) {
                if($fileName.EndsWith($pattern.Replace("%",""))){
                    return 1
                }      
            }
            # 'test.%'
            if($pattern.EndsWith("%")) {
                if($fileName.StartsWith($pattern.Replace("%",""))){
                    return 1
                }  
            }
        # End for each pattern
        }

    }
        
    return 0
}


# Functions to check for multiple things in strings:

# Determine a column number for a specific determined column in a CSV formatted file
function determineCSVColumnForField([string]$stringToCheck,[string]$columnToFind,[string]$splitCharacter) {
    $columnidsFromString = $stringToCheck.Split(",")
    $columnCount = 0
    foreach($column in $columnidsFromString) {
        if($column -eq $columnToFind) {
                return $columnCount
        }
        $columnCount +=1
    }
}

# Count columns in a CSV formatted file
function countFieldsInCSVString([string]$stringToCheck,[string]$splitCharacter) {
        
    $countFields = 0

    $stringOpen = 0
    $stringSingleQuotesOpen = 0

    $filteredStringArray = $stringToCheck
    $filteredStringArray = $filteredStringArray.toCharArray()

    # Strings can contain ";" and ",", so we need to make sure we count adequantly:
    foreach ($letter in $filteredStringArray) {
        if($stringSingleQuotesOpen -eq 0 -and $stringOpen -eq 0) {
            if($letter -eq "," -or $letter -eq ";") {
                $countFields += 1
            }
        }
        if($letter -eq "'") {
            if($stringSingleQuotesOpen -eq 0) {
                $stringSingleQuotesOpen = 1
            }
            else { $stringSingleQuotesOpen = 0 }
        }
        if($letter -eq """") {
            if($stringOpen -eq 0) {
                $stringOpen = 1
            }
            else { $stringOpen = 0 }
        }
    }

    # Count first field:
    $countFields += 1

    return $countFields
}

# This function walks through the string with the split character and extracts the string
# that is in the specified column number

#determineCSVValueForColumn $global:currentRowString $les_opt_ath_column $splitCharacter
function determineCSVValueForColumn([string]$stringToCheck,[int]$columnCount,[string]$splitCharacter) {
     
    $currentColumnValue = ""

    $countFields = 0

    $stringOpen = 0
    $stringSingleQuotesOpen = 0

    $filteredStringArray = $stringToCheck
    $filteredStringArray = $filteredStringArray.toCharArray()

    # Strings can contain ";" and ",", so we need to make sure we move adequantly:
    foreach ($letter in $filteredStringArray) {
        if($stringSingleQuotesOpen -eq 0 -and $stringOpen -eq 0) {
            if($letter -eq "," -or $letter -eq ";") {
                if($columnCount -eq $countFields) {
                    return $currentColumnValue
                }
                $countFields += 1
                $currentColumnValue = ""
            }
        }
        if($letter -eq "'") {
            if($stringSingleQuotesOpen -eq 0) {
                $stringSingleQuotesOpen = 1
            }
            else { $stringSingleQuotesOpen = 0 }
        }
        if($letter -eq """") {
            if($stringOpen -eq 0) {
                $stringOpen = 1
            }
            else { $stringOpen = 0 }
        }
        $currentColumnValue = $currentColumnValue + $letter
    }
    if($columnCount -eq $countFields) {
        return $currentColumnValue
    }
}

# END

# This function counts individual character usage in a string:
function characterCount([string]$characterToCount,[string]$stringToCheck) {
    $temp_string = $stringToCheck.replace($characterToCount, "")
    $count = $stringToCheck.Length - $temp_string.Length
    return $count
}

# Compare one character occurances to another, like ( and )
# Return 0 if equal count, 1 if unequal
function equalCharactersInString([string]$firstCharacter,[string]$secondCharacter,[string]$stringToCheck) {
   
    $firstCharacterCount = characterCount $firstCharacter $global:FileContent
    $secondCharacterCount = characterCount $secondCharacter $global:FileContent

    if($firstCharacterCount -ne $secondCharacterCount) {
        return 1
    }
    else {
        return 0
    }
}

# Verify if a string is empty
# Return 0 if filled, 1 if empty
function emptyString([string]$stringToCheck) {
    if($stringToCheck.Trim().Length -eq 0) {
        return 1
    }
    else {
        return 0
    }
}

# Verify if a string is found inside a string
# Return columnnumber if found, otherwise return nulls
function findString([string]$stringToFind,[string]$stringToCheck) {
    ForEach ($stringRow in $stringToCheck) {
        if($stringRow.Contains($stringToFind)) {
            $columnFound = $stringRow.IndexOf($stringToFind)
                return $columnFound 
        }
    }
    return $null
}

# Verify a specific string is found in a string, but it must not also contain the other string
# Return NULL if the string is not found with the other string, otherwise it will return the column count
function findStringButNotTheOtherString([string]$stringToFind,[string]$stringNotToFind,[string]$stringToCheck) {
    ForEach ($stringRow in $stringToCheck) {
        if($stringRow.Contains($stringToFind)) {
            if($stringRow.Contains($stringNotToFind)) {}
            else {
                $columnFound = $stringRow.IndexOf($stringToFind)
                return $columnFound 
            }
        }
    }
    return $null
}

# Verify two specific strings are found in a string.
# Return NULL if the strings are not found, otherwise it will return the column count
function findTwoStringsShortLine([string]$stringOneToFind,[string]$stringTwoToFind,[string]$stringToCheck) {
    ForEach ($stringRow in $stringToCheck) {
        $stringRow = $stringRow.ToLower()
        if($stringRow.Contains($stringOneToFind.ToLower()) -And $row.Length -lt 100 -And $stringRow.Contains($stringTwoToFind.ToLower())) {
                $columnFound = $stringRow.IndexOf($stringTwoToFind.ToLower())
                return $columnFound }
        }
    return $null
}

# Verify two specific strings are found in a string.
# Return NULL if the strings are not found, otherwise it will return the column count
function findTwoStringsAnyLine([string]$stringOneToFind,[string]$stringTwoToFind,[string]$stringToCheck) {
    $stringToCheck = $stringToCheck.ToLower()
    if($stringToCheck.ToLower().Contains($stringOneToFind) -And $stringToCheck.Contains($stringTwoToFind)) {
        $columnFound = $stringToCheck.IndexOf($stringTwoToFind)
        return $columnFound 
   }
   else {
     return $null
   }
}

# Returns 0 if the character is not found, or if the character is evenly found in the string.
# Return 1 if the character is found, but not on an even manner.
function unevenDoubleCharactersInString([string]$characterToFind,[string]$stringToCheck) {
    $evenDoubleCharacters = 0
    $evenDoubleCharacters += characterCount $characterToFind $stringToCheck 
    
   $divided = $evenDoubleCharacters%2
   if($divided -gt 0) {
        return 1
   }
   return 0
   # Possibly later on add line/ column nr. But how to do so with files that have line breaks in them?
}

# Returns 0 if the character is not found, or if the character is evenly found in the content.
# Return 1 if the character is found, but not on an even manner.
function unevenDoubleCharacters([string]$characterToFind,[object]$FileContent) {
    $evenDoubleCharacters = 0
    foreach ($fileRow in $FileContent) {
        $evenDoubleCharacters += characterCount $characterToFind $fileRow 
    }
    
   $divided = $evenDoubleCharacters%2
   if($divided -gt 0) {
        return 1
   }
   return 0
   # Possibly later on add line/ column nr. But how to do so with files that have line breaks in them?
}

function performFileCheck() {
    showTypeCheckHeader "Performing File Check.."
    $scriptLocation = Join-Path $PSScriptRoot $SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.FILE.SCRIPT_NAME
    Invoke-Expression "& `"$scriptLocation`" "
}   

function performCsvCheck() {
    showTypeCheckHeader "Performing CSV Check.."
    $scriptLocation = Join-Path $PSScriptRoot $SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.CSV.SCRIPT_NAME
    Invoke-Expression "& `"$scriptLocation`" " 
}

function performSqlCheck() {
    showTypeCheckHeader "Performing SQL Check.."
    $scriptLocation = Join-Path $PSScriptRoot $SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.SQL.SCRIPT_NAME
    Invoke-Expression "& `"$scriptLocation`" "
}

function performXmlCheck() {
    showTypeCheckHeader "Performing XML Check.."
    $scriptLocation = Join-Path $PSScriptRoot $SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.XML.SCRIPT_NAME
    Invoke-Expression "& `"$scriptLocation`" "
}

function performPofCheck() {
    showTypeCheckHeader "Performing POF Check.."
    $scriptLocation = Join-Path $PSScriptRoot $SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.POF.SCRIPT_NAME
    Invoke-Expression "& `"$scriptLocation`" "
}


function performJsonCheck () {
    showTypeCheckHeader "Performing JSON Check.."
    $scriptLocation = Join-Path $PSScriptRoot $SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.JSON.SCRIPT_NAME
    Invoke-Expression "& `"$scriptLocation`" "
}



# Take the parameter as search path, if no parameter then use the settings folder:
if($Args[0] -eq $null) {
    $searchPath = $SettingsObject.SW_BYWMS_CODE_REVIEW.SCRIPT_SETTINGS.SEARCH_PATH
}
else {
    $searchPath = $Args[0]
}

Write-Output " '$($searchPath)'"

if (-not(Test-Path -Path $searchPath)) {
    Write-Output ""
    Write-Output " $($ErrorMessageNoSearchPath)" | errorLineColour
    Write-Output ""
    exit
}


if($SettingsObject.SW_BYWMS_CODE_REVIEW.SCRIPT_SETTINGS.ENABLED -eq 1) {

showHeader

# Loop through all the files:
Get-ChildItem $searchPath -Include *.* -Recurse | 
Foreach-Object {
    
    $global:FileExtention = $_.Extension.ToLower()
    $global:FileFullName = $_.FullName.ToLower()
    $global:FileName = $_.Name.ToLower()
    $global:FileFolderName = $_.DirectoryName.ToLower()
    $global:FileContent = Get-Content $global:FileFullName

    $global:currentFileErrorCount = 0
    $global:currentFileWarningCount = 0

    $global:currentFileIsEmptyOrIgnored = 0

    # Folders to be ignored. Please add '/' or '\' if sub folders need to be ignored, like for example: 
    # "ignore/onlythis" in "/users/randy/ignore/onlythis/test":
    if ((folderMatchesFolder $SettingsObject.SW_BYWMS_CODE_REVIEW.IGNORE_SETTINGS.IGNORE_FOLDERS) -eq 1) {
        $global:currentFileIsEmptyOrIgnored = 1
        $global:ignoredFileCount += 1
    }
    else {
            # Files to be ignored.
            if ((fileMatchesFileNamePattern $SettingsObject.SW_BYWMS_CODE_REVIEW.IGNORE_SETTINGS.IGNORE_FILES) -eq 1) {
                $global:currentFileIsEmptyOrIgnored = 1
                $global:ignoredFileCount += 1
            }
    }
    
    if( $global:currentFileIsEmptyOrIgnored -eq 0) {
            
        Write-Output " File: '$($global:FileFullName) " | scriptLineColour

        # File checking:
        if($SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.FILE.ENABLED -eq 1) {
            performFileCheck
        }

        if($global:currentFileIsEmptyOrIgnored -ne 1) {

            if($global:FileExtention -eq '.csv' -and $SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.CSV.ENABLED -eq 1) {
                performCsvCheck 
            }

            if($global:FileExtention -eq '.sql' -and $SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.SQL.ENABLED -eq 1) {
                performSqlCheck 
            }

            if($SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.XML.ENABLED -eq 1 -and
            ($global:FileExtention -eq '.xml' -or (fileMatchesExtention $SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.XML.VERIFY_AS_XML) -eq 1)) {
                performXmlCheck
            }

            if($global:FileExtention -eq '.json' -and $SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.JSON.ENABLED -eq 1) {
                performJsonCheck
            }

            if($global:FileExtention -eq '.pof' -and $SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.POF.ENABLED -eq 1) {
                performPofCheck
            }

        }

        if($global:currentFileWarningCount -eq 0 -and $global:currentFileErrorCount -eq 0) {
            Write-Output " "
            Write-Output "   > No errors and warnings found. "
        }
        else {
            Write-Output " "
            if($global:currentFileWarningCount -gt 0) { Write-Output "   > Warnings found: $($global:currentFileWarningCount) " }
            if($global:currentFileErrorCount -gt 0)   { Write-Output "   > Errors found: $($global:currentFileErrorCount) " }
        }

        $global:fileCount += 1
        Write-Output " "
    }
}


showEndAnalysis

# End script enabled setting
}
else {
    Write-Output " Script is disabled. "
    Write-Output " "
}