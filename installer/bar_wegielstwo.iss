[Setup]
AppName=Bar Wegielstwo Board
AppVersion=0.0.2-alpha
AppPublisher=Bar Wegielstwo
DefaultDirName={autopf}\BarWegielstwo Board
DefaultGroupName=Bar Wegielstwo
OutputBaseFilename=BarWegielstwo-Board-Setup-v0.0.2-alpha
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64compatible
SetupLogging=yes
UninstallDisplayIcon={app}\bar_wegielstwo_board.exe

[Files]
Source: "{#RootDir}\bar_wegielstwo_board\build\windows\x64\runner\Release\bar_wegielstwo_board.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#RootDir}\bar_wegielstwo_board\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#RootDir}\bar_wegielstwo_board\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Tablica"; Filename: "{app}\bar_wegielstwo_board.exe"
Name: "{autodesktop}\Bar Wegielstwo Board"; Filename: "{app}\bar_wegielstwo_board.exe"

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
