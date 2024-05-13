
function determineCSVSplitCharacter([string]$FileContent) {
    # Add other split characters at some point
    $komma = characterCount "," $FileContent
    $semiColon = characterCount ";" $FileContent

    if($komma -eq 0 -and $semiColon -eq 0) {
        Write-Output "    No split character found! " | errorLineColour
    }
    else {
        if($komma -gt 0) {
            if($komma -gt $semiColon) {
                return ","
            }
            else {
                    return ";"
                }
        }
        else {
            return ";"
        }
    }
}

$CurrentQuery = New-Object -TypeName 'System.Collections.ArrayList';

$global:csvFileCount += 1

$global:lineCount = 1

$splitCharacter = ""

# Determine if CSV is split by "," or ";"
$splitCharacter = determineCSVSplitCharacter $global:FileContent


$fieldCount = 0
$ContentRow = 0

$les_opt_ath_column = 0

# Walk through most common CSV problems manually:
ForEach ($row in $global:FileContent) {
    $global:currentRowString = $row.Trim().ToLower()

    if($global:currentRowString -eq "") {
        csvWarningFoundWithRow "This line is empty, please remove!"
    }
    else {
        $les_opt_ath_value = determineCSVValueForColumn $global:currentRowString 0 $splitCharacter
        write-Output "   Column 1: $($les_opt_ath_value)"
        $les_opt_ath_value = determineCSVValueForColumn $global:currentRowString 1 $splitCharacter
        write-Output "   Column 2: $($les_opt_ath_value)"
        $les_opt_ath_value = determineCSVValueForColumn $global:currentRowString 2 $splitCharacter
        write-Output "   Column 3: $($les_opt_ath_value)"
        
            if (($SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.CSV.LES_OPT_ATH.ENABLED) -eq 1) {
                if($global:FileName.Contains("les_opt_ath")) {
                    
                    if($ContentRow -eq 0) {
                        #[string]$stringToCheck,[string]$columnToFind,[string]$splitCharacter) {
                        $les_opt_ath_column = determineCSVColumnForField $global:currentRowString "ath_id" $splitCharacter
                        Write-Output "   les_opt_ath detected: $($les_opt_ath_column)"
                    }
                    else {
                        # data row
                        #$les_opt_ath_value = determineCSVValueForColumn $global:currentRowString $les_opt_ath_column $splitCharacter
                    }
                    #dddddd
                    
                    #$les_opt_ath_column
                    #ath_id

                    if (($SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.CSV.LES_OPT_ATH.OTHER_USERS_THEN_SUPER) -eq 1) {
                        
                        
                    }
                  
                  }  
            }
            
            if (($SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.CSV.CHECK_FIELD_AMOUNT) -eq 1) {
                if($fieldCount -eq 0) {
                    $fieldCount = countFieldsInCSVString $global:currentRowString $splitCharacter
                }
                else {
                    $newFieldCount = countFieldsInCSVString $global:currentRowString $splitCharacter
                    if($fieldCount -ne $newFieldCount) {
                        csvErrorFoundWithRow "The defined columns do not match the defined headers!"
                    }
                }
        }

        # Indicate that the next rows are all content:
        $ContentRow = 1
    }

    
    $global:lineCount += 1
}

