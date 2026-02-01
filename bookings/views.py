from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.http import JsonResponse
from .models import HotelRoom, Booking
import json


class HotelRoomCreateView(APIView):
    def post(self, request):
        try:
            data = json.loads(request.body)
            room = HotelRoom.objects.create(
                description=data['description'],
                price_per_night=float(data['price_per_night'])
            )
            return Response({'room_id': room.id}, status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class HotelRoomListView(APIView):
    def get(self, request):
        rooms = HotelRoom.objects.all()
        result = []
        for room in rooms:
            result.append({
                'id': room.id,
                'description': room.description,
                'price_per_night': float(room.price_per_night),
                'created_at': room.created_at.isoformat()
            })
        return Response(result)


class HotelRoomDeleteView(APIView):
    def delete(self, request, room_id):
        try:
            room = HotelRoom.objects.get(id=room_id)
            room.delete()
            return Response({'message': f'Room {room_id} deleted'}, status=status.HTTP_200_OK)
        except HotelRoom.DoesNotExist:
            return Response({'error': 'Room not found'}, status=status.HTTP_404_NOT_FOUND)


class BookingCreateView(APIView):
    def post(self, request):
        try:
            data = json.loads(request.body)
            room = HotelRoom.objects.get(id=data['room_id'])
            booking = Booking.objects.create(
                room=room,
                date_start=data['date_start'],
                date_end=data['date_end']
            )
            return Response({'booking_id': booking.id}, status=status.HTTP_201_CREATED)
        except HotelRoom.DoesNotExist:
            return Response({'error': 'Room not found'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class BookingDeleteView(APIView):
    def delete(self, request, booking_id):
        try:
            booking = Booking.objects.get(id=booking_id)
            booking.delete()
            return Response({'message': f'Booking {booking_id} deleted'}, status=status.HTTP_200_OK)
        except Booking.DoesNotExist:
            return Response({'error': 'Booking not found'}, status=status.HTTP_404_NOT_FOUND)


class BookingListView(APIView):
    def get(self, request):
        room_id = request.GET.get('room_id')
        if not room_id:
            return Response({'error': 'room_id parameter is required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            room = HotelRoom.objects.get(id=room_id)
            bookings = room.bookings.all().order_by('date_start')
            result = []
            for booking in bookings:
                result.append({
                    'booking_id': booking.id,
                    'date_start': str(booking.date_start),
                    'date_end': str(booking.date_end)
                })
            return Response(result)
        except HotelRoom.DoesNotExist:
            return Response({'error': 'Room not found'}, status=status.HTTP_404_NOT_FOUND)