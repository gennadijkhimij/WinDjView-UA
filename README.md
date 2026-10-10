# WinDjView-UA

Модифікована версія WinDjView — швидкого переглядача DjVu для Windows — з повною українською локалізацією, посиленим кіберзахистом і перевіркою оновлень.
A modified version of the WinDjView DjVu viewer for Windows: complete Ukrainian localization, security hardening and update checks.

**[⬇ Завантажити / Download](https://github.com/gennadijkhimij/WinDjView-UA/releases/latest)** · [Встановлення](docs/INSTALL.md) · [Кіберзахист / Security](docs/SECURITY.md) · [Зміни](windjview/changes.txt) · Code signing policy: [docs/CODE_SIGNING_POLICY.md](docs/CODE_SIGNING_POLICY.md)

## Українською

**Що це:** WinDjView 2.1, зібраний з вихідного коду (Visual Studio 2026, x64 і x86), з українським інтерфейсом за замовчуванням (англійська — у меню «Вигляд → Мова»). Ставиться окремо від офіційного WinDjView у `C:\Program Files\WinDjView-UA`.

**Кіберзахист** (детально — [docs/SECURITY.md](docs/SECURITY.md)):
- у бібліотеку DjVuLibre перенесено виправлення безпеки 2014–2026 рр. (CVE-2019-15142…15145, CVE-2019-18804, CVE-2021-3500, CVE-2021-3630, CVE-2021-32490…32493, CVE-2025-53367 та інші) — [перелік](docs/DJVULIBRE-BACKPORTS.md);
- сучасний компілятор із Control Flow Guard, ASLR, DEP, /GS;
- мовна DLL завантажується лише як ресурси, системні DLL — лише з System32 (захист від підміни DLL);
- виправлено помилку пам'яті у «Властивостях документа» (x64);
- перевірка оновлень лише через HTTPS і лише повідомляє — нічого не завантажує сама; її можна вимкнути;
- встановлення в `Program Files`, контрольні суми SHA-256 для кожного релізу, відтворювана збірка на GitHub Actions;
- програма не збирає й не надсилає жодних даних.

Безпечне встановлення: завантажуйте лише з [релізів](https://github.com/gennadijkhimij/WinDjView-UA/releases/latest) і перевіряйте SHA-256 — [docs/INSTALL.md](docs/INSTALL.md). Цифрового підпису поки немає (заявку готуємо).

**Авторство:** WinDjView-UA — модифікована версія WinDjView. © 2026 Хімій Геннадій — українська локалізація, система оновлень, зміни та виправлення (особистий проєкт). На основі WinDjView © 2004–2015 Андрій Жежерун, © 2012–2015 Леонід Жежерун ([сайт](https://windjview.sourceforge.net), [код](https://github.com/raspopov/WinDjView)).

**Ліцензія:** GNU GPL версії 2 або (на ваш вибір) будь-якої пізнішої. Програма надається «як є», без жодних гарантій.

**Супровід:** Хімій Геннадій. Збірка, перевірка й випуск — [docs/UKRAINIAN.md](docs/UKRAINIAN.md), [docs/RELEASE.md](docs/RELEASE.md). Про вразливості — приватно через [GitHub Security Advisories](https://github.com/gennadijkhimij/WinDjView-UA/security).

## English

**What it is:** WinDjView 2.1 built from source (Visual Studio 2026, x64 and x86) with a Ukrainian interface by default (English via *View → Language*). Installs side by side with the official WinDjView into `C:\Program Files\WinDjView-UA`.

**Security** ([docs/SECURITY.md](docs/SECURITY.md)): DjVuLibre security fixes 2014–2026 backported (CVE-2019-15142..15145, CVE-2019-18804, CVE-2021-3500, CVE-2021-3630, CVE-2021-32490..32493, CVE-2025-53367 and others); Control Flow Guard, ASLR, DEP, /GS; the language DLL is mapped as resources only and system DLLs are loaded from System32 only; a 64-bit memory bug fixed; HTTPS update check that only notifies and can be turned off; Program Files installation, SHA-256 checksums, reproducible GitHub Actions builds; no data collection. Releases are not code-signed yet — verify the SHA-256 ([docs/INSTALL.md](docs/INSTALL.md)).

**Authorship:** WinDjView-UA is a modified version of WinDjView. © 2026 Gennadij Khimij — Ukrainian localization, update check, changes and fixes (personal project). Based on WinDjView © 2004–2015 Andrew Zhezherun, © 2012–2015 Leonid Zhezherun.

**License:** GNU GPL version 2 or (at your option) any later version. Provided "as is", without any warranty. Report vulnerabilities privately via [GitHub Security Advisories](https://github.com/gennadijkhimij/WinDjView-UA/security).

---

## Original WinDjView

*A fast, compact, and powerful DjVu viewer.*

Brought to you by: [Andrew Zhezherun](https://sourceforge.net/u/zhezherun/profile/)

### Summary
WinDjView is a fast, compact and powerful DjVu viewer for Windows with tabbed interface, continuous scrolling and advanced printing options, based on free DjVuLibre library.

![WinDjView screenshot](https://a.fsdn.com/con/app/proj/windjview/screenshots/328149.jpg)

### Files
[Download WinDjView](https://sourceforge.net/projects/windjview/files/latest/download)

### Support
[Discussion](https://sourceforge.net/p/windjview/discussion/)

### License
GNU General Public License version 2.0 (GPLv2)

### Code
This repository was kindly converted from an official [SourceForge.Net CVS-repository](https://sourceforge.net/p/windjview/code/) with a preserved commit history.
