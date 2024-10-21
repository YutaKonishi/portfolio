import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { ToUserProfile } from './ToUserProfile';
import { CompletedProjectButton } from './CompletedProjectButton';
import { styled } from '@mui/material/styles';
import NavigateBeforeIcon from '@mui/icons-material/NavigateBefore';
import { useNavigate, useParams } from 'react-router-dom';

const Base = styled('div')({
  backgroundColor: "#fff",
  width: '100vw',
  height: '100vh',
});

const CompletedProjectArea = styled('div')({
  height: '18vw',
  display: 'flex',
  flexWrap: 'wrap',
  justifyContent: 'flex-start', // 左对齐
  gap: '0vw', // 按钮之间的间距
});

const CompletedProject = styled('div')({
  fontSize: '22.5px',
  fontWeight: 'bold',
  color: '#333333',
  paddingLeft: "5vw",
  marginTop: "20vw",
  marginBottom: "2.5vw",
});

const StyledCompletedProjectButton = styled(CompletedProjectButton)({
  width: 'calc(50%)', // 每个按钮占据50%的宽度减去间距的一半
  boxSizing: 'border-box',
  margin: '0.5vw', // 这里添加按钮的外边距，以确保按钮之间有一定的间距
});

export const SNSField: React.FC = () => {
  const [completedProjects, setCompletedProjects] = useState([]);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchProjects = async () => {
      try {
        const completedResponse = await axios.get('http://127.0.0.1:8000/project/?is_completed=true');
        setCompletedProjects(completedResponse.data);
      } catch (error) {
        console.error('Failed to fetch projects:', error);
      }
    };

    fetchProjects();
  }, []);

  return (
    <Base>
      <ToUserProfile/>
      <NavigateBeforeIcon
        sx={{
          fontSize: "large",
          color: '#333',
          position: 'fixed',
          left: '10vw',
          top: '7.5vw',
        }}
        onClick={() => navigate('/')}
      />
      <CompletedProject>
        完了したプロジェクト
      </CompletedProject>
      <CompletedProjectArea>
        {completedProjects.map((project: any) => (
          <StyledCompletedProjectButton
            key={project.id}
            projectId={project.id}
            name={project.project_name}
            progress={project.progress}
          />
        ))}
      </CompletedProjectArea>
    </Base>
  );
};

export default SNSField;
