# Install-WinApps

A script to easily select and install common Windows applications, which are free or open source.

Please, consider donating or contributing to any of the open source software you enjoy using.
Contributing can be as simple as submiting Issues or Feature Requests.

## Requirements

- Internet access.
- You must have the rights to install software on the computer.
- You must start the script from an Administrator PowerShell session.

## Instructions

- Open an Administrator PowerShell session.
- Execute the following command:

```PowerShell
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/TrisBits/Install-WinApps/main/src/Install-WinApps.ps1'))
```

## Alternate Instructions

- Download and unzip the script.
- In an Administrator PowerShell session browse to the location of Install-WinApps.ps1.
- Execute the script using the following command.  If you recieve the error "not digitally signed" you will first need to execute the command **Unblock-File -Path .\Install-WinApps.ps1**

```PowerShell
.\Install-WinApps.ps1
```

## Software Currently Supported

You will be presented with checkboxes to select from the following software.

> Click the software links below if you wish to read more on the vendor website. <br>
> ** Indicates my personal recommendations.

- Browsers
  - [Brave](https://brave.com/features/)
  - [Chrome](https://www.google.com/chrome/browser-features/)
  - [Edge](https://www.microsoft.com/en-us/edge/features)
  - [Firefox**](https://www.mozilla.org/en-US/firefox/features/)
  - [Vivaldi](https://vivaldi.com/)
- Office Suites
  - [Libre Office**](https://www.libreoffice.org/discover/libreoffice/)
  - [Only Office](https://www.onlyoffice.com/desktop.aspx)
  - [Open Office](https://www.openoffice.org/why/index.html)
- Email
  - [Thunderbird](https://www.thunderbird.net/en-US/features/)
- Security
  - [Authy**](https://authy.com/)
  - [Bitwarden**](https://bitwarden.com/)
  - [Cryptomator](https://cryptomator.org/)
  - [KeePass](https://keepass.info/)
  - [LastPass](https://www.lastpass.com/)
  - [VeraCrypt](https://www.veracrypt.fr/en/Home.html)
- Gaming
  - [Epic Launcher](https://www.epicgames.com/store/)
  - [GOG Galaxy](https://www.gog.com/)
  - [Steam**](https://store.steampowered.com/)
- Group Chat
  - [Discord**](https://discord.com/)
  - [Skype](https://www.skype.com/en/features/)
  - [Teams](https://www.microsoft.com/en-us/microsoft-teams/group-chat-software)
  - [Zoom](https://zoom.us/)
- Utilities
  - [7-Zip](https://www.7-zip.org/)
  - [Notepad++](https://notepad-plus-plus.org/)
  - [OBS Studio](https://obsproject.com/)
  - [PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/)
  - [Windows PowerToys](https://docs.microsoft.com/en-us/windows/powertoys/)
  - [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/)
- Coding
  - [Git**](https://git-scm.com/)
  - [PowerShell 7](https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-70)
  - [Python 3](https://www.python.org/)
  - [Visual Studio 2022 Community](https://visualstudio.microsoft.com/vs/community/)
  - [Visual Studio Code**](https://code.visualstudio.com/docs)
