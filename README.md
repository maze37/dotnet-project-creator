# 🛠️ .NET Project Creator

Bash скрипт для автоматической генерации .NET проектов. Выбираешь пресет — получаешь готовую структуру с настроенными зависимостями, пакетами и папками.

---

## 🚀 Быстрый старт

```bash
git clone https://github.com/maze37/dotnet-project-creator.git
cd dotnet-project-creator
chmod +x create-project.sh
./create-project.sh
```

---

## 📦 Пресеты

### 1) Domain Only
Только бизнес-ядро. Для тех, кто начинает с продумывания агрегатов и энтити.

```
MyProject/
└── src/
    └── MyProject.Domain/
        ├── Aggregates/
        ├── Entities/
        ├── ValueObjects/
        ├── Enums/
        └── Exceptions/
```

---

### 2) Minimal API
Быстро поднять API без лишних слоёв.

```
MyProject/
└── src/
    ├── MyProject.Domain/
    │   ├── Entities/
    │   └── ValueObjects/
    └── MyProject.Web/
        └── Controllers/
```

**Пакеты:** Swashbuckle.AspNetCore

---

### 3) Standard
Классическая четырёхслойная архитектура.

```
MyProject/
└── src/
    ├── MyProject.Domain/
    │   ├── Aggregates/
    │   ├── Entities/
    │   ├── ValueObjects/
    │   ├── Enums/
    │   └── Exceptions/
    ├── MyProject.Application/
    │   └── Abstractions/
    ├── MyProject.Infrastructure/
    └── MyProject.Web/
        └── Controllers/
```

**Зависимости:**
```
Application    → Domain
Infrastructure → Application, Domain
Web            → Application, Infrastructure
```

**Пакеты:** Swashbuckle.AspNetCore

---

### 4) Full + CQRS
Полная структура для серьёзных проектов. Добавляет SharedKernel, CQRS папки и пакеты MediatR + FluentValidation.

```
MyProject/
└── src/
    ├── MyProject.Domain/
    │   ├── Aggregates/
    │   ├── Entities/
    │   ├── ValueObjects/
    │   ├── Enums/
    │   └── Exceptions/
    ├── MyProject.Application/
    │   ├── UseCases/
    │   │   ├── Commands/
    │   │   └── Queries/
    │   ├── Abstractions/
    │   └── Validators/
    ├── MyProject.Infrastructure/
    ├── MyProject.Shared/
    │   ├── Contracts/
    │   └── Extensions/
    └── MyProject.Web/
        └── Controllers/
```

**Зависимости:**
```
Domain         → Shared
Application    → Domain, Shared
Infrastructure → Application, Domain
Web            → Application, Infrastructure
```

**Пакеты:** MediatR, FluentValidation, FluentValidation.DependencyInjectionExtensions, Swashbuckle.AspNetCore

---

## ✨ Возможности

- **Прогресс-бар** — полоска `████░░░░` и счётчик шагов `[2/5]` в реальном времени
- **Валидация имени** — название должно начинаться с буквы, без пробелов и спецсимволов
- **Проверка окружения** — скрипт проверяет наличие `dotnet` перед запуском
- **Чистый .gitignore** — генерируется через `dotnet new gitignore` (актуальный, от Microsoft)
- **Нет мусора** — шаблонный `WeatherForecastController` и `WeatherForecast.cs` удаляются автоматически
- **Пустые папки** — сохраняются через `.gitkeep`, git их не потеряет

---

## 📋 Требования

- `bash`
- [`dotnet SDK`](https://dotnet.microsoft.com/download) — любая актуальная версия
- `git` — для `.gitignore` генерации

---

## 📝 Changelog

### v2.1
- Исправлены зависимости в пресете Full + CQRS — `Web → Infrastructure` возвращён, схема соответствует реальной архитектуре

### v2.0
- Добавлены 4 пресета: Domain Only, Minimal API, Standard, Full + CQRS
- Прогресс-бар с полоской и счётчиком шагов
- Валидация названия проекта
- Проверка установленного dotnet перед стартом
- Весь вывод dotnet скрыт — только нужные сообщения
- `dotnet new gitignore` вместо ручного heredoc
- Явные пути к `.csproj` в `dotnet add reference`
- Исправлен баг с необъявленной переменной `ORANGE`

### v1.0
- Базовая генерация Clean Architecture проекта
- Domain, Application, Infrastructure, Web
- Swagger, .gitignore, удаление WeatherForecast
