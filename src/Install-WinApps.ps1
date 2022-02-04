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
        Invoke-Expression "winget install --exact --id $Id --source winget --silent"
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
        Firefox = 'Mozilla.Firefox'
        Chrome  = 'Google.Chrome'
        Brave   = 'BraveSoftware.BraveBrowser'
        Edge    = 'Microsoft.Edge'
    }


    $ProgressBar.Value = 5
    $CurrentOperation.Text = "Current Operation:`n Determine items selected"

    $softwareSelected = [System.Collections.Generic.List[string]]@()

    ForEach ($checkbox in $CheckBoxes) {
        if ($checkbox.Checked -eq $true -and $checkbox.Text -in $softwarePackages.Keys) {
            $softwareSelected.Add($($checkBox.Text))
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
    $groupBox.Text = $SoftwareGroupName

    $checkBoxCounter = 1
    ForEach ($software in ($SoftwareList | Sort-Object)) {
        $checkBox = New-Object System.Windows.Forms.CheckBox
        $checkBox.UseVisualStyleBackColor = $True
        $System_Drawing_Size = New-Object System.Drawing.Size
        $System_Drawing_Size.Width = 120
        $System_Drawing_Size.Height = 24
        $checkBox.Size = $System_Drawing_Size
        $checkBox.TabIndex = 2

        $checkBox.Text = $software
        $System_Drawing_Point = New-Object System.Drawing.Point
        $System_Drawing_Point.X = 15

        # Vertically space dynamically
        $System_Drawing_Point.Y = 25 + (($checkBoxCounter - 1) * 25)
        $checkBox.Location = $System_Drawing_Point
        $checkBox.DataBindings.DefaultDataSourceUpdateMode = 0

        $checkBox.Name = "CheckBox$($software)"
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
    $form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#b8b8b8")

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

    # $officeList = [System.Collections.Generic.List[string]]@('Libre Office', 'Open Office')
    # $GroupBoxes, $Checkboxes = New-CheckBoxGroup -GroupBoxes $GroupBoxes -Checkboxes $CheckBoxes -SoftwareGroupName 'Office Suites' -SoftwareList $officeList

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