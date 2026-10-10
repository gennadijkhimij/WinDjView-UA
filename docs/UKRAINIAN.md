# WinDjView-UA — технічний опис

WinDjView-UA — модифікована версія WinDjView 2.1. Цей репозиторій — [raspopov/WinDjView](https://github.com/raspopov/WinDjView)
(конвертований з CVS SourceForge, історія збережена) плюс зміни, описані нижче. Програму збирають з вихідного коду.
Для користувачів: [встановлення](INSTALL.md), [кіберзахист](SECURITY.md).

## Що змінено відносно WinDjView 2.1

Повідомлення про зміни (GNU GPL v2, §2a); повна історія — у `git log`, коротко — у `windjview/changes.txt`.

| Що | Де |
|---|---|
| Повний український переклад (меню, діалоги, рядки, гарячі клавіші); примітка про модифіковану версію в «Про програму» (укр. і англ.) | `windjview/Languages/Ukrainian/`, `windjview/WinDjView.rc` |
| Українська — мова за замовчуванням; без `WinDjViewUA.dll` програма працює англійською | `AppSettings.cpp` |
| Власні налаштування `HKCU\Software\WinDjView-UA\WinDjView` (не перетинаються з офіційним WinDjView) | `WinDjView.cpp` (`SetRegistryKey`) |
| Перевірка оновлень: `https://raw.githubusercontent.com/gennadijkhimij/WinDjView-UA/main/version.txt`, сторінка завантаження — релізи GitHub | `IDS_VERSION_URL`, `IDS_DOWNLOAD_URL` у `.rc` |
| **Кіберзахист:** мовна DLL — лише як ресурси; безпечний пошук DLL; виправлення DjVuLibre 2014–2026 | `WinDjView.cpp`, `WinDjView.15.vcxproj`, `libdjvu/` — див. [SECURITY.md](SECURITY.md), [DJVULIBRE-BACKPORTS.md](DJVULIBRE-BACKPORTS.md) |
| Збирання Visual Studio 2026 (v145), статичні MFC/CRT, x64 і x86; лише англійська (вбудована) і українська мови | `WinDjView.15.vcxproj`, `libdjvu/libdjvu.15.vcxproj`, `Languages/Ukrainian/WinDjViewUA.15.vcxproj` |
| Метадані файлів: ProductName `WinDjView-UA`, CompanyName `Gennadij Khimij`, ліцензія GPL | `VERSIONINFO` у `.rc` |
| Інсталятор NSIS (x64/x86, тека й запис «Програми та засоби» `WinDjView-UA`), скрипти збирання й публікації, CI | `installer/`, `.github/workflows/windjview-ua.yml` |

Інші переклади репозиторію (французький, іспанський, китайський тощо) зроблені для WinDjView 0.4–1.0 і програмою 2.x
не завантажуються — у збірку вони не входять.

## Збирання (Windows)

Потрібно: Visual Studio 2026 з компонентами «Розробка класичних застосунків на C++» і «C++ MFC», NSIS 3.

```
powershell -ExecutionPolicy Bypass -File installer\build-windows.ps1
```

Скрипт збирає `windjview\WinDjView.15.sln` (Release x64 і Win32: `WinDjView.exe`, `WinDjViewUA.dll`, `libdjvu`),
потім інсталятор → `installer\dist\WinDjView-UA-<версія>-Setup-x64-x86.exe` і `SHA256SUMS.txt`.
Версію бере з `IDS_CURRENT_VERSION`. На Visual Studio 2022 використовує набір інструментів v143 (так збирає GitHub Actions).

Окремо в Visual Studio: відкрити `windjview\WinDjView.15.sln`, проєкт **WinDjView.15**, Release x64/Win32.

Випуск нової версії — [RELEASE.md](RELEASE.md).

## Технічні нотатки

- **Мовна DLL** завантажується програмою лише тоді, коли її `FileVersion` точно збігається з версією програми,
  тому номер версії однаковий у `WinDjView.rc` і `WinDjViewUA.rc`.
- **Мовна DLL лише як ресурси:** `LoadLibraryEx(…, LOAD_LIBRARY_AS_DATAFILE | LOAD_LIBRARY_AS_IMAGE_RESOURCE)`.
  Меню, діалоги, рядки, курсори, бітмапи й панелі інструментів працюють (перевірено, зокрема перемикання мов на льоту).
- **Пошук DLL:** `RestrictDllSearchPath()` на початку `InitInstance` (`SetDllDirectory("")`,
  `SetDefaultDllDirectories(LOAD_LIBRARY_SEARCH_DEFAULT_DIRS)`; функції шукаються під час виконання, бо проєкт
  використовує заголовки Windows XP) і ключ компонувальника `/DEPENDENTLOADFLAG:0x800`.
- **libdjvu** — DjVuLibre 3.5.25.3 зі 104 змінами WinDjView і перенесеними виправленнями безпеки;
  спосіб і перелік — [DJVULIBRE-BACKPORTS.md](DJVULIBRE-BACKPORTS.md).
- **Падіння «Властивостей документа»** в офіційному x64 2.1: вказівник на елемент списку обрізався до `DWORD`;
  виправлено в коді 2020 р. (`0ca20c1`), офіційно не випускалося — власна збірка його містить.

### Історичне: мовний пакет для офіційного WinDjView 2.1

Перша версія локалізації (вересень 2026) — лише `WinDjViewUA.dll` для офіційного `WinDjView.exe` 2.1, зібрана на
Linux через MinGW-w64 (`installer/tools/build.sh`, `build_lang_dll.sh`, `fix_toolbar.py`, `verify_dll.py`).
Особливості цієї збірки: `windres` пише ресурси `TOOLBAR` у форматі, який MFC не читає (`fix_toolbar.py`);
немає `afxres.rc` (`afx_extra.rc`, `afx_res/*.bin`, `afx_strings_uk.py`); шляхи `..\` у `.rc` переписуються лише
в рядках-іменах файлів (інакше `\t` у пунктах меню ставав `/t`). Для WinDjView-UA ці інструменти не потрібні:
DLL версії 2.1.x офіційний WinDjView 2.1 не завантажить.

## Що перевірено (Windows 10 Pro 22H2, x64)

- Встановлення, видалення й повторне встановлення інсталятором (тихий режим), ярлики для всіх користувачів,
  запис у «Програмах і засобах»; офіційний WinDjView поруч не зачіпається.
- Інтерфейс: усе меню, «Мова», вкладки «Налаштування», діалоги «Друк», «Властивості документа», «Перехід на
  сторінку», «Вибір масштабу», «Про програму», «Зберегти сторінку як»; перемикання англійська ↔ українська.
- Перевірка оновлень (сервер із новішою версією → пропозиція оновитися; поточна → «найновіша версія»).
- Мовна DLL не завантажується як модуль коду; курсори, бітмапи, значок, меню й рядки беруться з неї.
- Нова бібліотека: відображення документів, 40 випадково пошкоджених файлів — без падінь.
- Автоматичне збирання на GitHub Actions.

**Не перевірено:** Windows 11 і Windows 7; 32-бітна збірка на 32-бітній Windows (запускалась лише x64);
діалоги закладок, анотацій, словників; кожна CVE окремо на експлойті.

## Ліцензія

GNU General Public License v2 або новіша (як WinDjView і DjVuLibre) — `windjview/license`. Оригінальні авторські
права — Андрій та Леонід Жежеруни; зміни © 2026 Хімій Геннадій, на тих самих умовах, без додаткових обмежень.
