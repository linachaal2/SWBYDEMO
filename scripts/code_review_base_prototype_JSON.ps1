
$global:jsonFileCount += 1 

if($SettingsObject.SW_BYWMS_CODE_REVIEW.FILE_TYPES.JSON.SYNTAX_CHECK -eq 1) {
    try
    {
        $text = $($global:FileContent)
        $json = $text | ConvertFrom-Json
    }
    catch
    {
        jsonErrorFound "JSON syntax error found."  
    }   
}
#catch [System.Xml.XmlException] {