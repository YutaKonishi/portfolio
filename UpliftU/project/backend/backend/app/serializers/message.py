from rest_framework import serializers
from ..models import Message

class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = ["id", "question", "answer", "project", "createdAt", "dueDate", "isCompleted"]