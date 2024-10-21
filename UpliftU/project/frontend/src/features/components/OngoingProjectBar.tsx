import React, { useEffect, useState } from 'react';
import { styled } from '@mui/material/styles';
import { useNavigate } from 'react-router-dom';
import ArrowForwardIosIcon from '@mui/icons-material/ArrowForwardIos';
import axios from 'axios';
import dayjs from 'dayjs';
import pic from './src/pic.png'; // 画像をインポート
import pic2 from './src/pic2.jpg';
// import pic3 from './src/pic3.jpeg';

type Props = {
  projectId: number;
  name: string;
  progress: number;
};

const Bar = styled('div')<{ isFlashing: boolean }>(({ isFlashing }) => ({
  display: 'flex',
  alignItems: 'center',
  width: "90vw",
  height: "17.5vw",
  backgroundColor: "#ddd",
  borderRadius: "15px",
  margin: "auto",
  marginTop: "2.5vw",
  marginBottom: "2vw",
  cursor: 'pointer',
  animationName: isFlashing ? 'flashing' : 'none',
  animationDuration: '2.4s',
  animationTimingFunction: 'linear',
  animationFillMode: 'forwards',
  animationIterationCount: 'infinite',
}));

const ProgressContainer = styled('div')({
  display: 'flex',
  flexDirection: 'column',
  width: '65%',
  marginLeft: '4vw',
});

const ProjectName = styled('div')({
  fontWeight: 'bold',
  fontSize: '13px',
});

const ProgressBar = styled('div')({
  width: '100%',
  height: '3.5vw',
  backgroundColor: '#eee',
  borderRadius: '10px',
  overflow: 'hidden',
  marginTop: '1vw',
});

const Progress = styled('div')<{ progress: number }>(({ progress }) => ({
  width: `${progress}%`,
  height: '100%',
  backgroundColor: '#797EC2',
  borderRadius: '10px 10px 10px 10px',
}));

const OngoingProjectBar: React.FC<Props> = ({ projectId, name }) => {
  const navigate = useNavigate();
  const [progress, setProgress] = useState(0);
  const [isFlashing, setIsFlashing] = useState(false);
  const [imageSrc, setImageSrc] = useState<string>(pic);

  useEffect(() => {
    const images = [pic, pic2];
    const randomImage = images[Math.floor(Math.random() * images.length)];
    setImageSrc(randomImage);

    const fetchData = async () => {
      try {
        // Fetch question amount
        const projectResponse = await axios.get(`http://127.0.0.1:8000/project/?project_id=${projectId}`);
        const questionAmount = projectResponse.data[0]?.question_amount;

        // Fetch the number of questions asked
        const questionsResponse = await axios.get(`http://127.0.0.1:8000/message/?project_id=${projectId}`);
        const questions = questionsResponse.data;
        const questionsAsked = questions.length;

        // Calculate progress
        const calculatedProgress = questionAmount ? (questionsAsked / questionAmount) * 100 : 0;
        setProgress(calculatedProgress);

        // Fetch incomplete messages
        const incompleteQuestionsResponse = await axios.get(`http://127.0.0.1:8000/message/?project_id=${projectId}&isCompleted=false`);
        const incompleteDueDates = incompleteQuestionsResponse.data.map((question: any) => question.dueDate);
        console.log(incompleteDueDates);

        // Check if there are any incomplete questions with dueDate within 3 days
        const now = dayjs();
        const hasDueSoonQuestions = incompleteDueDates.some((dueDate: string) => {
          const diffDays = dayjs(dueDate).diff(now, 'day');
          console.log('しり', diffDays);
          return diffDays <= 2;
        });

        if (hasDueSoonQuestions) {
          setIsFlashing(true);
        }

      } catch (error) {
        console.error('Error fetching data:', error);
      }
    };

    fetchData();
  }, [projectId]);

  const handleClick = () => {
    navigate(`/project/${projectId}`);
  };

  return (
    <Bar isFlashing={isFlashing} onClick={handleClick}>
      <img
        src={imageSrc}
        alt="Project Avatar"
        style={{
          width: '10vw',
          height: '10vw',
          marginLeft: '5vw',
          borderRadius: '50%',
        }}
      />
      <ProgressContainer>
        <ProjectName>{name}</ProjectName>
        <ProgressBar>
          <Progress progress={progress} />
        </ProgressBar>
      </ProgressContainer>
      <ArrowForwardIosIcon sx={{
        fontSize: "small",
        color: '#333',
        marginLeft: '5vw',
      }}/>
    </Bar>
  );
};

export default OngoingProjectBar;

// CSS for the animation
const styleElement = document.createElement('style');
styleElement.textContent = `
@keyframes flashing {
  0% {
    background-color: #9bf6ff;
  }
  50% {
    background-color: #a0c4ff;
  }
  100% {
    background-color: #9bf6ff;
  }
}
`;
document.head.appendChild(styleElement);
