Function New-CheckBoxGroup {
    param (
        [Parameter(Mandatory = $true)]
        $GroupBoxes,
        [Parameter(Mandatory = $true)]
        $Checkboxes,
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
    $Form = New-Object System.Windows.Forms.Form
    $Form.AutoScaleMode = "Font"
    $Form.Width = $screenWorkingArea.Width * 0.50
    $Form.Height = $screenWorkingArea.Height * 0.50
    $Form.AutoSize = $false
    $Form.Text = "Install-WinApps"
    $Form.StartPosition = "CenterScreen"
    $Form.TopMost = $false
    $Form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#b8b8b8")

    #Add flow layout panel
    $flowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $flowLayoutPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
    $flowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $flowLayoutPanel.AutoSize = $true
    $flowLayoutPanel.AutoScroll = $true
    $Form.Controls.Add($flowLayoutPanel)

    # $browserList = [System.Collections.Generic.List[string]]@('Firefox', 'Chrome', 'Brave', 'Edge')
    # $GroupBoxes, $Checkboxes = New-CheckBoxGroup -GroupBoxes $GroupBoxes -Checkboxes $CheckBoxes -SoftwareGroupName 'Browsers' -SoftwareList $browserList

    # $officeList = [System.Collections.Generic.List[string]]@('Libre Office', 'Open Office')
    # $GroupBoxes, $Checkboxes = New-CheckBoxGroup -GroupBoxes $GroupBoxes -Checkboxes $CheckBoxes -SoftwareGroupName 'Office Suites' -SoftwareList $officeList

    $listTest1 = [System.Collections.Generic.List[string]]@('Apple', 'Blueberry', 'Orange', 'Cranberry', 'Mango')
    $GroupBoxes, $Checkboxes = New-CheckBoxGroup -GroupBoxes $GroupBoxes -Checkboxes $CheckBoxes -SoftwareGroupName 'Fruit' -SoftwareList $listTest1

    $listTest2 = [System.Collections.Generic.List[string]]@('Cat', 'Dog', 'Fish', 'Horse', 'Hampster')
    $GroupBoxes, $Checkboxes = New-CheckBoxGroup -GroupBoxes $GroupBoxes -Checkboxes $CheckBoxes -SoftwareGroupName 'Pets' -SoftwareList $listTest2

    $listTest3 = [System.Collections.Generic.List[string]]@('Spring', 'Summer', 'Fall', 'Winter')
    $GroupBoxes, $Checkboxes = New-CheckBoxGroup -GroupBoxes $GroupBoxes -Checkboxes $CheckBoxes -SoftwareGroupName 'Seasons' -SoftwareList $listTest3


    # Space GroupBoxes dynamically
    ForEach ($groupBox in $GroupBoxes) {
        $flowLayoutPanel.Controls.Add($groupBox)
    }

    $buttonPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $buttonPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::RightToLeft
    $buttonPanel.WrapContents = $false
    $buttonPanel.Height = 55
    $buttonPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $Form.Controls.Add($buttonPanel)

    $buttonClose = new-object System.Windows.Forms.Button
    $buttonClose.Size = new-object System.Drawing.Size(100, 40)
    $buttonClose.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#8b8f94")
    $buttonClose.Text = "Close"
    #$buttonClose.Add_Click( { $Form.Visible = $false; Invoke-SoftwareInstallProcess -Checkboxes $checkboxes; $Form.Close() })
    $buttonPanel.Controls.Add($buttonClose)

    $buttonInstall = new-object System.Windows.Forms.Button
    $buttonInstall.Size = new-object System.Drawing.Size(100, 40)
    $buttonInstall.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#8b8f94")
    $buttonInstall.Text = "Install Selections"
    #$OKButton.Add_Click( { $Form.Visible = $false; Invoke-SoftwareInstallProcess -Checkboxes $checkboxes; $Form.Close() })
    $buttonPanel.Controls.Add($buttonInstall)

    # Activate/Show the form
    $Form.Add_Shown( { $Form.Activate() })
    [void] $Form.ShowDialog()
}

Initialize-Form