# bookings/tests/test_basic.py
from django.test import TestCase
from bookings.models import HotelRoom, Booking
from django.utils import timezone
from datetime import date, timedelta


class BasicTests(TestCase):
    """Базовые тесты для проверки окружения"""

    def test_database_connection(self):
        """Тест подключения к базе данных"""
        from django.db import connection
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            result = cursor.fetchone()
            self.assertEqual(result[0], 1)

    def test_can_create_models(self):
        """Тест создания моделей"""
        # Создаем комнату
        room = HotelRoom.objects.create(
            description='Базовый тестовый номер',
            price_per_night=99.99
        )
        self.assertIsNotNone(room.id)

        # Создаем бронирование
        booking = Booking.objects.create(
            room=room,
            date_start=timezone.now(),
            date_end=date.today() + timedelta(days=2)
        )
        self.assertIsNotNone(booking.id)

        # Проверяем связи
        self.assertEqual(booking.room.id, room.id)
        self.assertIn(booking, room.bookings.all())

    def test_model_count(self):
        """Тест подсчета объектов"""
        initial_rooms = HotelRoom.objects.count()
        initial_bookings = Booking.objects.count()

        # Создаем новые объекты
        HotelRoom.objects.create(
            description='Еще один номер',
            price_per_night=150.00
        )

        self.assertEqual(HotelRoom.objects.count(), initial_rooms + 1)
        self.assertEqual(Booking.objects.count(), initial_bookings)