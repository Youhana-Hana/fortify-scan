Function checkReport($level) {
    "Search scan report for $level issues...."
    $result = FPRUtility.bat -information -search -query "[fortify priority order]:$level" -project .\target\*.fpr
    if($result -match "No issues matched search query."){
        "All OKAY!, Great job :)"
    } else {
        $result
        "Oops!, Something went wrong. Please check report to fix it"
        exit 1
    }
}

mvn clean package -DskipTests
mvn sca:clean
mvn sca:ear
mvn sca:translate
mvn sca:cleanUpGeneratedSources
mvn sca:scan

FPRUtility.bat -information -errors -project .\target\*.fpr
FPRUtility.bat -information -categoryIssueCounts -project .\target\*.fpr

checkReport "critical"

checkReport "high"
