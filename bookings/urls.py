from django.urls import path
from . import views

urlpatterns = [
    path('rooms/create/', views.HotelRoomCreateView.as_view(), name='room-create'),
    path('rooms/delete/<int:room_id>/', views.HotelRoomDeleteView.as_view(), name='room-delete'),
    path('rooms/list/', views.HotelRoomListView.as_view(), name='room-list'),
    path('booking/create/', views.BookingCreateView.as_view(), name='booking-create'),
    path('booking/delete/<int:booking_id>/', views.BookingDeleteView.as_view(), name='booking-delete'),
    path('bookings/list/', views.BookingListView.as_view(), name='booking-list'),
]