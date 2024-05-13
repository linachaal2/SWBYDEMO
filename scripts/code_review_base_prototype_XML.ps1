
$global:xmlFileCount += 1 

if($SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.XML.SYNTAX_CHECK -eq 1) {
    $xml = New-Object System.Xml.XmlDocument

    try {
        $xml.Load($global:FileFullName)
    }
    catch [System.Xml.XmlException] {
        xmlErrorFound "XML Syntax error: $($_.toString())"
    }
}