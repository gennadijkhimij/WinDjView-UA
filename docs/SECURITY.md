# Кіберзахист WinDjView-UA / Security

## Що посилено відносно WinDjView 2.1 (2015)

| Захід | WinDjView 2.1 | WinDjView-UA 2.1.2 |
|---|---|---|
| **Виправлення безпеки DjVuLibre** (бібліотека, що розбирає файли DjVu) | бібліотека 2012 р. без виправлень | перенесено виправлення 2014–2026 рр.: CVE-2019-15142…15145, CVE-2019-18804, CVE-2021-3500, CVE-2021-3630, CVE-2021-32490…32493, CVE-2025-53367 та інші — [перелік](DJVULIBRE-BACKPORTS.md) |
| **Компілятор і бібліотеки MFC/CRT** | Visual Studio 2013 | Visual Studio 2026 (11 років виправлень) |
| **Control Flow Guard** (захист від перехоплення керування) | ❌ | ✅ x64 і x86 |
| ASLR, DEP, /GS (стандартні захисти пам'яті) | ✅ | ✅ |
| **Мовна DLL** (`WinDjView*.dll` поруч із програмою) | завантажується як код — підкладена DLL виконується | завантажується **лише як ресурси**, її код не виконується |
| **Пошук системних DLL** (`version.dll`, `uxtheme.dll`, …) | зокрема в поточній теці | лише System32 і тека програми (`/DEPENDENTLOADFLAG`, `SetDefaultDllDirectories`) — захист від підміни DLL |
| **Помилка пам'яті у «Властивостях документа»** (x64 обрізав адресу) | падіння | виправлено |
| **Перевірка оновлень** | HTTP (і вже не працювала) | HTTPS, GitHub; програма лише показує, що є нова версія, сама нічого не завантажує |
| **Тека встановлення** | будь-яка, зокрема доступна на запис усім | `C:\Program Files\WinDjView-UA` — змінювати можуть лише адміністратори |
| **Контрольні суми** | — | `SHA256SUMS.txt` у кожному релізі |
| **Збирання** | вручну | відкритий код + GitHub Actions: кожен інсталятор можна відтворити з репозиторію |

## Що лишається ризиком (чесно)

- **Файли з ненадійних джерел.** Бібліотека DjVuLibre — це версія 3.5.25.3 з перенесеними
  виправленнями, а не повністю нова. Відомі вразливості закрито, але відкривати DjVu-файли з
  невідомих листів і сайтів усе одно варто обережно.
- **Немає цифрового підпису.** Windows попереджає «невідомий видавець». Заявку на безкоштовний
  підпис для відкритих проєктів (SignPath Foundation) готуємо — див. [політику підпису](CODE_SIGNING_POLICY.md).
  До того перевіряйте контрольну суму (див. [встановлення](INSTALL.md)).
- **Версія 2.1.1** перевіряла оновлення через SourceForge, проєкт там видалено. Оновіться до 2.1.2.

## Поради користувачам

1. Завантажуйте програму **лише** зі сторінки релізів:
   https://github.com/gennadijkhimij/WinDjView-UA/releases/latest
2. Перевіряйте SHA-256 інсталятора з `SHA256SUMS.txt` (див. [INSTALL.md](INSTALL.md)).
3. Встановлюйте в теку за замовчуванням (`C:\Program Files\WinDjView-UA`), не в теки на кшталт
   `C:\WinDjView` чи «Завантаження», куди може писати будь-який користувач.
4. Не вимикайте перевірку оновлень і встановлюйте нові версії.
5. Підозрілі DjVu-файли з пошти відкривайте лише після перевірки антивірусом.

## Приватність

Програма не збирає й не надсилає жодних даних. Єдине мережеве з'єднання — перевірка оновлень
(файл `version.txt` з GitHub) раз на тиждень; її можна вимкнути:
«Налаштування → Додатково → Автоматично перевіряти оновлення раз на тиждень».

## Повідомити про вразливість

Не публікуйте подробиці у відкритих issues. Скористайтеся
[приватним повідомленням про вразливість](https://github.com/gennadijkhimij/WinDjView-UA/security/advisories/new)
на GitHub. Вразливості самої бібліотеки DjVuLibre повідомляйте також її розробникам:
https://sourceforge.net/p/djvu/bugs/

---

## English summary

WinDjView-UA 2.1.2 hardens WinDjView 2.1: DjVuLibre security fixes 2014–2026 backported
(CVE-2019-15142..15145, CVE-2019-18804, CVE-2021-3500, CVE-2021-3630, CVE-2021-32490..32493,
CVE-2025-53367 and others); built with Visual Studio 2026 with Control Flow Guard, ASLR, DEP, /GS;
the language DLL is mapped as resources only; system DLLs are loaded from System32 only;
fixed a 64-bit pointer truncation crash; HTTPS update check that never downloads anything by itself;
installation into Program Files; SHA-256 checksums for every release; reproducible CI builds.
Remaining risks: the DjVuLibre base is 3.5.25.3 with backports, and releases are not code-signed yet.
Report vulnerabilities privately via GitHub security advisories.
