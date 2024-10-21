import React, { useEffect, useState } from 'react';
import { styled } from '@mui/material/styles';
import { ToUserProfile } from './ToUserProfile';
import NavigateBeforeIcon from '@mui/icons-material/NavigateBefore';
import { Avatar, Box, Button, Typography, Paper } from '@mui/material';
import SentimentSatisfiedAltIcon from '@mui/icons-material/SentimentSatisfiedAlt';
import FavoriteIcon from '@mui/icons-material/Favorite';
import CurrencyYenIcon from '@mui/icons-material/CurrencyYen';
import ShoppingBasketIcon from '@mui/icons-material/ShoppingBasket';
import VolunteerActivismIcon from '@mui/icons-material/VolunteerActivism';
import AnswerForm from './AnswerForm';
import { useNavigate, useParams } from 'react-router-dom';
import { fetchGPTResponse } from './fetchGPTResponse'; // 関数をインポート

const Base = styled('div')({
  width: "100vw",
  minHeight: "100vh",
  backgroundColor: '#fff',
});

const Title = styled('div')({
  paddingTop: '20vw',
  marginLeft: '5vw',
  fontSize: "22.5px",
  fontWeight: "bold"
});

const ProfileContainer = styled(Paper)({
  paddingTop: '10px',
  borderRadius: '15px',
  backgroundColor: '#fff',
  margin: '20px',
  display: 'flex',
  alignItems: 'center',
  gap: '15px',
});

const InfoBox = styled(Box)({
  display: 'flex',
  flexDirection: 'column',
  width: '40vw',
});

const Tag = styled(Box)<{ bgcolor: string }>(({ bgcolor }) => ({
  backgroundColor: bgcolor || '#e0e0e0',
  color: '#333',
  borderRadius: '15px',
  padding: '5px 15px',
  display: 'inline-block',
  marginRight: '10px',
  fontWeight: 'bold',
  fontSize: '12.5px',
}));

const ProjectInfo = styled(Box)({
  margin: '7.5vw',
});

const InfoPaper = styled(Paper)({
  borderRadius: '15px',
  display: 'flex',
  flexDirection: 'column',
  backgroundColor: '#fff',
  marginBottom: '20px',
});

const InfoRow = styled(Box)({
  display: 'flex',
  justifyContent: 'space-between',
  width: '100%',
  marginTop: '10px',
});

const QuestionLog = styled('div')({
  padding: '7.5vw',
});

const QuestionBox = styled('div')({
  backgroundColor: '#ddd',
  padding: '7.5px 15px',
  borderRadius: '0px 20px 20px 20px',
  marginBottom: '10px',
  width: '50vw',
  fontSize: '15px',
});

const AnswerBox = styled('div')({
  backgroundColor: '#95D2B3',
  padding: '7.5px 15px',
  borderRadius: '20px 20px 0px 20px',
  marginBottom: '10px',
  fontSize: '15px',
  width: '50vw',
  marginLeft: '35vw',
});

const ButtonArea = styled("div")({
  display: 'flex',
  justifyContent: 'center', // Center the button horizontally
  width: "100vw",
});

interface Project {
  id: string;
  question_amount: number;
  genre: string;
  giftPurchaseDate: string;
  giftGivingDate: string;
  receiver: string;
  project_name: string;
  budget: number;
  present_purpose: string;
  frequency: number;
}

interface Receiver {
  id: string;
  age: number;
  gender: string;
  relationship: string;
  receiver_name: string;
  hobbies: string;
}

interface Message {
  id: string;
  question: string;
  answer: string;
  project: string;
  createdAt: string;
  dueDate: string;
  isCompleted: boolean;
}

const getGenderDisplay = (gender: string): string => {
  switch (gender) {
    case 'M':
      return '男性';
    case 'F':
      return '女性';
    default:
      return '不明';
  }
};

const formatDate = (isoString: string): string => {
  const date = new Date(isoString);
  return `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()}`;
};

const parseDateString = (dateString: string): Date => new Date(dateString);

const calculateDaysLeft = (dueDate: string): number => {
  const dueDateTime = new Date(dueDate).getTime();
  const currentDateTime = new Date().getTime();
  const timeDifference = dueDateTime - currentDateTime;
  return Math.ceil(timeDifference / (1000 * 60 * 60 * 24));
};

const ProjectPage: React.FC = () => {
  const [showAnswerForm, setShowAnswerForm] = useState(false);
  const navigate = useNavigate();
  const [projectsData, setProjectsData] = useState<Project[]>([]);
  const [description, setDescription] = useState<string>('');
  const [daysLeft, setDaysLeft] = useState<number>(3);
  const [receiversData, setReceiversData] = useState<Receiver[]>([]);
  const [messages, setMessages] = useState<Message[]>([]);
  const [currentMessageId, setCurrentMessageId] = useState<string>('');
  const { projectId } = useParams<{ projectId: string }>();

  const fetchData = () => {
    fetch('http://127.0.0.1:8000/project/')
      .then(response => response.json())
      .then(setProjectsData)
      .catch(error => console.error('Error fetching project data:', error));
  
    fetch('http://127.0.0.1:8000/receiver/')
      .then(response => response.json())
      .then(setReceiversData)
      .catch(error => console.error('Error fetching receiver data:', error));
  
    if (projectId) {
      fetch(`http://127.0.0.1:8000/message/?project_id=${projectId}&isCompleted=false`)
        .then(response => response.json())
        .then((messages: Message[]) => {
          console.log('Fetched messages:', messages);
          if (messages.length > 0) {
            console.log('First message question:', messages[0].question);
            setDescription(messages[0].question);
            setCurrentMessageId(messages[0].id);
            setDaysLeft(calculateDaysLeft(messages[0].dueDate));
          }
        })
        .catch(error => console.error('Error fetching messages:', error));
  
      fetch(`http://127.0.0.1:8000/message/?project_id=${projectId}`)
        .then(response => response.json())
        .then((messages: Message[]) => {
          console.log('Fetched messages:', messages);
          setMessages(messages);
        })
        .catch(error => console.error('Error fetching messages:', error));
    }
  };

  useEffect(() => {
    fetchData();
  }, [projectId]);

  console.log('Current description:', description);

  const projectData = projectsData.find(item => item.id === projectId);
  const receiver_id = projectData ? projectData.receiver : "xxx";
  const receiverData = receiversData.find(item => item.id === receiver_id);

  const recipientName_last = receiverData ? receiverData.receiver_name : '';
  const age = receiverData ? receiverData.age : 999;
  const gender = receiverData ? receiverData.gender : 'undefined';
  const hobbies = receiverData ? receiverData.hobbies.split(',') : [];
  const relationship = receiverData ? [receiverData.relationship] : ['不明'];
  const questionsLeft = projectData ? projectData.question_amount - messages.length : 0;
  const daysUntilPurchase = projectData ? Math.ceil((parseDateString(formatDate(projectData.giftPurchaseDate)).getTime() - new Date().getTime()) / (1000 * 3600 * 24)) : -999;
  const purpose = projectData ? projectData.present_purpose : 'XXXXX';
  const budget = projectData ? projectData.budget : -999;
  const purchaseDate = projectData ? formatDate(projectData.giftPurchaseDate) : '20XX/Y/Z';
  const giftDate = projectData ? formatDate(projectData.giftGivingDate) : '20XX/Y/Z';

  return (
    <Base>
      <ToUserProfile />
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
      <Title>{recipientName_last}さんのプロジェクト</Title>
      <Paper sx={{ padding: '15px', borderRadius: '25px', backgroundColor: '#333', margin: '25px' }}>
        <Typography sx={{
          fontSize: '22.5px',
          color: '#fff',
          fontWeight: 'bold',
          marginLeft: '2vw',
        }}>
          本日のミッション
        </Typography>
        <Box sx={{
          display: 'flex',
          alignItems: 'flex-start',
          marginBottom: '10px',
          marginTop: '10px',
        }}>
          <Box>
            <Typography sx={{
              fontWeight: "bold",
              fontSize: '17.5px',
              color: '#fff',
              width: '15vw',
              marginLeft: '2vw',
              lineHeight: '25px',
            }}>
              質問
            </Typography>
          </Box>
          <Box>
            <Typography sx={{
              fontSize: '17.5px',
              lineHeight: '25px',
              color: '#fff',
            }}>
              {description}
            </Typography>
          </Box>
        </Box>
        <Box sx={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginTop: '2vw',
          backgroundColor: '#76ABAE',
          borderRadius: '20px',
          padding: '12.5px 30px',
        }}>
          <Typography sx={{
            fontWeight: 'bold',
            fontSize: '15px',
            color: '#333',
          }}>
            次の質問まで<br />あと {daysLeft} 日
          </Typography>
          <Button
            variant="contained"
            sx={{
              backgroundColor: '#eee',
              color: '#333',
              borderRadius: '15px',
              fontSize: '15px',
              padding: '2.5px 30px',
              fontWeight: "bold",
            }}
            onClick={() => setShowAnswerForm(true)}
          >
            回答を入力
          </Button>
        </Box>
      </Paper>
      {showAnswerForm && <AnswerForm description={description} onClose={() => { setShowAnswerForm(false); fetchData(); }} id={currentMessageId} />}
      <ProfileContainer elevation={0}>
        <SentimentSatisfiedAltIcon sx={{ width: '17.5vw', height: '17.5vw' }} />
        <InfoBox>
          <Typography sx={{ fontWeight: 'bold', fontSize: '17.5px' }}>{recipientName_last} さん</Typography>
          <Typography sx={{ fontWeight: 'bold', fontSize: '17.5px' }}>{age}歳, {getGenderDisplay(gender)}</Typography>
        </InfoBox>
      </ProfileContainer>
      <Box sx={{ display: 'flex', alignItems: 'center', marginBottom: '10px' }}>
        <Typography sx={{
          fontWeight: 'bold',
          marginLeft: '7.5vw',
          fontSize: '17.5px',
          width: '20vw',
        }}>趣味</Typography>
        {hobbies.map((hobby, index) => (
          <Tag key={index} bgcolor="#E8F183">{hobby}</Tag>
        ))}
      </Box>
      <Box sx={{ display: 'flex', alignItems: 'center' }}>
        <Typography sx={{
          fontWeight: 'bold',
          marginLeft: '7.5vw',
          fontSize: '17.5px',
          width: '20vw',
        }}>関係性</Typography>
        {relationship.map((person, index) => (
          <Tag key={index} bgcolor="#9EA1D4">{person}</Tag>
        ))}
      </Box>
      <ProjectInfo>
        <Typography sx={{ fontWeight: 'bold', fontSize: '22.5px', marginBottom: '20px' }}>プロジェクト情報</Typography>
        <InfoRow>
          <InfoPaper elevation={0} sx={{
            backgroundColor: '#A8D1D1',
            width: '40vw',
            marginRight: '20px',
          }}>
            <Typography sx={{
              fontSize: '12.5px',
              fontWeight: 'bold',
              textAlign: 'left',
              paddingTop: '15px',
              paddingLeft: '12.5px',
              color: '#333',
            }}>残り質問数</Typography>
            <Typography sx={{
              fontSize: '15px',
              textAlign: 'right',
              fontWeight: 'bold',
              paddingRight: '15px',
              color: '#333',
            }}>あと <span style={{ fontSize: '40px' }}>{questionsLeft}</span> 回</Typography>
          </InfoPaper>
          <InfoPaper elevation={0} sx={{
            backgroundColor: '#FD8A8A',
            width: '40vw',
          }}>
            <Typography sx={{
              fontSize: '12.5px',
              fontWeight: 'bold',
              textAlign: 'left',
              paddingTop: '15px',
              paddingLeft: '12.5px',
              color: '#333',
            }}>プレゼント購入まで</Typography>
            <Typography sx={{
              fontSize: '15px',
              textAlign: 'right',
              fontWeight: 'bold',
              paddingRight: '15px',
              color: '#333',
            }}>あと <span style={{ fontSize: '40px' }}>{daysUntilPurchase}</span> 日</Typography>
          </InfoPaper>
        </InfoRow>
        <InfoRow>
          <InfoBox>
            <InfoItem1 label="目的" value={purpose} />
          </InfoBox>
          <InfoBox>
            <InfoItem2 label="予算" value={`${budget} 円`} />
          </InfoBox>
        </InfoRow>
        <InfoRow>
          <InfoBox>
            <InfoItem3 label="購入予定日" value={purchaseDate} />
          </InfoBox>
          <InfoBox>
            <InfoItem4 label="渡す日" value={giftDate} />
          </InfoBox>
        </InfoRow>
      </ProjectInfo>
      <QuestionLog>
        <Typography sx={{ fontWeight: 'bold', fontSize: '22.5px', marginBottom: '20px' }}>質問履歴</Typography>
        {messages
          .sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()) // 最新のメッセージが下にくるようにソート
          .map(message => (
            <React.Fragment key={message.id}>
              <QuestionBox>{message.question}</QuestionBox>
              {message.answer && <AnswerBox>{message.answer}</AnswerBox>}
            </React.Fragment>
          ))}
      </QuestionLog>
      <ButtonArea>
        <Button
          sx={{
            backgroundColor: "#FD8A8A",
            fontSize: "14px",
            fontWeight: "bold",
            color: "#333",
            borderRadius: "20px",
            padding: "9px 30px",
            marginBottom: '7.5vw'
          }}
          onClick={() => navigate(`/gift_suggestion/${projectId}`)}
        >
          回答の生成
        </Button>
      </ButtonArea>
    </Base>
  );
};

interface InfoItemProps {
  label: string;
  value: string;
}

//目的
const InfoItem1: React.FC<InfoItemProps> = ({ label, value }) => (
  <Box sx={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
    <FavoriteIcon sx={{
      width: '40px',
      height: '40px',
      backgroundColor: '#ffffff',
      marginRight: '10px'
    }} />
    <Box>
      <Typography sx={{ fontSize: '15px', fontWeight: 'bold', color: '#333' }}>{label}</Typography>
      <Typography sx={{ fontSize: '17.5px', fontWeight: 'bold', color: '#333' }}>{value}</Typography>
    </Box>
  </Box>
);

//予算
const InfoItem2: React.FC<InfoItemProps> = ({ label, value }) => (
  <Box sx={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
    <CurrencyYenIcon sx={{
      width: '40px',
      height: '40px',
      backgroundColor: '#ffffff',
      marginRight: '10px'
    }} />
    <Box>
      <Typography sx={{ fontSize: '15px', fontWeight: 'bold', color: '#333' }}>{label}</Typography>
      <Typography sx={{ fontSize: '17.5px', fontWeight: 'bold', color: '#333' }}>{value}</Typography>
    </Box>
  </Box>
);

//購入予定日
const InfoItem3: React.FC<InfoItemProps> = ({ label, value }) => (
  <Box sx={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
    <ShoppingBasketIcon sx={{
      width: '40px',
      height: '40px',
      backgroundColor: '#ffffff',
      marginRight: '10px'
    }} />
    <Box>
      <Typography sx={{ fontSize: '15px', fontWeight: 'bold', color: '#333' }}>{label}</Typography>
      <Typography sx={{ fontSize: '17.5px', fontWeight: 'bold', color: '#333' }}>{value}</Typography>
    </Box>
  </Box>
);

//渡す日
const InfoItem4: React.FC<InfoItemProps> = ({ label, value }) => (
  <Box sx={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
    <VolunteerActivismIcon sx={{
      width: '40px',
      height: '40px',
      backgroundColor: '#ffffff',
      marginRight: '10px'
    }} />
    <Box>
      <Typography sx={{ fontSize: '15px', fontWeight: 'bold', color: '#333' }}>{label}</Typography>
      <Typography sx={{ fontSize: '17.5px', fontWeight: 'bold', color: '#333' }}>{value}</Typography>
    </Box>
  </Box>
);


export default ProjectPage;
