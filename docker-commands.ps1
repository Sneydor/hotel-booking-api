# docker-commands.ps1
param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

function Show-Header {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "   Hotel Booking - Docker Manager" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

switch ($Command.ToLower()) {
    "start" {
        Show-Header
        Write-Host "🚀 Запуск проекта..." -ForegroundColor Green
        docker-compose up --build -d
        Write-Host ""
        Write-Host "✅ Проект запущен!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🌐 Адреса:" -ForegroundColor Yellow
        Write-Host "   • Админка:     http://localhost:8000/admin/" -ForegroundColor Cyan
        Write-Host "   • API (номера): http://localhost:8000/rooms/list/" -ForegroundColor Cyan
        Write-Host "   • База данных: localhost:5432" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "📋 Команды:" -ForegroundColor Yellow
        Write-Host "   • .\docker-commands.ps1 stop    - остановить" -ForegroundColor Gray
        Write-Host "   • .\docker-commands.ps1 logs    - логи" -ForegroundColor Gray
        Write-Host "   • .\docker-commands.ps1 migrate - миграции" -ForegroundColor Gray
    }

    "stop" {
        Show-Header
        Write-Host "🛑 Остановка проекта..." -ForegroundColor Yellow
        docker-compose down
        Write-Host "✅ Проект остановлен" -ForegroundColor Green
    }

    "restart" {
        Show-Header
        Write-Host "🔄 Перезапуск проекта..." -ForegroundColor Green
        docker-compose down
        docker-compose up --build -d
        Write-Host "✅ Проект перезапущен" -ForegroundColor Green
    }

    "logs" {
        docker-compose logs
    }

    "logs-f" {
        docker-compose logs -f
    }

    "migrate" {
        Show-Header
        Write-Host "🗄️  Выполнение миграций..." -ForegroundColor Green
        docker-compose exec web python manage.py migrate
    }

    "makemigrations" {
        Show-Header
        Write-Host "📝 Создание миграций..." -ForegroundColor Green
        docker-compose exec web python manage.py makemigrations
    }

    "createsuperuser" {
        Show-Header
        Write-Host "👑 Создание суперпользователя..." -ForegroundColor Green
        docker-compose exec web python manage.py createsuperuser
    }

    "shell" {
        docker-compose exec web python manage.py shell
    }

    "dbshell" {
        Show-Header
        Write-Host "🗄️  Подключение к PostgreSQL..." -ForegroundColor Green
        docker-compose exec db psql -U postgres -d postgres
    }

    "status" {
        Show-Header
        Write-Host "📊 Статус контейнеров:" -ForegroundColor Yellow
        docker-compose ps

        Write-Host "`n🌐 Проверка API:" -ForegroundColor Yellow
        try {
            $response = Invoke-RestMethod -Uri "http://localhost:8000/rooms/list/" -TimeoutSec 3
            Write-Host "   ✅ API работает!" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ API не отвечает" -ForegroundColor Red
        }
    }

    "clean" {
        Show-Header
        Write-Host "🧹 Очистка Docker..." -ForegroundColor Red
        docker-compose down -v
        docker system prune -f
        Write-Host "✅ Очистка завершена" -ForegroundColor Green
    }

    "test-api" {
        Show-Header
        Write-Host "🧪 Тестирование API..." -ForegroundColor Green

        # Создаем номер
        Write-Host "1. Создаем тестовый номер..." -ForegroundColor Yellow
        $body = '{"description":"Docker Test Room", "price_per_night":10000}'
        try {
            $response = Invoke-RestMethod -Uri "http://localhost:8000/rooms/create/" -Method Post -Body $body -ContentType "application/json"
            Write-Host "   ✅ Создан номер ID: $($response.room_id)" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ Ошибка: $_" -ForegroundColor Red
        }

        # Получаем список
        Write-Host "2. Получаем список номеров..." -ForegroundColor Yellow
        try {
            $response = Invoke-RestMethod -Uri "http://localhost:8000/rooms/list/"
            Write-Host "   ✅ Найдено номеров: $($response.Count)" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ Ошибка: $_" -ForegroundColor Red
        }
    }

    default {
        Show-Header
        Write-Host "Использование: .\docker-commands.ps1 <команда>" -ForegroundColor White
        Write-Host ""
        Write-Host "Основные команды:" -ForegroundColor Yellow
        Write-Host "  start            - запустить проект" -ForegroundColor Cyan
        Write-Host "  stop             - остановить проект" -ForegroundColor Cyan
        Write-Host "  restart          - перезапустить проект" -ForegroundColor Cyan
        Write-Host "  status           - показать статус" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Управление данными:" -ForegroundColor Yellow
        Write-Host "  migrate          - выполнить миграции" -ForegroundColor Gray
        Write-Host "  makemigrations   - создать миграции" -ForegroundColor Gray
        Write-Host "  createsuperuser  - создать админа" -ForegroundColor Gray
        Write-Host "  shell            - Django shell" -ForegroundColor Gray
        Write-Host "  dbshell          - PostgreSQL shell" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Мониторинг:" -ForegroundColor Yellow
        Write-Host "  logs             - просмотр логов" -ForegroundColor Gray
        Write-Host "  logs-f           - следить за логами" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Тестирование:" -ForegroundColor Yellow
        Write-Host "  test-api         - тест API" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Очистка:" -ForegroundColor Yellow
        Write-Host "  clean            - очистить всё (осторожно!)" -ForegroundColor Red
    }
}