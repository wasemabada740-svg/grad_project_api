from django.urls import path
from .views import chat


urlpatterns = [
    path('analytics/', chat, name='chat'),
]