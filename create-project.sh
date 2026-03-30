#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─────────────────────────────────────────
#  Прогресс-бар
#  Использование: step <описание>
# ─────────────────────────────────────────
STEP=0

progress() {
    local step="$1"
    local total="$2"
    local label="$3"
    local bar_width=24
    local filled=$(( bar_width * step / total ))
    local empty=$(( bar_width - filled ))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty;  i++)); do bar+="░"; done
    echo -e "${CYAN}[${step}/${total}]${NC} ${bar} ${YELLOW}${label}${NC}"
}

step() {
    STEP=$(( STEP + 1 ))
    progress "$STEP" "$TOTAL_STEPS" "$1"
}

# ─────────────────────────────────────────
#  Проверка что dotnet установлен
# ─────────────────────────────────────────
if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}Ошибка: dotnet не установлен.${NC}"
    echo -e "Скачай здесь: ${CYAN}https://dotnet.microsoft.com/download${NC}"
    exit 1
fi

# ─────────────────────────────────────────
#  Шапка
# ─────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║     .NET Project Creator v2.0        ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""

# ─────────────────────────────────────────
#  Название проекта + валидация
# ─────────────────────────────────────────
echo -e "${GREEN}Введите название проекта:${NC}"
read PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Ошибка: название не может быть пустым${NC}"
    exit 1
fi

if [[ ! "$PROJECT_NAME" =~ ^[A-Za-z] ]]; then
    echo -e "${RED}Ошибка: название должно начинаться с буквы (A-Z, a-z)${NC}"
    exit 1
fi

if [[ ! "$PROJECT_NAME" =~ ^[A-Za-z][A-Za-z0-9_-]*$ ]]; then
    echo -e "${RED}Ошибка: допустимы только буквы, цифры, дефис и подчёркивание. Без пробелов.${NC}"
    echo -e "${YELLOW}Примеры: MyProject, my-project, my_project${NC}"
    exit 1
fi

# ─────────────────────────────────────────
#  Выбор пресета
# ─────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}Выберите шаблон проекта:${NC}"
echo ""
echo -e "  ${YELLOW}1)${NC} ${BOLD}Domain Only${NC}    — Domain (агрегаты, энтити, value objects)"
echo -e "  ${YELLOW}2)${NC} ${BOLD}Minimal API${NC}    — Domain + Web"
echo -e "  ${YELLOW}3)${NC} ${BOLD}Standard${NC}       — Domain + Application + Infrastructure + Web"
echo -e "  ${YELLOW}4)${NC} ${BOLD}Full + CQRS${NC}    — Standard + SharedKernel + MediatR + FluentValidation"
echo ""
read -p "Введите номер [1-4]: " PRESET

case $PRESET in
    1|2|3|4) ;;
    *)
        echo -e "${RED}Ошибка: введите число от 1 до 4${NC}"
        exit 1
        ;;
esac

case $PRESET in
    1) TOTAL_STEPS=3 ;;
    2) TOTAL_STEPS=4 ;;
    3) TOTAL_STEPS=5 ;;
    4) TOTAL_STEPS=7 ;;
esac

echo ""

# ─────────────────────────────────────────
#  Вспомогательные функции
# ─────────────────────────────────────────
create_classlib() {
    dotnet new classlib -n "$1" -o "src/$1" --no-restore > /dev/null 2>&1
    dotnet sln add "src/$1/$1.csproj" > /dev/null 2>&1
}

add_ref() {
    dotnet add "src/$1" reference "src/$2/$2.csproj" > /dev/null 2>&1
}

make_dir() {
    mkdir -p "$1"
    touch "$1/.gitkeep"
}

# ─────────────────────────────────────────
#  Шаг 1 — Solution (общий для всех)
# ─────────────────────────────────────────
mkdir "$PROJECT_NAME" || {
    echo -e "${RED}Ошибка: папка '$PROJECT_NAME' уже существует${NC}"
    exit 1
}
cd "$PROJECT_NAME"

step "Создаём solution..."
dotnet new sln -n "$PROJECT_NAME" > /dev/null 2>&1
dotnet new gitignore > /dev/null 2>&1
mkdir src

# ─────────────────────────────────────────
#  ПРЕСЕТ 1 — Domain Only
# ─────────────────────────────────────────
if [ "$PRESET" = "1" ]; then

    step "Создаём Domain..."
    create_classlib "$PROJECT_NAME.Domain"
    make_dir "src/$PROJECT_NAME.Domain/Entities"
    make_dir "src/$PROJECT_NAME.Domain/Aggregates"
    make_dir "src/$PROJECT_NAME.Domain/ValueObjects"
    make_dir "src/$PROJECT_NAME.Domain/Enums"
    make_dir "src/$PROJECT_NAME.Domain/Exceptions"
    rm -f "src/$PROJECT_NAME.Domain/Class1.cs"

    step "Финализируем..."
    dotnet restore > /dev/null 2>&1

fi

# ─────────────────────────────────────────
#  ПРЕСЕТ 2 — Minimal API
# ─────────────────────────────────────────
if [ "$PRESET" = "2" ]; then

    step "Создаём проекты..."
    create_classlib "$PROJECT_NAME.Domain"
    dotnet new webapi -n "$PROJECT_NAME.Web" -o "src/$PROJECT_NAME.Web" --no-restore > /dev/null 2>&1
    dotnet sln add "src/$PROJECT_NAME.Web/$PROJECT_NAME.Web.csproj" > /dev/null 2>&1

    step "Настраиваем зависимости и пакеты..."
    add_ref "$PROJECT_NAME.Web" "$PROJECT_NAME.Domain"
    dotnet add "src/$PROJECT_NAME.Web" package Swashbuckle.AspNetCore > /dev/null 2>&1

    step "Создаём структуру папок..."
    make_dir "src/$PROJECT_NAME.Domain/Entities"
    make_dir "src/$PROJECT_NAME.Domain/ValueObjects"
    make_dir "src/$PROJECT_NAME.Web/Controllers"
    rm -f "src/$PROJECT_NAME.Domain/Class1.cs"
    rm -f "src/$PROJECT_NAME.Web/Controllers/WeatherForecastController.cs"
    rm -f "src/$PROJECT_NAME.Web/WeatherForecast.cs"

    step "Финализируем..."
    dotnet restore > /dev/null 2>&1

fi

# ─────────────────────────────────────────
#  ПРЕСЕТ 3 — Standard
# ─────────────────────────────────────────
if [ "$PRESET" = "3" ]; then

    step "Создаём проекты..."
    create_classlib "$PROJECT_NAME.Domain"
    create_classlib "$PROJECT_NAME.Application"
    create_classlib "$PROJECT_NAME.Infrastructure"
    dotnet new webapi -n "$PROJECT_NAME.Web" -o "src/$PROJECT_NAME.Web" --no-restore > /dev/null 2>&1
    dotnet sln add "src/$PROJECT_NAME.Web/$PROJECT_NAME.Web.csproj" > /dev/null 2>&1

    step "Настраиваем зависимости..."
    add_ref "$PROJECT_NAME.Application"    "$PROJECT_NAME.Domain"
    add_ref "$PROJECT_NAME.Infrastructure" "$PROJECT_NAME.Application"
    add_ref "$PROJECT_NAME.Infrastructure" "$PROJECT_NAME.Domain"
    add_ref "$PROJECT_NAME.Web"            "$PROJECT_NAME.Application"
    add_ref "$PROJECT_NAME.Web"            "$PROJECT_NAME.Infrastructure"

    step "Устанавливаем пакеты..."
    dotnet add "src/$PROJECT_NAME.Web" package Swashbuckle.AspNetCore > /dev/null 2>&1

    step "Создаём структуру папок..."
    make_dir "src/$PROJECT_NAME.Domain/Entities"
    make_dir "src/$PROJECT_NAME.Domain/Aggregates"
    make_dir "src/$PROJECT_NAME.Domain/ValueObjects"
    make_dir "src/$PROJECT_NAME.Domain/Enums"
    make_dir "src/$PROJECT_NAME.Domain/Exceptions"
    make_dir "src/$PROJECT_NAME.Application/Abstractions"
    make_dir "src/$PROJECT_NAME.Web/Controllers"
    rm -f "src/$PROJECT_NAME.Domain/Class1.cs"
    rm -f "src/$PROJECT_NAME.Application/Class1.cs"
    rm -f "src/$PROJECT_NAME.Infrastructure/Class1.cs"
    rm -f "src/$PROJECT_NAME.Web/Controllers/WeatherForecastController.cs"
    rm -f "src/$PROJECT_NAME.Web/WeatherForecast.cs"

    step "Финализируем..."
    dotnet restore > /dev/null 2>&1

fi

# ─────────────────────────────────────────
#  ПРЕСЕТ 4 — Full + CQRS
# ─────────────────────────────────────────
if [ "$PRESET" = "4" ]; then

    step "Создаём проекты..."
    create_classlib "$PROJECT_NAME.Domain"
    create_classlib "$PROJECT_NAME.Application"
    create_classlib "$PROJECT_NAME.Infrastructure"
    create_classlib "$PROJECT_NAME.Shared"
    dotnet new webapi -n "$PROJECT_NAME.Web" -o "src/$PROJECT_NAME.Web" --no-restore > /dev/null 2>&1
    dotnet sln add "src/$PROJECT_NAME.Web/$PROJECT_NAME.Web.csproj" > /dev/null 2>&1

    step "Настраиваем зависимости..."
    add_ref "$PROJECT_NAME.Domain"         "$PROJECT_NAME.Shared"
    add_ref "$PROJECT_NAME.Application"    "$PROJECT_NAME.Domain"
    add_ref "$PROJECT_NAME.Application"    "$PROJECT_NAME.Shared"
    add_ref "$PROJECT_NAME.Infrastructure" "$PROJECT_NAME.Application"
    add_ref "$PROJECT_NAME.Infrastructure" "$PROJECT_NAME.Domain"
    add_ref "$PROJECT_NAME.Web"            "$PROJECT_NAME.Application"
    add_ref "$PROJECT_NAME.Web"            "$PROJECT_NAME.Infrastructure"

    step "Устанавливаем пакеты..."
    dotnet add "src/$PROJECT_NAME.Application" package MediatR > /dev/null 2>&1
    dotnet add "src/$PROJECT_NAME.Application" package FluentValidation > /dev/null 2>&1
    dotnet add "src/$PROJECT_NAME.Application" package FluentValidation.DependencyInjectionExtensions > /dev/null 2>&1
    dotnet add "src/$PROJECT_NAME.Web"         package Swashbuckle.AspNetCore > /dev/null 2>&1
    dotnet add "src/$PROJECT_NAME.Web"         package MediatR > /dev/null 2>&1

    step "Создаём структуру папок..."
    make_dir "src/$PROJECT_NAME.Domain/Entities"
    make_dir "src/$PROJECT_NAME.Domain/Aggregates"
    make_dir "src/$PROJECT_NAME.Domain/ValueObjects"
    make_dir "src/$PROJECT_NAME.Domain/Enums"
    make_dir "src/$PROJECT_NAME.Domain/Exceptions"
    make_dir "src/$PROJECT_NAME.Application/UseCases/Commands"
    make_dir "src/$PROJECT_NAME.Application/UseCases/Queries"
    make_dir "src/$PROJECT_NAME.Application/Abstractions"
    make_dir "src/$PROJECT_NAME.Application/Validators"
    make_dir "src/$PROJECT_NAME.Shared/Contracts"
    make_dir "src/$PROJECT_NAME.Shared/Extensions"
    make_dir "src/$PROJECT_NAME.Web/Controllers"
    rm -f "src/$PROJECT_NAME.Domain/Class1.cs"
    rm -f "src/$PROJECT_NAME.Application/Class1.cs"
    rm -f "src/$PROJECT_NAME.Infrastructure/Class1.cs"
    rm -f "src/$PROJECT_NAME.Shared/Class1.cs"
    rm -f "src/$PROJECT_NAME.Web/Controllers/WeatherForecastController.cs"
    rm -f "src/$PROJECT_NAME.Web/WeatherForecast.cs"

    step "Финализируем..."
    dotnet restore > /dev/null 2>&1

fi

# ─────────────────────────────────────────
#  Итог
# ─────────────────────────────────────────
echo ""
echo -e "${GREEN}✅ Проект ${BOLD}$PROJECT_NAME${NC}${GREEN} создан!${NC}"
echo ""
echo -e "${ORANGE}Структура:${NC}"
find . \
    -not -path '*/obj/*' \
    -not -path '*/bin/*' \
    -not -name '.gitkeep' \
    -not -name '.gitignore' \
    -not -name '*.sln' \
  | sort \
  | sed 's|[^/]*/|  |g; s|^\s\s||'
echo ""
echo -e "${GREEN}Для запуска:${NC}"
if [ "$PRESET" = "1" ]; then
    echo -e "  ${YELLOW}cd $PROJECT_NAME && dotnet build${NC}"
else
    echo -e "  ${YELLOW}cd $PROJECT_NAME/src/$PROJECT_NAME.Web${NC}"
    echo -e "  ${YELLOW}dotnet run${NC}"
fi
echo ""
