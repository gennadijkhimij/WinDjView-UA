# Code signing policy / Політика цифрового підпису

**Status:** application to SignPath Foundation is being prepared. Until it is approved, WinDjView-UA
releases are **not signed** — verify downloads with `SHA256SUMS.txt` attached to every release.
**Стан:** заявку до SignPath Foundation готуємо. Доки її не схвалено, випуски **не підписані** —
перевіряйте завантажене за `SHA256SUMS.txt` з кожного релізу.

After approval / Після схвалення:

> Free code signing provided by [SignPath.io](https://about.signpath.io), certificate by [SignPath Foundation](https://signpath.org)

## What is signed / Що підписується

Only files built by GitHub Actions from this repository
(`.github/workflows/windjview-ua.yml`, `installer/build-windows.ps1`) for a release tag `v*`:
`WinDjView.exe`, `WinDjViewUA.dll` and `WinDjView-UA-<version>-Setup.exe`.
Product name in the file metadata: **WinDjView-UA**, product version = release version.
Every signing request is approved manually.

Підписуються лише файли, зібрані GitHub Actions з цього репозиторію для тегу випуску `v*`.
Кожен запит на підпис схвалюється вручну.

## Team roles / Ролі

| Role | Members |
|---|---|
| Authors (committers) | Gennadij Khimij ([@gennadijkhimij](https://github.com/gennadijkhimij)) |
| Reviewers (pull requests from others) | Gennadij Khimij |
| Approvers (signing requests) | Gennadij Khimij |

All members use multi-factor authentication for GitHub and SignPath.
Усі учасники використовують двофакторну автентифікацію в GitHub і SignPath.

## Privacy policy / Політика приватності

WinDjView-UA does not collect or send personal data, documents, file names or usage statistics.

The only network connection the program makes on its own is the **update check**: once a week
(and when the user chooses *Help → Check for updates*) it downloads
`https://raw.githubusercontent.com/gennadijkhimij/WinDjView-UA/main/version.txt` — a text file
with the latest version number. The request carries no user data beyond what any HTTPS request
contains (IP address, Windows HTTP client headers), which GitHub processes under its own privacy
statement. The weekly check can be turned off in *Settings → Advanced → Automatically check for updates
once a week*. If a newer version exists, the program only offers to open the
releases page in the browser; it does not download or install anything by itself.

WinDjView-UA не збирає й не надсилає особисті дані, документи, назви файлів чи статистику.
Єдине мережеве з'єднання, яке програма робить сама, — **перевірка оновлень** раз на тиждень
(і з меню «Довідка → Перевірити оновлення»): завантаження файлу `version.txt` з номером останньої
версії з GitHub. Щотижневу перевірку можна вимкнути: «Налаштування → Додатково → Автоматично
перевіряти оновлення раз на тиждень». Нічого самостійно програма не завантажує й не встановлює.

Third-party component: the bundled DjVuLibre library (GNU GPL) only decodes documents and makes
no network connections.
