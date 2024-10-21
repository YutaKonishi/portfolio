from ..models import Project
from ..serializers import ProjectSerializer
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action

class ProjectViewSet(viewsets.ModelViewSet):
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer

    # http://127.0.0.1:8000/project/?is_completed={true/false}
    # http://127.0.0.1:8000/project/?project_id={project_id} 
    # http://127.0.0.1:8000/project/?user_id={user_id} 
    def get_queryset(self):
        queryset = super().get_queryset()
        project = self.request.query_params.get('project_id')
        is_completed = self.request.query_params.get('is_completed')
        user_id = self.request.query_params.get('user_id')

        if project is not None:
            queryset = queryset.filter(id=project)
        
        if is_completed is not None:
            is_completed_bool = is_completed.lower() == 'true'
            queryset = queryset.filter(isCompleted=is_completed_bool)

        if user_id is not None:
            queryset = queryset.filter(user_id=user_id)

        return queryset

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def perform_create(self, serializer):
        serializer.save()

    @action(detail=True, methods=['patch'], url_path='update-fields')
    def update_fields(self, request, pk=None):
        try:
            project = self.get_object()
            present = request.data.get('present')
            is_completed = request.data.get('isCompleted')
            prompt = request.data.get('prompt')

            if present is not None:
                project.present = present

            if is_completed is not None:
                project.isCompleted = is_completed

            if prompt is not None:
                project.prompt = prompt

            project.save()
            return Response({'status': 'fields updated'}, status=status.HTTP_200_OK)
        except Project.DoesNotExist:
            return Response({'error': 'Project not found'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
