
# Generic checks over the full file:

if ((fileMatchesExtention $SettingsObject.SW_BYWMS_CODE_REVIEW.IGNORE_SETTINGS.OPEN_SQUARE_BRACKETS_CHECK_ONLY_FOR -eq 1) -or $SettingsObject.SW_BYWMS_CODE_REVIEW.IGNORE_SETTINGS.OPEN_SQUARE_BRACKETS_CHECK_ONLY_FOR -eq "*") {
    $verifyBracketsMatch = equalCharactersInString "[" "]" $global:FileContent
    if($verifyBracketsMatch -eq 1) {
        fileWarningFound "Unclosed usage of '[' and ']'"
    }
}

if ((fileMatchesExtention $SettingsObject.SW_BYWMS_CODE_REVIEW.IGNORE_SETTINGS.OPEN_BRACKETS_CHECK_ONLY_FOR -eq 1) -or $SettingsObject.SW_BYWMS_CODE_REVIEW.IGNORE_SETTINGS.OPEN_BRACKETS_CHECK_ONLY_FOR -eq "*") {
    $verifyBracketsMatch = equalCharactersInString "(" ")" $global:FileContent
    if($verifyBracketsMatch -eq 1) {
        fileWarningFound "Unclosed usage of '(' and ')'"
    }
}

if ((fileMatchesExtention $SettingsObject.SW_BYWMS_CODE_REVIEW.IGNORE_SETTINGS.UNEVEN_DOUBLE_QUOTES_CHECK_ONLY_FOR -eq 1) -or $SettingsObject.SW_BYWMS_CODE_REVIEW.IGNORE_SETTINGS.UNEVEN_DOUBLE_QUOTES_CHECK_ONLY_FOR -eq "*") {
    $verifyDoubleQuotesEvenness = unevenDoubleCharacters """" $global:FileContent
    if($verifyDoubleQuotesEvenness -eq 1) {
        fileErrorFound "Uneven usage of double quotes."
    }
}

if ((fileMatchesExtention $SettingsObject.SW_BYWMS_CODE_REVIEW.IGNORE_SETTINGS.UNEVEN_SINGLE_QUOTES_CHECK_ONLY_FOR -eq 1) -or $SettingsObject.SW_BYWMS_CODE_REVIEW.IGNORE_SETTINGS.UNEVEN_SINGLE_QUOTES_CHECK_ONLY_FOR -eq "*") {
    $verifyDoubleQuotesEvenness = unevenDoubleCharacters "'" $global:FileContent
    if($verifyDoubleQuotesEvenness -eq 1) {
        fileErrorFound "Uneven usage of single quotes."
    }
}

if ((fileMatchesExtention $SettingsObject.SW_BYWMS_CODE_REVIEW.IGNORE_SETTINGS.EMPTY_FILE_CHECK_ONLY_FOR -eq 1) -or $SettingsObject.SW_BYWMS_CODE_REVIEW.IGNORE_SETTINGS.EMPTY_FILE_CHECK_ONLY_FOR -eq "*") {
    $verifyEmptyFile = emptyString $global:FileContent
    if($verifyEmptyFile -eq 1) {
        fileErrorFound "Empty file detected" 
        $global:currentFileIsEmptyOrIgnored = 1
    }       
}
