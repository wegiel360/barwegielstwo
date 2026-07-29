[Setup]
AppName=Bar Wegielstwo Pro
AppVersion=2.0.0
AppPublisher=Bar Wegielstwo
DefaultDirName={autopf}\BarWegielstwo Pro
DefaultGroupName=Bar Wegielstwo Pro
UninstallDisplayIcon={app}\bar_wegielstwo_pro.exe
OutputBaseFilename=BarWegielstwoPro-Setup-v2.0.0
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64compatible
SetupLogging=yes

[Files]
; === Bar Wegielstwo Pro (Launcher) ===
Source: "{#RootDir}\bar_wegielstwo_pro\build\windows\x64\runner\Release\bar_wegielstwo_pro.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#RootDir}\bar_wegielstwo_pro\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#RootDir}\bar_wegielstwo_pro\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; === Bar Wegielstwo Order (Kiosk) ===
Source: "{#RootDir}\bar_wegielstwo_order\build\windows\x64\runner\Release\bar_wegielstwo_order.exe"; DestDir: "{app}\order"; Flags: ignoreversion
Source: "{#RootDir}\bar_wegielstwo_order\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}\order"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#RootDir}\bar_wegielstwo_order\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\order\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; === Bar Wegielstwo Board (Tablica) ===
Source: "{#RootDir}\bar_wegielstwo_board\build\windows\x64\runner\Release\bar_wegielstwo_board.exe"; DestDir: "{app}\board"; Flags: ignoreversion
Source: "{#RootDir}\bar_wegielstwo_board\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}\board"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#RootDir}\bar_wegielstwo_board\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\board\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; === Bar Wegielstwo Admin (Zarzadzanie) ===
Source: "{#RootDir}\bar_wegielstwo_admin\build\windows\x64\runner\Release\bar_wegielstwo_admin.exe"; DestDir: "{app}\admin"; Flags: ignoreversion
Source: "{#RootDir}\bar_wegielstwo_admin\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}\admin"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#RootDir}\bar_wegielstwo_admin\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\admin\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Bar Wegielstwo Pro"; Filename: "{app}\bar_wegielstwo_pro.exe"
Name: "{group}\Zamow (Kiosk)"; Filename: "{app}\order\bar_wegielstwo_order.exe"
Name: "{group}\Tablica"; Filename: "{app}\board\bar_wegielstwo_board.exe"
Name: "{group}\Zarzadzanie"; Filename: "{app}\admin\bar_wegielstwo_admin.exe"
Name: "{autodesktop}\Bar Wegielstwo Pro"; Filename: "{app}\bar_wegielstwo_pro.exe"

[Run]
Filename: "{app}\bar_wegielstwo_pro.exe"; Description: "Uruchom Bar Wegielstwo Pro"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"