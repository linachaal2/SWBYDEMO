
$global:pofFileCount += 1 

# Checks for inside the file:
$global:lineCount = 1

$longLineFound = 0
$startTagFound = 0
$commandFileTagFound = 0
$referencedFieldsFound = 0
$endTagFound = 0

ForEach ($row in $global:FileContent) {
    $global:currentRowString = $row.Trim().ToLower()
    
    if($global:currentRowString.length -gt 150) { $longLineFound += 1 }

    $findValue = findString "^xa" $global:currentRowString
    if($findValue -ge 0) { $startTagFound += 1 }

    $findValue = findString "~cmd_file=" $global:currentRowString
    if($findValue -ge 0) { $commandFileTagFound += 1 }

    $findValue = findString "^xz" $global:currentRowString
    if($findValue -ge 0) { $endTagFound += 1 }

    $findValue = findString " ^" $global:currentRowString
    if($findValue -ge 0) {
        $global:characterPosition = $findValue
        pofWarningFoundWithColumn "Too many spaces: space before tag."
    }

    $findValue = findString "^ " $global:currentRowString
    if($findValue -ge 0) {
        $global:characterPosition = $findValue + 1
        pofWarningFoundWithColumn "Too many spaces: space after tag."
    }

    $findValue = findString "^fd^fs" $global:currentRowString
    if($findValue -ge 0) {
        $global:characterPosition = $findValue + 3
        pofWarningFoundWithColumn "Empty value '^FD^FS' was found, please add a field or text."
    }

    # Correct usage of the ^FX command includes following it with the ^FS command.
    $findValue = findString "^fx" $global:currentRowString
    if($findValue -ge 0) {
        $global:characterPosition = $findValue + 3
        $findValue = findTwoStringsAnyLine "^fx" "^fs" $global:currentRowString
        if($findValue -eq $null) {
            pofWarningFoundWithColumn "'^FX' must always be followed by a '^FS'"
        }
    }

    # ~ not equally found:
    $findValue = unevenDoubleCharactersInString "~" $global:currentRowString
    if($findValue -eq 1) {
        pofErrorFound "When inserting fields, the '~' character needs to be followed by a '~'."
    }


    # ~delivery_location_1,10~
    #                     ^ width not found
    #The inserted field does not have a (correct) width defined
    $findValue = characterCount "~" $global:currentRowString
    if($findValue -gt 1) { 
        $referencedFieldsFound += 1
        $fieldValue = $global:currentRowString.Substring($global:currentRowString.IndexOf("~")+1)
        $fieldValue = $fieldValue.Substring(0,$fieldValue.IndexOf("~"))
        $global:characterPosition = $global:currentRowString.IndexOf("~")
        if($fieldValue.Contains(",")) {
            $fieldDeclaration = $fieldValue.Split(",")
            $global:characterPosition = $global:characterPosition + $fieldDeclaration[0].Length+2
            if($fieldDeclaration[1] -match "^\d+$") {}
            else {
                pofErrorFoundWithColumn "Length for inserted field is not correct"
            }
        }
        else {
            $global:characterPosition = $global:characterPosition + $fieldValue.Length
            pofErrorFoundWithColumn "When inserting fields, a length is necessary"
        }
    }

    $global:lineCount += 1
}

if($startTagFound -eq 0) {
    pofErrorFound "The ZPL start tag '^XA' cannot be found."
}

if($longLineFound -gt 3) {
    pofWarningFound "It is common practice to add line breaks to the ZPL. Can you add line breaks for better visibility?"
}

if($referencedFieldsFound -gt 1 -and $commandFileTagFound -eq 0) {
    pofErrorFound "Referenced fields are found, but there is no command file declaration."
}

if($endTagFound -eq 0) {
    pofErrorFound "The ZPL end tag '^XZ' cannot be found."
}
if(($startTagFound -gt 0 -and $endTagFound -gt 0) -and ($startTagFound -ne $endTagFound)) {
    pofErrorFound "The ZPL start tag '^XA' and end tags '^XZ' do not match."
}



# Warning, "^CI28: Unicode (UTF-8 encoding) - Unicode Character Set" not set.
# Do you want to include it to help support different characters?
# ^CI28

# Format overview checker function?

# Check format:
# ^PQ~pckqty,2~

# ^PRp,s,b
# The ^PR command determines the media and slew speed (feeding a blank
# label) during printing.

# ^LHx,y
# The ^LH command sets the label home position

# ^LL190
# ^PW330

# ^FOx,y,z

# ^Af,o,h,w

# if this found: ~delivery_location_1,10~
# then check for: ^FV~CMD_FILE=USR_DCKUNNVAS007.MSQL,50~^FS


#foreach ($char in $global:currentRowString.ToCharArray()) 
#{ 
#    if($char -eq "~") {
#
#    } 
#}