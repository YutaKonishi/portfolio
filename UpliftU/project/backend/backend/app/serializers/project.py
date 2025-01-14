from rest_framework import serializers
from ..models import Project

class ProjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Project
        fields = ["id", "question_amount", "genre", "giftPurchaseDate", "giftGivingDate", "receiver", "project_name", "budget", "present_purpose", "frequency", "isCompleted", "remark", "user_id", "present", "prompt"]