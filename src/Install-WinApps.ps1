Function Install-WinGet {
    param(
        [Parameter(Mandatory = $true)]
        $ProgressBar,
        [Parameter(Mandatory = $true)]
        $CurrentOperation
    )

    # Get latest download url for WinGet
    $asset = Invoke-RestMethod -Method Get -Uri 'https://api.github.com/repos/microsoft/winget-cli/releases/latest' | ForEach-Object assets | Where-Object name -like "*.msixbundle"

    $InstallerWinGet = $env:TEMP + "\$($asset.name)"
    $currentVersionWinGet = $asset.browser_download_url | Select-String '(\bv?(?:\d+\.){2}\d+)' | ForEach-Object { $_.Matches[0].Groups[1].Value }

    Try {
        $installedVersionWinGet = Invoke-Expression 'winget --version'
    }
    Catch {
        $installedVersionWinGet = $null
    }

    if (!($currentVersionWinGet -le $installedVersionWinGet)) {
        if ($currentVersionWinGet -gt $installedVersionWinGet -and $null -ne $installedVersionWinGet) {
            $ProgressBar.Value = 3
            $ProgressBar.Refresh()
            $CurrentOperation.Text = "Current Operation:`n Updating winget $($installedVersionWinGet) to $($currentVersionWinGet)"
            $CurrentOperation.Refresh()

            $progresspreference = 'silentlyContinue'
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $InstallerWinGet
            Add-AppxPackage -Path $InstallerWinGet -Update
            $progressPreference = 'Continue'
        }
        else {
            $ProgressBar.Value = 3
            $ProgressBar.Refresh()
            $CurrentOperation.Text = "Current Operation:`n Installing winget $($currentVersionWinGet)"
            $CurrentOperation.Refresh()

            $progresspreference = 'silentlyContinue'
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $InstallerWinGet
            Add-AppxPackage -Path $InstallerWinGet
            $progressPreference = 'Continue'
        }

        if (Test-Path -Path "$InstallerWinGet") {
            Remove-Item $InstallerWinGet -Force -ErrorAction SilentlyContinue
        }
    }

    $ProgressBar.Value = 4
    $ProgressBar.Refresh()
    $CurrentOperation.Text = "Current Operation:`n Dependency winget $($currentVersionWinGet) is installed"
    $CurrentOperation.Refresh()

    Return $ProgressBar
}


Function Install-WinGetSoftware {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Id
    )

    if ((Invoke-Expression "winget list --exact --id $Id --accept-source-agreements") -eq 'No installed package found matching input criteria.') {
        Invoke-Expression "winget install --exact --id $Id --source winget --accept-source-agreements --accept-package-agreements --silent"
    }
}



Function Invoke-SoftwareInstallProcess {
    param (
        [Parameter(Mandatory = $true)]
        $CheckBoxes,
        [Parameter(Mandatory = $true)]
        $ProgressBar,
        [Parameter(Mandatory = $true)]
        $CurrentOperation
    )

    $ProgressBar = Install-WinGet -ProgressBar $ProgressBar -CurrentOperation $CurrentOperation
    $ProgressBar.Refresh()
    $CurrentOperation.Refresh()

    $softwarePackages = @{
        Firefox                   = 'Mozilla.Firefox'
        Chrome                    = 'Google.Chrome'
        Brave                     = 'BraveSoftware.BraveBrowser'
        Edge                      = 'Microsoft.Edge'
        LibreOffice               = 'TheDocumentFoundation.LibreOffice'
        OpenOffice                = 'Apache.OpenOffice'
        OnlyOffice                = 'ONLYOFFICE.DesktopEditors'
        Thunderbird               = 'Mozilla.Thunderbird'
        Authy                     = 'Twilio.Authy'
        Bitwarden                 = 'Bitwarden.Bitwarden'
        LastPass                  = 'LogMeIn.LastPass'
        KeePass                   = 'DominikReichl.KeePass'
        Steam                     = 'Valve.Steam'
        GOGGalaxy                 = 'GOG.Galaxy'
        EpicLauncher              = 'EpicGames.EpicGamesLauncher'
        Git                       = 'Git.Git'
        VisualStudioCode          = 'Microsoft.VisualStudioCode'
        VisualStudio2022Community = 'Microsoft.VisualStudio.2022.Community'
        PowerShell7               = 'Microsoft.PowerShell'
        Python3                   = 'Python.Python.3'
    }


    $ProgressBar.Value = 5
    $CurrentOperation.Text = "Current Operation:`n Determine items selected"

    $softwareSelected = [System.Collections.Generic.List[string]]@()

    ForEach ($checkbox in $CheckBoxes) {
        if ($checkbox.Checked -eq $true -and $checkbox.Name -in $softwarePackages.Keys) {
            $softwareSelected.Add($($checkBox.Name))
        }
    }

    if ($softwareSelected.Count -eq 0) {
        $CurrentOperation.Text = "Current Operation:`n No items to install"
        $CurrentOperation.Refresh()
        $ProgressBar.Value = 100
        $ProgressBar.Refresh()
        Return
    }

    [int]$progressAmount = [math]::floor((100 - $ProgressBar.Value) / $softwareSelected.Count)

    ForEach ($software in $softwareSelected) {
        $CurrentOperation.Text = "Current Operation:`n Installing $($software)"
        $CurrentOperation.Refresh()

        Install-WinGetSoftware -Id $softwarePackages.$($software)

        $ProgressBar.Value += $progressAmount
        $ProgressBar.Refresh()
    }

    $CurrentOperation.Text = "Current Operation:`n Installs Complete"
    $CurrentOperation.Refresh()
    $ProgressBar.Value = 100
    $ProgressBar.Refresh()
}


Function New-CheckBoxGroup {
    param (
        [Parameter(Mandatory = $true)]
        $GroupBoxes,
        [Parameter(Mandatory = $true)]
        $CheckBoxes,
        [Parameter(Mandatory = $true)]
        [string]$SoftwareGroupName,
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.List[string]]$SoftwareList
    )

    $groupBox = New-Object System.Windows.Forms.GroupBox
    $groupBox.AutoSize = $true
    $groupBox.AutoSizeMode = 'GrowAndShrink'
    $groupBox.Margin = 5
    $groupBox.Text = $SoftwareGroupName
    $groupBox.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#2f9ff5")

    $checkBoxCounter = 1
    ForEach ($software in ($SoftwareList | Sort-Object)) {
        $checkBox = New-Object System.Windows.Forms.CheckBox
        $checkBox.UseVisualStyleBackColor = $True
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 120
        $System_Drawing_Size.Height = 27
        $checkBox.Size = $System_Drawing_Size
        $checkBox.TabIndex = 2

        $checkBox.Text = $software
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 15

        # Vertically space dynamically
        $System_Drawing_Point.Y = 27 + (($checkBoxCounter - 1) * 27)
        $checkBox.Location = $System_Drawing_Point
        $checkBox.DataBindings.DefaultDataSourceUpdateMode = 0

        $checkBox.Name = $software -replace ' ', ''
        $groupBox.Controls.Add($checkBox)
        $checkBoxCounter++

        $CheckBoxes += $checkBox
    }

    $GroupBoxes += $groupBox

    Return $GroupBoxes, $Checkboxes
}


Function Initialize-Form {
    Add-Type -assembly System.Windows.Forms

    $screenWorkingArea = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea

    $GroupBoxes = @()
    $CheckBoxes = @()

    $iconBase64 = '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'
    $iconBytes = [Convert]::FromBase64String($iconBase64)
    $iconStream = [System.IO.MemoryStream]::new($iconBytes, 0, $iconBytes.Length)

    # Set the size of your form
    $form = New-Object System.Windows.Forms.Form
    $form.AutoScaleMode = "Font"
    $form.Width = $screenWorkingArea.Width * 0.50
    $form.Height = $screenWorkingArea.Height * 0.50
    $form.AutoSize = $false
    $form.Text = "Install-WinApps"
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedSingle"
    $form.TopMost = $false
    $form.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($iconStream).GetHIcon()))
    $form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#323538")

    #Add flow layout panel
    $flowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $flowLayoutPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
    $flowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $flowLayoutPanel.AutoSize = $true
    $flowLayoutPanel.AutoScroll = $true
    $form.Controls.Add($flowLayoutPanel)

    # Software Selection Groups
    $browserList = [System.Collections.Generic.List[string]]@('Firefox', 'Chrome', 'Brave', 'Edge')
    $GroupBoxes, $Checkboxes = New-CheckBoxGroup -GroupBoxes $GroupBoxes -Checkboxes $CheckBoxes -SoftwareGroupName 'Browsers' -SoftwareList $browserList

    $officeList = [System.Collections.Generic.List[string]]@('Libre Office', 'Open Office', 'Only Office')
    $GroupBoxes, $Checkboxes = New-CheckBoxGroup -GroupBoxes $GroupBoxes -Checkboxes $CheckBoxes -SoftwareGroupName 'Office Suites' -SoftwareList $officeList

    $emailList = [System.Collections.Generic.List[string]]@('Thunderbird')
    $GroupBoxes, $Checkboxes = New-CheckBoxGroup -GroupBoxes $GroupBoxes -Checkboxes $CheckBoxes -SoftwareGroupName 'Email' -SoftwareList $emailList

    $securityList = [System.Collections.Generic.List[string]]@('Authy', 'Bitwarden', 'LastPass', 'KeePass')
    $GroupBoxes, $Checkboxes = New-CheckBoxGroup -GroupBoxes $GroupBoxes -Checkboxes $CheckBoxes -SoftwareGroupName 'Security' -SoftwareList $securityList

    $gamingList = [System.Collections.Generic.List[string]]@('Steam', 'GOG Galaxy', 'Epic Launcher')
    $GroupBoxes, $Checkboxes = New-CheckBoxGroup -GroupBoxes $GroupBoxes -Checkboxes $CheckBoxes -SoftwareGroupName 'Gaming' -SoftwareList $gamingList

    $codingList = [System.Collections.Generic.List[string]]@('Git', 'Visual Studio Code', 'Visual Studio 2022 Community', 'PowerShell 7', 'Python 3')
    $GroupBoxes, $Checkboxes = New-CheckBoxGroup -GroupBoxes $GroupBoxes -Checkboxes $CheckBoxes -SoftwareGroupName 'Coding' -SoftwareList $codingList


    # $listTest1 = [System.Collections.Generic.List[string]]@('Apple', 'Blueberry', 'Orange', 'Cranberry', 'Mango')
    # $GroupBoxes, $Checkboxes = New-CheckBoxGroup -GroupBoxes $GroupBoxes -CheckBoxes $CheckBoxes -SoftwareGroupName 'Fruit' -SoftwareList $listTest1

    # $listTest2 = [System.Collections.Generic.List[string]]@('Cat', 'Dog', 'Fish', 'Horse', 'Hampster')
    # $GroupBoxes, $Checkboxes = New-CheckBoxGroup -GroupBoxes $GroupBoxes -CheckBoxes $CheckBoxes -SoftwareGroupName 'Pets' -SoftwareList $listTest2

    # $listTest3 = [System.Collections.Generic.List[string]]@('Spring', 'Summer', 'Fall', 'Winter')
    # $GroupBoxes, $Checkboxes = New-CheckBoxGroup -GroupBoxes $GroupBoxes -CheckBoxes $CheckBoxes -SoftwareGroupName 'Seasons' -SoftwareList $listTest3


    # Space GroupBoxes dynamically
    ForEach ($groupBox in $GroupBoxes) {
        $flowLayoutPanel.Controls.Add($groupBox)
    }

    # Progress Information
    $progressPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $progressPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
    $progressPanel.WrapContents = $false
    $progressPanel.Height = 27
    $progressPanel.Dock = [System.Windows.Forms.DockStyle]::Top
    $form.Controls.Add($progressPanel)

    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Name = 'progressBar'
    $progressBar.Visible = $false
    $progressBar.Value = 1
    $progressBar.Style = "Continuous"
    $progressBar.Height = 25
    $progressBar.Width = $form.Width / 2 - 15
    $progressPanel.Controls.Add($progressBar)

    $currentOperation = New-Object System.Windows.Forms.Label
    $currentOperation.Name = 'currentOperation'
    $currentOperation.Visible = $false
    $currentOperation.Height = 26
    $currentOperation.Width = $form.Width / 2 - 15
    $currentOperation.Text = "Current Operation:`n Checking Dependancies"
    $currentOperation.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#2f9ff5")
    $currentOperation.Margin = 1
    $progressPanel.Controls.Add($currentOperation)

    # Buttons
    $buttonPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttonPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::RightToLeft
    $buttonPanel.WrapContents = $false
    $buttonPanel.Height = 55
    $buttonPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $form.Controls.Add($buttonPanel)

    $buttonClose = new-object System.Windows.Forms.Button
    $buttonClose.Size = new-object System.Drawing.Size(100, 40)
    $buttonClose.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#8b8f94")
    $buttonClose.Text = "Close"
    $buttonClose.Add_Click( { $form.Close() })
    $buttonPanel.Controls.Add($buttonClose)

    $buttonInstall = new-object System.Windows.Forms.Button
    $buttonInstall.Size = new-object System.Drawing.Size(100, 40)
    $buttonInstall.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#8b8f94")
    $buttonInstall.Text = "Install Selections"
    $buttonInstall.Add_Click( {
            $buttonInstall.Enabled = $false
            $buttonClose.Enabled = $false
            $progressBar.Visible = $true
            $currentOperation.Visible = $true

            Invoke-SoftwareInstallProcess -Checkboxes $CheckBoxes -ProgressBar $progressBar -CurrentOperation $currentOperation

            # Reset controls for possible additional executions
            $progressBar.Visible = $false
            $currentOperation.Visible = $false
            $progressBar.Value = 1
            $currentOperation.Text = "Current Operation:`n Checking Dependancies"
            $buttonInstall.Enabled = $true
            $buttonClose.Enabled = $true
        })
    $buttonPanel.Controls.Add($buttonInstall)

    # Activate/Show the form
    $form.Add_Shown( { $form.Activate() })
    [void] $form.ShowDialog()
}




#region Main
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')

if ($isAdmin -eq $false) {
    Throw "Must be executed from an Administrator elevated session"
}


Initialize-Form
#endregion Main