import { styled } from '@mui/material/styles';
import { Avatar } from '@mui/material';
import { useNavigate } from 'react-router-dom';
// import ArrowForwardIosIcon from '@mui/icons-material/ArrowForwardIos';

type Props = {
  projectId: number;
  name: string;
  progress: number;
};

const Bar = styled('div')({
  display: 'flex',
  alignItems: 'center',
  width: "45vw",
  height: "15vw",
  backgroundColor: "#ddd",
  borderRadius: "15px",
  margin: "auto",
  marginLeft: "2.5vw",
  marginRight: "1vw",
  marginTop: "1vw",
  marginBottom: "1vw",
  cursor: 'pointer',

});

const ProgressContainer = styled('div')({
  display: 'flex',
  flexDirection: 'column',
  width: '65%',
  // width: '100%',
  marginLeft: '2vw',
  marginRight:'2vw',
});

const ProjectName = styled('div')({
  fontWeight: 'bold',
  fontSize: '12.5px',
});

// const ProgressBar = styled('div')({
//   width: '100%',
//   height: '3.5vw',
//   backgroundColor: '#eee',
//   borderRadius: '10px',
//   overflow: 'hidden',
//   marginTop: '1vw',
// });

// const Progress = styled('div')<{ progress: number }>(({ progress }) => ({
//   width: `${progress}%`,
//   height: '100%',
//   backgroundColor: '#797EC2',
//   borderRadius: '10px 10px 10px 10px',
// }));

export const CompletedProjectButton: React.FC<Props> = ({ projectId, name }) => {
  const navigate = useNavigate();

  const handleClick = () => {
    navigate(`/project_done/${projectId}`);
  };
  return (
    <Bar onClick={handleClick}>
      <Avatar sx={{
        bgcolor: '#333',
        width: '10vw',
        height: '10vw',
        marginLeft: '2.5vw',
      }} />

      <ProgressContainer>
        <ProjectName>{name}</ProjectName>
      </ProgressContainer>

      {/* <ArrowForwardIosIcon sx={{
        fontSize: "small",
        color: '#333',
        marginLeft: '5vw',
      }}/> */}
    </Bar>
  );
};

export default CompletedProjectButton;