# Description
Automate installing and running Fortify scan to meet security requirements.

# Install Fortify scan client
1. Clone
    ```bash
    git clone https://github.com/Youhana-Hana/fortify-scan.git
    ```
2.  Install scan client and Maven plugin
    Open powershell as **Administrator** 

    ``` bash
        cd devAndDeployHelpers/fortify
        ./install.ps1
    ```
3. Update .m2/settings.xml with the following **pluginGroup**
    <pluginGroup>com.fortify.ps.maven.plugin</pluginGroup

# Scan your project
1. Copy devAndDeployHelpers/fortify/runFortifyScan.ps1 to your project root
2. Open powershell as normal user 
    ``` bash
    cp <devAndDeployHelpers>/fortify/runFortifyScan.ps1 <Project Root>
    ```
3. Run runFortifyScan.ps1
    ``` bash
    ./runFortifyScan.ps1
    ```
4. Script will generate report at ./target/<artifactId>.fpr, search for any critical or high issues
5. If output is "All OKAY!, Great job :)" for both critical and high issues, then you are safe, otherwise: Navigate to the report at ".target/<artifactId>.fpr"", then open it using fortify Audit WorkBench and start resolving issues.
