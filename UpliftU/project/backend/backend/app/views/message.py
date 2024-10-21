from ..models import Message
from ..serializers import MessageSerializer
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response

class MessageViewSet(viewsets.ModelViewSet):
    queryset = Message.objects.all()
    serializer_class = MessageSerializer

    # http://127.0.0.1:8000/message/?project_id={project_id}&isCompleted=false
    # http://127.0.0.1:8000/message/?isCompleted=false
    # http://127.0.0.1:8000/message/?project_id={project_id}
    def get_queryset(self):
        queryset = super().get_queryset()
        project = self.request.query_params.get('project_id')
        id = self.request.query_params.get('id')
        is_completed = self.request.query_params.get('isCompleted')

        if id is not None:
            queryset = queryset.filter(id=id)
        if project is not None:
            queryset = queryset.filter(project=project)
        if is_completed is not None:
            is_completed_bool = is_completed.lower() == 'true'
            queryset = queryset.filter(isCompleted=is_completed_bool)

        return queryset

    @action(detail=True, methods=['post'])
    def post_answer(self, request, pk=None):
        message = self.get_object()
        answer = request.data.get('answer')
        is_completed = request.data.get('isCompleted')

        if answer is not None:
            message.answer = answer
            if is_completed is not None:
                message.isCompleted = is_completed
            message.save()
            return Response({'status': 'answer posted and completion status updated'}, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'No answer provided'}, status=status.HTTP_400_BAD_REQUEST)