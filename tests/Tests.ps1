. "src\utils.ps1"

Describe "Remove brackets" {
    It "Should remove some brackets" {
        removeBrackets("trolololololo") | should be "trolololololo"
        removeBrackets("trolo[lo]lololo") | should be "trololololo"
        removeBrackets("Some Comic Name [Scanlated by Someone][ScanGroupWhatever]") | should be "Some Comic Name"
        removeBrackets("Some Comic Name [Scanlated by Someone][ScanGroupWhatever]    ") | should be "Some Comic Name"
        removeBrackets("Some Comic Name [Scanlated by Someone][ScanGroupWhatever].cbz") | should be "Some Comic Name.cbz"
        removeBrackets("Some Comic Name [Scanlated by Someone] [ScanGroupWhatever]   .cbz") | should be "Some Comic Name.cbz"
    }
}