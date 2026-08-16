# Tracker

Трекер привычек (Яндекс Практикум, iOS-разработчик).

## Локализация

Базовый язык — русский. Дополнительно подключены английский и испанский
(машинный перевод).

```
Tracker/Resources/Localization/
├── ru.lproj/Localizable.strings, Localizable.stringsdict
├── en.lproj/Localizable.strings, Localizable.stringsdict
└── es.lproj/Localizable.strings, Localizable.stringsdict
```

Плюрализация «N дней» вынесена в `Localizable.stringsdict`: для русского
настроены формы `one / few / many / other`, для английского и испанского —
`one / other`.

## Кодогенерация ресурсов (SwiftGen)

Обращение к строкам идёт через сгенерированный `enum L10n`, а не через
строковые литералы:

```swift
title = L10n.Trackers.title
counterLabel.text = L10n.daysCount(count)   // из .stringsdict
```

Файл `Generated/Strings+Generated.swift` создаётся build-фазой **SwiftGen**,
которая выполняется **до** `Compile Sources`, и не хранится в git
(см. `.gitignore`). Конфигурация — `swiftgen.yml`.

Перед первой сборкой установите SwiftGen:

```sh
brew install swiftgen
# или
mint install SwiftGen/SwiftGen
```

Для этой build-фазы отключён `ENABLE_USER_SCRIPT_SANDBOXING`: в песочнице
скрипт не может прочитать `swiftgen.yml` и записать файл в `Generated/`.

Ассеты (изображения) уже используют сгенерированные Xcode символы
`ImageResource`: `UIImage(resource: .icTabBarTrackers)`.

## Зависимости (SPM)

| Пакет | Таргет | Назначение |
| --- | --- | --- |
| [appmetrica-sdk-ios](https://github.com/appmetrica/appmetrica-sdk-ios) (`AppMetricaCore`) | Tracker | аналитика |
| [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) (`SnapshotTesting`) | TrackerTests | скриншот-тесты |

Пакеты объявлены в `project.pbxproj`; при первом открытии Xcode разрешит их
сам (**File → Packages → Resolve Package Versions**, если этого не произошло).

## Аналитика

События отправляются с полями `event` (`open` / `close` / `click`),
`screen` (`Main`) и `item` (`add_track`, `track`, `filter`, `edit`,
`delete`) и дублируются в консоль в DEBUG-сборке.

API key в репозитории не хранится: он выдаётся на конкретное приложение в
интерфейсе AppMetrica и является приватным. В `AnalyticsService` лежит
плейсхолдер. Без ключа SDK не активируется, приложение работает штатно, а
отправляемые события можно проверить по логам в консоли. Чтобы события уходили
в AppMetrica, подставьте свой ключ в `AnalyticsService.Constants.apiKey`.

## Скриншот-тесты

`TrackerTests` снимают главный экран в светлой и тёмной темах, с данными и в
пустом состоянии. Эталоны лежат в `TrackerTests/__Snapshots__`.

Детерминизм обеспечивают три вещи:

* in-memory Core Data стек и фиксированный набор трекеров (`TrackerFixtures`),
  поэтому снапшот не зависит от данных на устройстве;
* фиксированная дата (понедельник, 05.01.2026), которая прокидывается в
  `TrackersViewController`. Иначе `UIDatePicker` показывал бы текущий день и
  эталон устаревал бы каждые сутки;
* явная конфигурация устройства `.image(on: .iPhone13, traits:)`, за счёт чего
  размер кадра не зависит от выбранного симулятора.

Порядок работы:

1. Первый запуск записывает эталоны и завершается с сообщением о записи.
2. Повторный запуск сравнивает результат с эталонами и проходит.
3. Перезаписать эталоны после правок вёрстки можно через
   `withSnapshotTesting(record: .all) { assertSnapshot(...) }` либо удалив
   папку `__Snapshots__`.

Записывать и сравнивать эталоны нужно на одном и том же симуляторе и одной
версии iOS: рендеринг системных элементов между версиями отличается.
