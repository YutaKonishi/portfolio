from django.db import models
from .receiver import Receiver
import uuid
from users.models import CustomUser

class Project(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    question_amount = models.PositiveIntegerField(help_text="問題数")
    genre = models.CharField(max_length=1024, default="", help_text="ジャンル")
    giftPurchaseDate = models.DateTimeField(help_text="プレゼント買う日")
    giftGivingDate = models.DateTimeField(help_text="プレゼント贈る日")
    receiver = models.ForeignKey(Receiver, on_delete=models.PROTECT, help_text="受け取り手", related_name="project")
    project_name = models.CharField(max_length=255, help_text="プロジェクト名")
    budget = models.PositiveIntegerField(help_text="予算")
    present_purpose = models.CharField(max_length=255, help_text="プレゼントの目的")
    frequency = models.PositiveIntegerField(help_text="頻度")
    isCompleted = models.BooleanField(help_text="完了フラグ")
    remark = models.CharField(max_length=255, help_text="備考欄")
    user_id = models.ForeignKey(CustomUser, on_delete=models.PROTECT, help_text="ユーザID", related_name="project")
    present = models.CharField(max_length=255, null=True, blank=True, help_text="プレゼント")
    prompt = models.CharField(max_length=2048, null=True, blank=True, help_text="プロンプト")
