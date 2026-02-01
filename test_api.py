import requests
import json

BASE_URL = "http://localhost:8000"


def test_create_room():
    print("1. Создаем номер отеля...")
    response = requests.post(
        f"{BASE_URL}/rooms/create/",
        json={"description": "Люкс с видом на море", "price_per_night": 15000}
    )
    print(f"   Ответ: {response.json()}")
    return response.json().get('room_id')


def test_list_rooms():
    print("\n2. Получаем список номеров...")
    response = requests.get(f"{BASE_URL}/rooms/list/")
    print(f"   Ответ: {response.json()}")
    return response.json()


def test_create_booking(room_id):
    print(f"\n3. Создаем бронирование для комнаты {room_id}...")
    response = requests.post(
        f"{BASE_URL}/booking/create/",
        json={
            "room_id": room_id,
            "date_start": "2024-01-15",
            "date_end": "2024-01-20"
        }
    )
    print(f"   Ответ: {response.json()}")
    return response.json().get('booking_id')


def test_list_bookings(room_id):
    print(f"\n4. Получаем бронирования для комнаты {room_id}...")
    response = requests.get(f"{BASE_URL}/bookings/list/?room_id={room_id}")
    print(f"   Ответ: {response.json()}")


if __name__ == "__main__":
    print("🚀 Начинаем тестирование API...")

    # Создаем номер
    room_id = test_create_room()

    # Получаем список номеров
    test_list_rooms()

    # Создаем бронирование
    if room_id:
        booking_id = test_create_booking(room_id)

        # Получаем список бронирований
        test_list_bookings(room_id)

    print("\n✅ Тестирование завершено!")