; ---------------------------------------------------------------------------
; WinDjView-UA - full installer (NSIS 3.x, Unicode). Interface: Ukrainian / English.
; WinDjView-UA is a modified version of WinDjView built from this repository:
; built-in English + Ukrainian (WinDjViewUA.dll), x64 and x86. No other languages.
;
; Build (after building windjview\WinDjView.15.sln, Release x64 and Win32):
;   makensis WinDjView-Setup.nsi            or   installer\build-windows.ps1
;
; Input (paths relative to this file, i.e. to the installer\ folder of the repository):
;   ${BIN_X64}\WinDjView.exe, ${BIN_X86}\WinDjView.exe
;       default ..\windjview\Release_x64 and ..\windjview\Release
;   ${DLL_X64}\WinDjViewUA.dll, ${DLL_X86}\WinDjViewUA.dll
;       default ..\windjview\Languages\Ukrainian\Release_x64 and ...\Release
;   override:  makensis /DBIN_X64=C:\path /DDLL_X64=C:\path ...
;   ..\windjview\license, ..\windjview\changes.txt, NOTICE.txt
;
; Install folder, Start menu folder and the uninstall entry are named WinDjView-UA, so the official
; WinDjView can stay installed side by side; the program keeps its settings in HKCU\Software\WinDjView-UA.
; One installer for both: installs the 64-bit build on 64-bit Windows, the 32-bit build otherwise.
; Silent install / update:  WinDjView-UA-<version>-Setup-x64-x86.exe /S   [/D=C:\Folder]
; ---------------------------------------------------------------------------
Unicode true
!define APP_NAME    "WinDjView-UA"
!ifndef APP_VERSION
  !define APP_VERSION "2.1.1"
!endif
!define UNINST_KEY  "Software\Microsoft\Windows\CurrentVersion\Uninstall\WinDjView-UA"
!define APP_KEY     "Software\Microsoft\Windows\CurrentVersion\App Paths\WinDjView.exe"
!define PUBLISHER   "Gennadij Khimij (based on WinDjView by Andrew Zhezherun)"
!define HOMEPAGE    "https://sourceforge.net/projects/windjview-ua/"

!ifndef BIN_X64
  !define BIN_X64 "..\windjview\Release_x64"
!endif
!ifndef BIN_X86
  !define BIN_X86 "..\windjview\Release"
!endif
!ifndef DLL_X64
  !define DLL_X64 "..\windjview\Languages\Ukrainian\Release_x64"
!endif
!ifndef DLL_X86
  !define DLL_X86 "..\windjview\Languages\Ukrainian\Release"
!endif

Name "${APP_NAME} ${APP_VERSION}"
OutFile "${APP_NAME}-${APP_VERSION}-Setup-x64-x86.exe"
SetCompressor /SOLID lzma
RequestExecutionLevel admin
InstallDir "__auto__"
ShowInstDetails show

VIProductVersion "${APP_VERSION}.0"
VIAddVersionKey "ProductName"     "${APP_NAME}"
VIAddVersionKey "ProductVersion"  "${APP_VERSION}"
VIAddVersionKey "FileVersion"     "${APP_VERSION}"
VIAddVersionKey "FileDescription" "${APP_NAME} setup"
VIAddVersionKey "CompanyName"     "Gennadij Khimij"
VIAddVersionKey "LegalCopyright"  "(C) 2026 Gennadij Khimij; WinDjView (C) 2004-2015 Andrew Zhezherun. GNU GPL v2 or later"

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"

!define MUI_ABORTWARNING
!define MUI_ICON   "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\windjview\license"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\WinDjView.exe"
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "Ukrainian"
!insertmacro MUI_LANGUAGE "English"

LangString SEC_MAIN  ${LANG_UKRAINIAN} "Програма WinDjView-UA (українська та англійська мови)"
LangString SEC_MAIN  ${LANG_ENGLISH}   "WinDjView-UA (Ukrainian and English interface)"
LangString SEC_MENU  ${LANG_UKRAINIAN} "Ярлики в меню «Пуск»"
LangString SEC_MENU  ${LANG_ENGLISH}   "Start Menu shortcuts"
LangString SEC_DESK  ${LANG_UKRAINIAN} "Ярлик на робочому столі"
LangString SEC_DESK  ${LANG_ENGLISH}   "Desktop shortcut"
LangString MSG_X64   ${LANG_UKRAINIAN} "Встановлюється 64-бітна версія WinDjView-UA"
LangString MSG_X64   ${LANG_ENGLISH}   "Installing the 64-bit version of WinDjView-UA"
LangString MSG_X86   ${LANG_UKRAINIAN} "Встановлюється 32-бітна версія WinDjView-UA"
LangString MSG_X86   ${LANG_ENGLISH}   "Installing the 32-bit version of WinDjView-UA"

Function .onInit
  SetShellVarContext all          ; per-machine install: shortcuts for all users
  ${If} ${RunningX64}
    SetRegView 64
  ${EndIf}
  ; choose the folder only when /D=... was not given; an update goes to the existing folder
  ${If} $INSTDIR == "__auto__"
    ReadRegStr $0 HKLM "${UNINST_KEY}" "InstallLocation"
    ${If} $0 != ""
      StrCpy $INSTDIR $0
    ${ElseIf} ${RunningX64}
      StrCpy $INSTDIR "$PROGRAMFILES64\WinDjView-UA"
    ${Else}
      StrCpy $INSTDIR "$PROGRAMFILES32\WinDjView-UA"
    ${EndIf}
  ${EndIf}
FunctionEnd

Section "$(SEC_MAIN)" SecMain
  SectionIn RO
  SetOutPath "$INSTDIR"
  SetOverwrite on
  ${If} ${RunningX64}
    DetailPrint "$(MSG_X64)"
    File "${BIN_X64}\WinDjView.exe"
    File "${DLL_X64}\WinDjViewUA.dll"
  ${Else}
    DetailPrint "$(MSG_X86)"
    File "${BIN_X86}\WinDjView.exe"
    File "${DLL_X86}\WinDjViewUA.dll"
  ${EndIf}
  File "/oname=license.txt" "..\windjview\license"
  File "..\windjview\changes.txt"
  File "NOTICE.txt"
  WriteUninstaller "$INSTDIR\uninstall.exe"

  WriteRegStr   HKLM "${APP_KEY}" "" "$INSTDIR\WinDjView.exe"
  WriteRegStr   HKLM "${UNINST_KEY}" "DisplayName"     "${APP_NAME} ${APP_VERSION}"
  WriteRegStr   HKLM "${UNINST_KEY}" "DisplayVersion"  "${APP_VERSION}"
  WriteRegStr   HKLM "${UNINST_KEY}" "Publisher"       "${PUBLISHER}"
  WriteRegStr   HKLM "${UNINST_KEY}" "URLInfoAbout"    "${HOMEPAGE}"
  WriteRegStr   HKLM "${UNINST_KEY}" "DisplayIcon"     "$INSTDIR\WinDjView.exe"
  WriteRegStr   HKLM "${UNINST_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr   HKLM "${UNINST_KEY}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegStr   HKLM "${UNINST_KEY}" "QuietUninstallString" '"$INSTDIR\uninstall.exe" /S'
  WriteRegDWORD HKLM "${UNINST_KEY}" "NoModify" 1
  WriteRegDWORD HKLM "${UNINST_KEY}" "NoRepair" 1
SectionEnd

Section "$(SEC_MENU)" SecMenu
  SetOutPath "$INSTDIR"
  CreateDirectory "$SMPROGRAMS\WinDjView-UA"
  CreateShortcut  "$SMPROGRAMS\WinDjView-UA\WinDjView-UA.lnk" "$INSTDIR\WinDjView.exe"
  CreateShortcut  "$SMPROGRAMS\WinDjView-UA\Uninstall.lnk" "$INSTDIR\uninstall.exe"
SectionEnd

Section /o "$(SEC_DESK)" SecDesk
  SetOutPath "$INSTDIR"
  CreateShortcut "$DESKTOP\WinDjView-UA.lnk" "$INSTDIR\WinDjView.exe"
SectionEnd

Section "Uninstall"
  Delete "$INSTDIR\WinDjView.exe"
  Delete "$INSTDIR\WinDjViewUA.dll"
  Delete "$INSTDIR\license.txt"
  Delete "$INSTDIR\changes.txt"
  Delete "$INSTDIR\NOTICE.txt"
  Delete "$INSTDIR\uninstall.exe"
  RMDir  "$INSTDIR"
  Delete "$SMPROGRAMS\WinDjView-UA\WinDjView-UA.lnk"
  Delete "$SMPROGRAMS\WinDjView-UA\Uninstall.lnk"
  RMDir  "$SMPROGRAMS\WinDjView-UA"
  Delete "$DESKTOP\WinDjView-UA.lnk"
  DeleteRegKey HKLM "${UNINST_KEY}"
  ; App Paths is shared with the official WinDjView: remove it only if it points to this installation
  ReadRegStr $0 HKLM "${APP_KEY}" ""
  ${If} $0 == "$INSTDIR\WinDjView.exe"
    DeleteRegKey HKLM "${APP_KEY}"
  ${EndIf}
SectionEnd

Function un.onInit
  SetShellVarContext all
  ${If} ${RunningX64}
    SetRegView 64
  ${EndIf}
FunctionEnd
