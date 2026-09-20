; ---------------------------------------------------------------------------
; WinDjView 2.1 - full installer (NSIS 3.x, Unicode). Interface: Ukrainian / English.
; Languages installed: built-in English + Ukrainian (WinDjViewUA.dll). No Russian.
;
; Build:  makensis WinDjView-Setup.nsi
;
; Input (paths relative to this file, i.e. to the installer\ folder of the repository):
;   bin\x64\WinDjView.exe        <- required: official 64-bit WinDjView 2.1 (not stored in git)
;   bin\x86\WinDjView.exe        <- optional: if present at build time, 32-bit Windows is supported too
;   ${DLL_DIR_X64}\WinDjViewUA.dll, ${DLL_DIR_X86}\WinDjViewUA.dll
;                                <- language DLLs; default build\x64, build\x86 (made by tools/build.sh)
;                                   override:  makensis /DDLL_DIR_X64=C:\path\x64 /DDLL_DIR_X86=C:\path\x86 ...
;   ..\windjview\license, ..\windjview\changes.txt   <- taken from the repository
;   NOTICE.txt                   <- optional (notice about modifications), packed if present
; Silent install:  WinDjView-2.1-Setup.exe /S   [/D=C:\Folder]
; ---------------------------------------------------------------------------
Unicode true
!define APP_NAME    "WinDjView"
!define APP_VERSION "2.1"
!define UNINST_KEY  "Software\Microsoft\Windows\CurrentVersion\Uninstall\WinDjView"
!define APP_KEY     "Software\Microsoft\Windows\CurrentVersion\App Paths\WinDjView.exe"

!ifndef DLL_DIR_X64
  !define DLL_DIR_X64 "build\x64"
!endif
!ifndef DLL_DIR_X86
  !define DLL_DIR_X86 "build\x86"
!endif
!if /FileExists "bin\x86\WinDjView.exe"
  !define HAVE_X86
!endif
!if /FileExists "NOTICE.txt"
  !define HAVE_NOTICE
!endif

Name "${APP_NAME} ${APP_VERSION}"
OutFile "WinDjView-${APP_VERSION}-Setup.exe"
SetCompressor /SOLID lzma
RequestExecutionLevel admin
InstallDir "__auto__"
ShowInstDetails show

VIProductVersion "${APP_VERSION}.0.0"
VIAddVersionKey "ProductName"     "${APP_NAME}"
VIAddVersionKey "ProductVersion"  "${APP_VERSION}"
VIAddVersionKey "FileVersion"     "${APP_VERSION}"
VIAddVersionKey "FileDescription" "${APP_NAME} setup (Ukrainian/English)"
VIAddVersionKey "LegalCopyright"  "Copyright (C) 2004-2015 Andrew Zhezherun. GNU GPL v2 or later"

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

LangString SEC_MAIN  ${LANG_UKRAINIAN} "Програма WinDjView та українська мова інтерфейсу"
LangString SEC_MAIN  ${LANG_ENGLISH}   "WinDjView and Ukrainian interface language"
LangString SEC_MENU  ${LANG_UKRAINIAN} "Ярлики в меню «Пуск»"
LangString SEC_MENU  ${LANG_ENGLISH}   "Start Menu shortcuts"
LangString SEC_DESK  ${LANG_UKRAINIAN} "Ярлик на робочому столі"
LangString SEC_DESK  ${LANG_ENGLISH}   "Desktop shortcut"
LangString SEC_LANG  ${LANG_UKRAINIAN} "Українська мова інтерфейсу за замовчуванням (для поточного користувача)"
LangString SEC_LANG  ${LANG_ENGLISH}   "Ukrainian interface by default (current user)"
LangString MSG_NO32  ${LANG_UKRAINIAN} "Цей інсталятор містить лише 64-бітну версію WinDjView, а ця Windows 32-бітна."
LangString MSG_NO32  ${LANG_ENGLISH}   "This installer contains only the 64-bit build of WinDjView, and this Windows is 32-bit."

Function .onInit
!ifndef HAVE_X86
  ${IfNot} ${RunningX64}
    MessageBox MB_OK|MB_ICONSTOP "$(MSG_NO32)"
    Abort
  ${EndIf}
!endif
  ${If} ${RunningX64}
    SetRegView 64
  ${EndIf}
  ; choose the folder only when /D=... was not given
  ${If} $INSTDIR == "__auto__"
    ReadRegStr $0 HKLM "${UNINST_KEY}" "InstallLocation"
    ${If} $0 != ""
      StrCpy $INSTDIR $0
    ${ElseIf} ${RunningX64}
      StrCpy $INSTDIR "$PROGRAMFILES64\WinDjView"
    ${Else}
      StrCpy $INSTDIR "$PROGRAMFILES32\WinDjView"
    ${EndIf}
  ${EndIf}
FunctionEnd

Section "$(SEC_MAIN)" SecMain
  SectionIn RO
  SetOutPath "$INSTDIR"
  SetOverwrite on
  ${If} ${RunningX64}
    File "bin\x64\WinDjView.exe"
    File "${DLL_DIR_X64}\WinDjViewUA.dll"
  ${Else}
!ifdef HAVE_X86
    File "bin\x86\WinDjView.exe"
    File "${DLL_DIR_X86}\WinDjViewUA.dll"
!endif
  ${EndIf}
  File "/oname=license.txt" "..\windjview\license"
  File "..\windjview\changes.txt"
!ifdef HAVE_NOTICE
  File "NOTICE.txt"
!endif
  WriteUninstaller "$INSTDIR\uninstall.exe"

  WriteRegStr   HKLM "${APP_KEY}" "" "$INSTDIR\WinDjView.exe"
  WriteRegStr   HKLM "${UNINST_KEY}" "DisplayName"     "${APP_NAME} ${APP_VERSION}"
  WriteRegStr   HKLM "${UNINST_KEY}" "DisplayVersion"  "${APP_VERSION}"
  WriteRegStr   HKLM "${UNINST_KEY}" "Publisher"       "Andrew Zhezherun"
  WriteRegStr   HKLM "${UNINST_KEY}" "DisplayIcon"     "$INSTDIR\WinDjView.exe"
  WriteRegStr   HKLM "${UNINST_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr   HKLM "${UNINST_KEY}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "${UNINST_KEY}" "NoModify" 1
  WriteRegDWORD HKLM "${UNINST_KEY}" "NoRepair" 1
SectionEnd

Section "$(SEC_MENU)" SecMenu
  SetOutPath "$INSTDIR"
  CreateDirectory "$SMPROGRAMS\WinDjView"
  CreateShortcut  "$SMPROGRAMS\WinDjView\WinDjView.lnk" "$INSTDIR\WinDjView.exe"
  CreateShortcut  "$SMPROGRAMS\WinDjView\Uninstall.lnk" "$INSTDIR\uninstall.exe"
SectionEnd

Section "$(SEC_LANG)" SecLang
  ; only if the user has not chosen a language yet (0x422 = 1058 = Ukrainian)
  ClearErrors
  ReadRegDWORD $0 HKCU "Software\Andrew Zhezherun\WinDjView\Settings" "language"
  ${If} ${Errors}
    WriteRegDWORD HKCU "Software\Andrew Zhezherun\WinDjView\Settings" "language" 1058
  ${EndIf}
SectionEnd

Section /o "$(SEC_DESK)" SecDesk
  SetOutPath "$INSTDIR"
  CreateShortcut "$DESKTOP\WinDjView.lnk" "$INSTDIR\WinDjView.exe"
SectionEnd

Section "Uninstall"
  Delete "$INSTDIR\WinDjView.exe"
  Delete "$INSTDIR\WinDjViewUA.dll"
  Delete "$INSTDIR\license.txt"
  Delete "$INSTDIR\changes.txt"
  Delete "$INSTDIR\NOTICE.txt"
  Delete "$INSTDIR\uninstall.exe"
  RMDir  "$INSTDIR"
  Delete "$SMPROGRAMS\WinDjView\WinDjView.lnk"
  Delete "$SMPROGRAMS\WinDjView\Uninstall.lnk"
  RMDir  "$SMPROGRAMS\WinDjView"
  Delete "$DESKTOP\WinDjView.lnk"
  DeleteRegKey HKLM "${UNINST_KEY}"
  DeleteRegKey HKLM "${APP_KEY}"
SectionEnd

Function un.onInit
  ${If} ${RunningX64}
    SetRegView 64
  ${EndIf}
FunctionEnd
