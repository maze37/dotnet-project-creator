# dotnet-project-creator

Bash скрипт для автоматической генерации .NET проектов по архитектуре Clean Architecture.

## Структура которую создаёт скрипт
```
MyProject/
├── MyProject.sln
├── .gitignore
└── src/
    ├── MyProject.Domain/
    ├── MyProject.Application/
    ├── MyProject.Infrastructure/
    └── MyProject.Web/
```

## Использование
```bash
chmod +x create-project.sh
./create-project.sh
```

Скрипт спросит название проекта и создаст всё автоматически.

## Что делает скрипт

- Создаёт solution файл
- Генерирует 4 проекта (Domain, Application, Infrastructure, Web)
- Настраивает зависимости между проектами
- Устанавливает Swashbuckle (Swagger)
- Генерирует .gitignore через `dotnet new gitignore`
- Удаляет шаблонный WeatherForecast мусор
