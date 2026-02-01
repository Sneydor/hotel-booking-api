# test_api_fixed.ps1 - Исправленная версия с кодировкой

function Send-Request {
    param(
        [string]$Uri,
        [string]$Method = "Get",
        [object]$Body = $null,
        [string]$ContentType = "application/json"
    )

    $params = @{
        Uri = $Uri
        Method = $Method
        ContentType = $ContentType
    }

    if ($Body) {
        # Конвертируем тело в правильную кодировку
        if ($Body -is [string]) {
            $utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($Body)
            $params.Body = [System.Text.Encoding]::UTF8.GetString($utf8Bytes)
        } else {
            $json = $Body | ConvertTo-Json -Compress
            $utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
            $params.Body = [System.Text.Encoding]::UTF8.GetString($utf8Bytes)
        }
    }

    try {
        $response = Invoke-RestMethod @params
        return $response
    } catch {
        Write-Host "   Ошибка: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

Write-Host "🚀 Тестируем Hotel Booking API (исправленная версия)..." -ForegroundColor Green
Write-Host ""

# 1. Проверяем сервер
Write-Host "1. Проверяем доступность сервера..." -ForegroundColor Yellow
$rooms = Send-Request -Uri "http://localhost:8000/rooms/list/"
if ($rooms -ne $null) {
    Write-Host "   ✅ Сервер работает!" -ForegroundColor Green
} else {
    Write-Host "   ❌ Сервер не отвечает!" -ForegroundColor Red
    exit
}

# 2. Создаем номера (с английским текстом для простоты)
Write-Host "`n2. Создаем номера отеля..." -ForegroundColor Yellow

# Номер 1 - на английском
$body1 = @{
    description = "Luxury sea view room"
    price_per_night = 15000
}

$room1 = Send-Request -Uri "http://localhost:8000/rooms/create/" -Method Post -Body $body1
if ($room1) {
    Write-Host "   Создан номер ID: $($room1.room_id)" -ForegroundColor Cyan
}

# Номер 2
$body2 = @{
    description = "Standard room"
    price_per_night = 5000
}

$room2 = Send-Request -Uri "http://localhost:8000/rooms/create/" -Method Post -Body $body2
if ($room2) {
    Write-Host "   Создан номер ID: $($room2.room_id)" -ForegroundColor Cyan
}

# 3. Получаем список номеров
Write-Host "`n3. Получаем список всех номеров..." -ForegroundColor Yellow
$rooms = Send-Request -Uri "http://localhost:8000/rooms/list/"
if ($rooms) {
    Write-Host "   Всего номеров: $($rooms.Count)"
    foreach ($room in $rooms) {
        Write-Host "   - ID $($room.id): $($room.description) ($$($room.price_per_night)/ночь)"
    }
}

# 4. Создаем бронирование
Write-Host "`n4. Создаем бронирование..." -ForegroundColor Yellow
$bookingBody = @{
    room_id = 1
    date_start = "2024-01-15"
    date_end = "2024-01-20"
}

$booking = Send-Request -Uri "http://localhost:8000/booking/create/" -Method Post -Body $bookingBody
if ($booking) {
    Write-Host "   Создано бронирование ID: $($booking.booking_id)" -ForegroundColor Cyan
}

# 5. Получаем бронирования
Write-Host "`n5. Получаем бронирования для номера 1..." -ForegroundColor Yellow
$bookings = Send-Request -Uri "http://localhost:8000/bookings/list/?room_id=1"
if ($bookings) {
    Write-Host "   Бронирований: $($bookings.Count)"
    foreach ($b in $bookings) {
        Write-Host "   - Бронирование $($b.booking_id): с $($b.date_start) по $($b.date_end)"
    }
}

Write-Host "`n✅ Тестирование завершено!" -ForegroundColor Green