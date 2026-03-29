#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Введите название проекта:${NC}"
read PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Ошибка: название не может быть пустым${NC}"
    exit 1
fi

# Сохраняем корневой путь до создания проекта
PROJECT_ROOT="$(pwd)/$PROJECT_NAME"

# Создаём папку с проверкой
mkdir "$PROJECT_NAME" || { echo -e "${RED}Ошибка: папка '$PROJECT_NAME' уже существует${NC}"; exit 1; }
cd "$PROJECT_NAME"

echo -e "${YELLOW}📁 Создаём solution...${NC}"
dotnet new sln -n "$PROJECT_NAME"

# Генерируем .gitignore через dotnet (актуальный, от Microsoft)
dotnet new gitignore

mkdir src

echo -e "${YELLOW}📦 Создаём проекты...${NC}"
dotnet new classlib -n "$PROJECT_NAME.Domain"         -o "src/$PROJECT_NAME.Domain"
dotnet new classlib -n "$PROJECT_NAME.Application"    -o "src/$PROJECT_NAME.Application"
dotnet new classlib -n "$PROJECT_NAME.Infrastructure" -o "src/$PROJECT_NAME.Infrastructure"
dotnet new webapi   -n "$PROJECT_NAME.Web"            -o "src/$PROJECT_NAME.Web"

echo -e "${YELLOW}🔗 Добавляем проекты в solution...${NC}"
dotnet sln add "src/$PROJECT_NAME.Domain/$PROJECT_NAME.Domain.csproj"
dotnet sln add "src/$PROJECT_NAME.Application/$PROJECT_NAME.Application.csproj"
dotnet sln add "src/$PROJECT_NAME.Infrastructure/$PROJECT_NAME.Infrastructure.csproj"
dotnet sln add "src/$PROJECT_NAME.Web/$PROJECT_NAME.Web.csproj"

echo -e "${YELLOW}🔗 Настраиваем зависимости...${NC}"
dotnet add "src/$PROJECT_NAME.Application"    reference "src/$PROJECT_NAME.Domain/$PROJECT_NAME.Domain.csproj"
dotnet add "src/$PROJECT_NAME.Infrastructure" reference "src/$PROJECT_NAME.Application/$PROJECT_NAME.Application.csproj"
dotnet add "src/$PROJECT_NAME.Infrastructure" reference "src/$PROJECT_NAME.Domain/$PROJECT_NAME.Domain.csproj"
dotnet add "src/$PROJECT_NAME.Web"            reference "src/$PROJECT_NAME.Application/$PROJECT_NAME.Application.csproj"
dotnet add "src/$PROJECT_NAME.Web"            reference "src/$PROJECT_NAME.Infrastructure/$PROJECT_NAME.Infrastructure.csproj"

echo -e "${YELLOW}📦 Устанавливаем пакеты...${NC}"
dotnet add "src/$PROJECT_NAME.Web" package Swashbuckle.AspNetCore

echo -e "${YELLOW}🧹 Убираем лишнее...${NC}"
rm -f "src/$PROJECT_NAME.Web/Controllers/WeatherForecastController.cs"
rm -f "src/$PROJECT_NAME.Web/WeatherForecast.cs"

echo ""
echo -e "${GREEN}✅ Проект ${YELLOW}$PROJECT_NAME${GREEN} создан!${NC}"
echo ""
echo -e "${ORANGE}Структура:${NC}"
find . -not -path '*/obj/*' -not -path '*/bin/*' | sort | sed 's|[^/]*/|  |g'
echo ""
echo -e "${GREEN}Для запуска:${NC}"
echo -e "  cd ${YELLOW}$PROJECT_NAME/src/$PROJECT_NAME.Web${NC}"
echo -e "  dotnet run"
