; ---------------------------------------------------------------------------
; WinDjView 2.1 - Ukrainian language pack installer (NSIS 3.x, Unicode)
; Installs WinDjViewUA.dll next to an existing WinDjView 2.1 installation.
; Build:  makensis WinDjView-UA-LangPack.nsi      (run tools/build.sh first: it builds the DLLs into build\x64, build\x86)
; Needs:  ${DLL_DIR_X64}\WinDjViewUA.dll, ${DLL_DIR_X86}\WinDjViewUA.dll, ..\windjview\license
;         override the DLL folders with  makensis /DDLL_DIR_X64=... /DDLL_DIR_X86=... WinDjView-UA-LangPack.nsi
; ---------------------------------------------------------------------------
Unicode true
!define APP_NAME     "WinDjView"
!define APP_VERSION  "2.1"
!define PACK_NAME    "WinDjView - українська локалізація"
!define PACK_VERSION "2.1.1"
!define UNINST_KEY   "Software\Microsoft\Windows\CurrentVersion\Uninstall\WinDjView-Ukrainian"

Name "${PACK_NAME}"
!ifndef DLL_DIR_X64
  !define DLL_DIR_X64 "build\x64"
!endif
!ifndef DLL_DIR_X86
  !define DLL_DIR_X86 "build\x86"
!endif
OutFile "WinDjView-${APP_VERSION}-Ukrainian-Setup.exe"
SetCompressor /SOLID lzma
RequestExecutionLevel admin
InstallDir "__auto__"            ; sentinel: replaced in .onInit unless /D=... was given
ShowInstDetails show
ShowUnInstDetails show

VIProductVersion "${PACK_VERSION}.0"
VIAddVersionKey "ProductName"     "WinDjView Ukrainian language pack"
VIAddVersionKey "ProductVersion"  "${PACK_VERSION}"
VIAddVersionKey "FileVersion"     "${PACK_VERSION}"
VIAddVersionKey "FileDescription" "WinDjView Ukrainian language pack installer"
VIAddVersionKey "LegalCopyright"  "GNU GPL v2 or later"
VIAddVersionKey "Comments"        "For WinDjView ${APP_VERSION}"

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"
!include "FileFunc.nsh"

!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_NOAUTOCLOSE

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\windjview\license"
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE DirLeave
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_TEXT "Українську мову встановлено.$\r$\n$\r$\nЗапустіть WinDjView і виберіть меню «Language» → «Українська»."
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "Ukrainian"
!insertmacro MUI_LANGUAGE "English"

LangString MSG_NO_APP ${LANG_UKRAINIAN} "У вибраній папці не знайдено WinDjView.exe.$\r$\nСпочатку встановіть WinDjView ${APP_VERSION}, потім виберіть його папку."
LangString MSG_NO_APP ${LANG_ENGLISH}   "WinDjView.exe was not found in the selected folder.$\r$\nInstall WinDjView ${APP_VERSION} first, then select its folder."
LangString MSG_VERSION ${LANG_UKRAINIAN} "Ця локалізація призначена для WinDjView ${APP_VERSION}, а в папці знайдено версію $0.$\r$\nПрограма не завантажить мову з іншої версії. Продовжити все одно?"
LangString MSG_VERSION ${LANG_ENGLISH}   "This language pack is built for WinDjView ${APP_VERSION}, but version $0 was found.$\r$\nThe program will not load a language DLL of another version. Continue anyway?"

Var ExeMachine   ; 0x014c = x86, 0x8664 = x64

Function .onInit
  ${If} ${RunningX64}
    SetRegView 64
  ${EndIf}
  ${If} $INSTDIR != "__auto__"
    Return                         ; folder given on the command line (/D=...)
  ${EndIf}
  ; default folder: first existing WinDjView installation
  StrCpy $INSTDIR ""
  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\WinDjView" "InstallLocation"
  ${If} $0 != ""
  ${AndIf} ${FileExists} "$0\WinDjView.exe"
    StrCpy $INSTDIR $0
  ${EndIf}
  ${If} $INSTDIR == ""
  ${AndIf} ${FileExists} "$PROGRAMFILES64\WinDjView\WinDjView.exe"
    StrCpy $INSTDIR "$PROGRAMFILES64\WinDjView"
  ${EndIf}
  ${If} $INSTDIR == ""
  ${AndIf} ${FileExists} "$PROGRAMFILES32\WinDjView\WinDjView.exe"
    StrCpy $INSTDIR "$PROGRAMFILES32\WinDjView"
  ${EndIf}
  ${If} $INSTDIR == ""
    StrCpy $INSTDIR "$PROGRAMFILES\WinDjView"
  ${EndIf}
FunctionEnd

; read IMAGE_FILE_HEADER.Machine of WinDjView.exe -> $ExeMachine
Function ReadMachine
  StrCpy $ExeMachine 0
  ClearErrors
  FileOpen $1 "$INSTDIR\WinDjView.exe" r
  IfErrors done
  FileSeek $1 0x3C SET
  FileReadByte $1 $2
  FileReadByte $1 $3
  IntOp $3 $3 << 8
  IntOp $2 $2 + $3                 ; e_lfanew (low word is enough)
  IntOp $2 $2 + 4
  FileSeek $1 $2 SET
  FileReadByte $1 $2
  FileReadByte $1 $3
  IntOp $3 $3 << 8
  IntOp $ExeMachine $2 + $3
  FileClose $1
  done:
FunctionEnd

Function DirLeave
  ${IfNot} ${FileExists} "$INSTDIR\WinDjView.exe"
    MessageBox MB_ICONEXCLAMATION|MB_OK "$(MSG_NO_APP)"
    Abort
  ${EndIf}
  ${GetFileVersion} "$INSTDIR\WinDjView.exe" $0
  ${If} $0 != ""
    StrCpy $2 $0 3                 ; "2.1" from "2.1.0.0"
    ${If} $2 != "${APP_VERSION}"
      MessageBox MB_ICONQUESTION|MB_YESNO "$(MSG_VERSION)" IDYES +2
      Abort
    ${EndIf}
  ${EndIf}
FunctionEnd

Section "Install"
  SetOutPath "$INSTDIR"
  SetOverwrite on
  Call ReadMachine
  ${If} $ExeMachine = 0x8664
    DetailPrint "WinDjView x64 detected"
    File "/oname=WinDjViewUA.dll" "${DLL_DIR_X64}\WinDjViewUA.dll"
  ${Else}
    DetailPrint "WinDjView x86 detected"
    File "/oname=WinDjViewUA.dll" "${DLL_DIR_X86}\WinDjViewUA.dll"
  ${EndIf}
  WriteUninstaller "$INSTDIR\uninstall-ua.exe"

  WriteRegStr   HKLM "${UNINST_KEY}" "DisplayName"     "${PACK_NAME}"
  WriteRegStr   HKLM "${UNINST_KEY}" "DisplayVersion"  "${PACK_VERSION}"
  WriteRegStr   HKLM "${UNINST_KEY}" "Publisher"       "WinDjView localization"
  WriteRegStr   HKLM "${UNINST_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr   HKLM "${UNINST_KEY}" "UninstallString" '"$INSTDIR\uninstall-ua.exe"'
  WriteRegDWORD HKLM "${UNINST_KEY}" "NoModify" 1
  WriteRegDWORD HKLM "${UNINST_KEY}" "NoRepair" 1
SectionEnd

Function un.onInit
  ${If} ${RunningX64}
    SetRegView 64
  ${EndIf}
FunctionEnd

Section "Uninstall"
  Delete "$INSTDIR\WinDjViewUA.dll"
  Delete "$INSTDIR\uninstall-ua.exe"
  DeleteRegKey HKLM "${UNINST_KEY}"
SectionEnd
