from ..models import Receiver
from ..serializers import ReceiverSerializer
from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework import status

class ReceiverViewSet(viewsets.ModelViewSet):
    queryset = Receiver.objects.all()
    serializer_class = ReceiverSerializer

    # http://127.0.0.1:8000/receiver/?receiver_id={receiver_id}
    # http://127.0.0.1:8000/receiver/?user_id={user_id}
    def get_queryset(self):
        queryset = super().get_queryset()
        receiver_id = self.request.query_params.get('receiver_id')
        user_id = self.request.query_params.get('user_id')
        
        if receiver_id is not None:
            queryset = queryset.filter(id=receiver_id)
        
        if user_id is not None:
            queryset = queryset.filter(user_id=user_id)
        
        return queryset

    # 新しいデータをポストできるようにする
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def perform_create(self, serializer):
        serializer.save()

