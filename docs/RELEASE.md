# Випуск нової версії WinDjView-UA

Програма (з версії 2.1.2) перевіряє оновлення за адресою
`https://raw.githubusercontent.com/gennadijkhimij/WinDjView-UA/main/version.txt`
(щотижня і з меню «Довідка → Перевірити оновлення»). Якщо номер там більший за її власний,
вона пропонує відкрити https://github.com/gennadijkhimij/WinDjView-UA/releases/latest.
Тому **`version.txt` у корені репозиторію піднімають останнім**, коли реліз з інсталятором уже опубліковано.
(Версія 2.1.1 перевіряла SourceForge — проєкт там видалено.)

## Кроки

1. **Номер версії** (наприклад, 2.1.3) — однаковий у двох файлах, інакше мовна DLL не завантажиться:
   - `windjview/WinDjView.rc`: `FILEVERSION`, `PRODUCTVERSION`, `"FileVersion"`, `"ProductVersion"`, `IDS_CURRENT_VERSION`;
   - `windjview/Languages/Ukrainian/WinDjViewUA.rc`: те саме.
   Додати запис у `windjview/changes.txt`; за потреби — у `installer/NOTICE.txt`.
2. **Збірка** (Windows, Visual Studio 2026 з C++ MFC, NSIS 3):
   ```
   powershell -ExecutionPolicy Bypass -File installer\build-windows.ps1
   ```
   Результат: `installer/dist/WinDjView-UA-<версія>-Setup.exe`, `SHA256SUMS.txt`.
3. **Перевірка безпеки й роботи:**
   - встановити (`/S` — тихо), запустити, «Про програму», «Перевірити оновлення», відкрити кілька DjVu;
   - у властивостях exe: ProductName `WinDjView-UA`, версія — нова;
   - захисти не вимкнено (PowerShell + Python `pefile`): DllCharacteristics містить ASLR, DEP, CFG,
     `DependentLoadFlags` = `0x800`;
   - у процесі програми `WinDjViewUA.dll` не з'являється серед модулів (завантажена лише як ресурси);
   - якщо змінювалась `libdjvu` — переглянути [DJVULIBRE-BACKPORTS.md](DJVULIBRE-BACKPORTS.md) і перевірити
     нові виправлення безпеки DjVuLibre (https://sourceforge.net/p/djvu/djvulibre-git/).
4. **GitHub**: коміт, тег і push — GitHub Actions збере інсталятор і створить реліз з ним і `SHA256SUMS.txt`:
   ```
   git tag -a v2.1.3 -m "WinDjView-UA 2.1.3"
   git push origin main v2.1.3
   ```
   Інсталятор для поширення — **з релізу GitHub** (зібраний з відкритого коду, його контрольна сума — у релізі).
5. **Оголосити оновлення**: у `version.txt` (корінь репозиторію) записати новий номер, коміт і push у `main`.
   Встановлені копії запропонують оновлення протягом тижня.
6. **Підпис** (коли SignPath Foundation схвалить заявку): запит на підпис у SignPath для збірки тегу,
   ручне схвалення — див. [CODE_SIGNING_POLICY.md](CODE_SIGNING_POLICY.md).

## Тихе оновлення

`WinDjView-UA-<версія>-Setup.exe /S` ставить нову версію в ту саму теку поверх старої;
налаштування (`HKCU\Software\WinDjView-UA`) зберігаються.

## SourceForge (якщо обліковий запис відновлять)

`installer/publish-sourceforge.sh <версія> [--announce]` — викладає інсталятор у Files проєкту `windjview-ua`
(ключ `~/.ssh/sourceforge_ed25519`). Перевірка оновлень у 2.1.2+ від SourceForge не залежить.
