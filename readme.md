# Startup Script

A Powershell startup script

## Description

A PowerShell script which starts with Windows. The script synchronizes the time with a time server, sets the playback and recording audio sources, and cleans up the %temp% folder and Recycling Bin.


## Getting Started

### Dependencies

* [Powershell 7](https://github.com/PowerShell/PowerShell/releases) 
* Windows 11 (Windows 10 not tested)

### Setup

* Download the script.
* Edit the script and set the global variables.


### Runnig Script on startup

* Open Task Scheduler as Administrator.
* Create a task in the Library.
* Set the task name.
* Set SYSTEM User as the runner.
* Go to the Triggers tab and create a trigger.
* Choose At Startup.
* Go to the Actions tab and create an action.
* For the program, choose PowerShell (C:\Program Files\PowerShell\7\pwsh.exe).
* The argument is -File "/Path/to/script.ps1".

## Authors

Contributors names and contact info

Maximilian Lanski [@sirmpixx](https://www.instagram.com/sirmpixx/?hl=de)

## Version History

* Version 1.0: First Creation
* Version 2.0: Complete rewrite of the script

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Acknowledgments

Inspiration, code snippets, etc.
* [README-Template](https://gist.github.com/DomPizzie/7a5ff55ffa9081f2de27c315f5018afc)
* [AudioDeviceCmdlets](https://github.com/frgnca/AudioDeviceCmdlets)
