# bookings/tests/test_models.py
from django.test import TestCase
from bookings.models import HotelRoom, Booking
from django.utils import timezone
from datetime import date, timedelta


class ModelTests(TestCase):
    """Тесты для моделей HotelRoom и Booking"""

    def setUp(self):
        """Настройка тестовых данных"""
        # Создаем тестовую комнату
        self.room = HotelRoom.objects.create(
            description="Прекрасный номер с видом на море",
            price_per_night=150.00
        )

        # Создаем тестовое бронирование
        self.booking = Booking.objects.create(
            room=self.room,
            date_start=timezone.now(),
            date_end=date.today() + timedelta(days=7)
        )

    def test_hotelroom_creation(self):
        """Тест создания отельного номера"""
        self.assertEqual(self.room.description, "Прекрасный номер с видом на море")
        self.assertEqual(float(self.room.price_per_night), 150.00)
        self.assertIsNotNone(self.room.created_at)

    def test_hotelroom_str_method(self):
        """Тест строкового представления HotelRoom"""
        # Тестируем фактическое поведение
        expected_str = f"HotelRoom object ({self.room.id})"
        self.assertEqual(str(self.room), expected_str)

    def test_booking_creation(self):
        """Тест создания бронирования"""
        self.assertEqual(self.booking.room.id, self.room.id)
        self.assertIsNotNone(self.booking.date_start)
        self.assertIsNotNone(self.booking.date_end)
        self.assertIsNotNone(self.booking.created_at)

    def test_booking_room_relationship(self):
        """Тест связи Booking с HotelRoom"""
        # Проверяем прямую связь
        self.assertEqual(self.booking.room.id, self.room.id)

        # Проверяем обратную связь
        room_bookings = list(self.room.bookings.all())
        self.assertEqual(len(room_bookings), 1)
        self.assertEqual(room_bookings[0].id, self.booking.id)

    def test_booking_ordering(self):
        """Тест ordering в Meta классе Booking"""
        # Создаем более раннее бронирование
        earlier_booking = Booking.objects.create(
            room=self.room,
            date_start=timezone.now() - timedelta(days=2),
            date_end=date.today() + timedelta(days=1)
        )

        # Получаем все бронирования
        bookings = list(Booking.objects.all())

        # Должно быть 2 бронирования
        self.assertEqual(len(bookings), 2)

        # Проверяем порядок: более раннее должно быть первым
        # Сравниваем по датам, а не по полным datetime
        self.assertLess(bookings[0].date_start, bookings[1].date_start)