# Випуск нової версії WinDjView-UA

Програма перевіряє оновлення за адресою `https://windjview-ua.sourceforge.io/version.txt`
(щотижня і з меню «Довідка → Перевірити оновлення»). Якщо номер там більший за її власний,
вона пропонує відкрити https://sourceforge.net/projects/windjview-ua/files/.
Тому **`version.txt` піднімають останнім**, коли інсталятор уже викладено.

## Кроки

1. **Номер версії** (наприклад, 2.1.2) — однаковий у п'яти місцях, інакше мовна DLL не завантажиться:
   - `windjview/WinDjView.rc`: `FILEVERSION`, `PRODUCTVERSION`, `"FileVersion"`, `"ProductVersion"`, `IDS_CURRENT_VERSION`;
   - `windjview/Languages/Ukrainian/WinDjViewUA.rc`: те саме;
   - `sourceforge/htdocs/version.txt`.
   Додати запис у `windjview/changes.txt`.
2. **Збірка** (Windows, Visual Studio 2026 з C++ MFC, NSIS 3):
   ```
   powershell -ExecutionPolicy Bypass -File installer\build-windows.ps1
   ```
   Результат: `installer/dist/WinDjView-UA-<версія>-Setup.exe`, `SHA256SUMS.txt`.
3. **Перевірка**: встановити (`/S` — тихо), запустити, «Про програму», «Перевірити оновлення».
4. **GitHub**: коміт, тег і push — GitHub Actions збере інсталятор і додасть його до релізу:
   ```
   git tag v2.1.2
   git push origin main v2.1.2
   ```
5. **SourceForge** (з цього комп'ютера, Git Bash; ключ `~/.ssh/sourceforge_ed25519`):
   ```
   installer/publish-sourceforge.sh 2.1.2            # лише файли
   installer/publish-sourceforge.sh 2.1.2 --announce # + version.txt: копії почнуть пропонувати оновлення
   ```
   На SourceForge у Files → тека версії → інсталятор → «i» → **Default download for Windows**.

## Тихе оновлення

`WinDjView-UA-<версія>-Setup.exe /S` ставить нову версію в ту саму теку поверх старої;
налаштування (`HKCU\Software\WinDjView-UA`) зберігаються.
