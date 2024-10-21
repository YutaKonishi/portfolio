from django.db import models
from .project import Project
import uuid


class Message(models.Model):
    id : models.UUIDField = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    question : models.CharField = models.CharField(max_length=1024, help_text="問題")
    answer : models.CharField = models.CharField(max_length=1024, default="", help_text="gpt答え", null=True, blank=True)
    project : models.ForeignKey = models.ForeignKey(Project, on_delete=models.PROTECT, help_text="対話", related_name="message")
    createdAt: models.DateTimeField = models.DateTimeField(help_text="作成日")
    dueDate: models.DateTimeField = models.DateTimeField(help_text="締め切り")
    isCompleted: models.BooleanField = models.BooleanField(help_text="完了フラグ")
