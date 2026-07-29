[Setup]
AppName=Bar Węgielstwo Pro
AppVersion=1.0.0
AppPublisher=Bar Węgielstwo
DefaultDirName={autopf}\BarWegielstwo Pro
DefaultGroupName=Bar Węgielstwo Pro
UninstallDisplayIcon={app}\bar_wegielstwo_pro.exe
OutputBaseFilename=BarWegielstwoPro-Setup-1.0.0
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64

[Files]
; Order (Kiosk)
Source: "{#ProjectDir}\bar_wegielstwo_order\build\windows\x64\runner\Release\bar_wegielstwo_order.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectDir}\bar_wegielstwo_order\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#ProjectDir}\bar_wegielstwo_order\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; Board (Tablica)
Source: "{#ProjectDir}\bar_wegielstwo_board\build\windows\x64\runner\Release\bar_wegielstwo_board.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectDir}\bar_wegielstwo_board\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#ProjectDir}\bar_wegielstwo_board\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; Admin (Zarzządzanie)
Source: "{#ProjectDir}\bar_wegielstwo_admin\build\windows\x64\runner\Release\bar_wegielstwo_admin.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectDir}\bar_wegielstwo_admin\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#ProjectDir}\bar_wegielstwo_admin\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; Pro (Launcher)
Source: "{#ProjectDir}\bar_wegielstwo_pro\build\windows\x64\runner\Release\bar_wegielstwo_pro.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#ProjectDir}\bar_wegielstwo_pro\build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#ProjectDir}\bar_wegielstwo_pro\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Bar Węgielstwo Pro"; Filename: "{app}\bar_wegielstwo_pro.exe"
Name: "{group}\Zamów (Kiosk)"; Filename: "{app}\bar_wegielstwo_order.exe"
Name: "{group}\Tablica"; Filename: "{app}\bar_wegielstwo_board.exe"
Name: "{group}\Zarządzanie"; Filename: "{app}\bar_wegielstwo_admin.exe"
Name: "{autodesktop}\Bar Węgielstwo Pro"; Filename: "{app}\bar_wegielstwo_pro.exe"

[Run]
Filename: "{app}\bar_wegielstwo_pro.exe"; Description: "Uruchom Bar Węgielstwo Pro"; Flags: nowait postinstall skipifsilent