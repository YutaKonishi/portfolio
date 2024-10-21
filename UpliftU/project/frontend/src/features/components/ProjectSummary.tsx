import React, { useEffect, useState } from 'react';
import { styled } from '@mui/material/styles';
import { ToUserProfile } from './ToUserProfile';
import NavigateBeforeIcon from '@mui/icons-material/NavigateBefore';
import { Avatar, Box, Typography, Paper } from '@mui/material';
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
  paddingLeft: '7.5vw',
  paddingRight: '7.5vw',
  paddingBottom: '5vw',
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

const PresentBox = styled('div')({
  padding: '7.5px 15px',
  marginBottom: '10px',
  fontSize: '17.5px',
  fontWeight: 'bold',
  width: '100vw',
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
  present?: string;
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

const ProjectSummary: React.FC = () => {
  const [showAnswerForm, setShowAnswerForm] = useState(false);
  const navigate = useNavigate();
  const [projectsData, setProjectsData] = useState<Project[]>([]);
  const [description, setDescription] = useState<string>('');
  const [daysLeft, setDaysLeft] = useState<number>(3);
  const [receiversData, setReceiversData] = useState<Receiver[]>([]);
  const [messages, setMessages] = useState<Message[]>([]);
  const [presentSuggestion, setPresentSuggestion] = useState<string>('');
  const { projectId } = useParams<{ projectId: string }>();

  useEffect(() => {
    fetch('http://127.0.0.1:8000/project/')
      .then(response => response.json())
      .then(setProjectsData)
      .catch(error => console.error('Error fetching project data:', error));
  }, []);

  useEffect(() => {
    fetch('http://127.0.0.1:8000/receiver/')
      .then(response => response.json())
      .then(setReceiversData)
      .catch(error => console.error('Error fetching receiver data:', error));
  }, []);

  useEffect(() => {
    if (projectId) {
      fetch(`http://127.0.0.1:8000/message/?project_id=${projectId}&isCompleted=false`)
        .then(response => response.json())
        .then((messages: Message[]) => {
          console.log('Fetched messages:', messages);
          if (messages.length > 0) {
            console.log('First message question:', messages[0].question);
            setDescription(messages[0].question);
            setDaysLeft(calculateDaysLeft(messages[0].dueDate));
          }
        })
        .catch(error => console.error('Error fetching messages:', error));
    }
  }, [projectId]);

  useEffect(() => {
    if (projectId) {
      fetch(`http://127.0.0.1:8000/message/?project_id=${projectId}`)
        .then(response => response.json())
        .then((messages: Message[]) => {
          console.log('Fetched messages:', messages);
          setMessages(messages);
        })
        .catch(error => console.error('Error fetching messages:', error));
    }
  }, [projectId]);

  useEffect(() => {
    if (projectId) {
      fetch(`http://127.0.0.1:8000/project/?project_id=${projectId}`)
        .then(response => response.json())
        .then((project: Project) => {
          console.log('Fetched project:', project);
          if (project[0].present) {
            setPresentSuggestion(project[0].present);
          }
        })
        .catch(error => console.error('Error fetching project data:', error));
    }
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
  const questionsLeft = 12;
  const daysUntilPurchase = projectData ? Math.ceil((parseDateString(formatDate(projectData.giftPurchaseDate)).getTime() - new Date().getTime()) / (1000 * 3600 * 24)) : -999;
  const purpose = projectData ? projectData.present_purpose : 'XXXXX';
  const budget = projectData ? projectData.budget : -999;
  const purchaseDate = projectData ? formatDate(projectData.giftPurchaseDate) : '20XX/Y/Z';
  const giftDate = projectData ? formatDate(projectData.giftGivingDate) : '20XX/Y/Z';


  //gptに与える受け取り手の情報
  const receiver_data = "[年齢：" + String(age) + " 性別：" + gender + " 自分との関係：" + relationship + " 趣味：" + hobbies + " プレゼントの目的：" + purpose + " 予算：" + budget +  " プレゼントを渡す日：" + giftDate + ']'
  //gptに与えるプロンプト
  console.log(receiver_data)
  const gpt_input = [
    { role: 'system', content: 'あなたは相手が欲しいプレゼントが何かを特定するプロです。プレゼントを渡す相手の情報を知り、最適なプレゼントを選んでください。ただし、決して相手にプレゼントを選ぼうとしていることを悟られてはいけないので、直接相手に欲しいものを聞かずにそれとなく詮索してください。送り手との関係性を重要視してください。' },
    { role: 'user', content: '相手の情報： ' + receiver_data +
      ' これらを踏まえた上で相手が欲しいものをさらに詳しく知るために、相手に聞く質問文を1つだけ生成してください。質問以外の文章は出力しないでください。'},
  ];
  console.log(gpt_input)


  //GPTから回答を取得
  useEffect(() => {
    const fetchDescription = async () => {
      try {
        const gptResponse = await fetchGPTResponse(gpt_input);
        setDescription(gptResponse);
        console.log(gptResponse);

        // 取得した回答をDBに投稿して保存
        const message = {
          message_id: 'unique_message_id', // ユニークなメッセージIDを生成または取得
          question: gptResponse,
          answer: '', // 初めは空のままにしておくか、必要に応じて設定
          project_id: projectId,
        };

        console.log('Message to save:', message); // デバッグ用に
        await postMessage(message);

      } catch (error) {
        console.error('Error fetching GPT response or saving message:', error);
      }
    };
    fetchDescription();
  }, []);

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
      
      {showAnswerForm && <AnswerForm description={description} onClose={() => setShowAnswerForm(false)} id={messages[0].id} />}
      <ProfileContainer elevation={0}>
        <Avatar sx={{ width: '17.5vw', height: '17.5vw' }} />
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
            }}>合計質問数</Typography>
            <Typography sx={{
              fontSize: '15px',
              textAlign: 'right',
              fontWeight: 'bold',
              paddingRight: '15px',
              color: '#333',
            }}><span style={{ fontSize: '40px' }}>{questionsLeft}</span> 回</Typography>
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
            }}>プレゼント準備期間</Typography>
            <Typography sx={{
              fontSize: '15px',
              textAlign: 'right',
              fontWeight: 'bold',
              paddingRight: '15px',
              color: '#333',
            }}><span style={{ fontSize: '40px' }}>{daysUntilPurchase}</span> 日</Typography>
          </InfoPaper>
        </InfoRow>
        <InfoRow>
          <InfoBox>
            <InfoItem label="目的" value={purpose} />
          </InfoBox>
          <InfoBox>
            <InfoItem label="予算" value={`${budget} 円`} />
          </InfoBox>
        </InfoRow>
        <InfoRow>
          <InfoBox>
            <InfoItem label="購入予定日" value={purchaseDate} />
          </InfoBox>
          <InfoBox>
            <InfoItem label="渡す日" value={giftDate} />
          </InfoBox>
        </InfoRow>
      </ProjectInfo>
      <QuestionLog>
        <Typography sx={{ fontWeight: 'bold', fontSize: '22.5px', marginBottom: '20px' }}>プレゼント提案</Typography>
        <PresentBox>{presentSuggestion}</PresentBox>
      </QuestionLog>
      <QuestionLog>
        <Typography sx={{ fontWeight: 'bold', fontSize: '22.5px', marginBottom: '20px' }}>質問履歴</Typography>
        {messages
          .sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime())
          .map(message => (
            <React.Fragment key={message.id}>
              <QuestionBox>{message.question}</QuestionBox>
              {message.answer && <AnswerBox>{message.answer}</AnswerBox>}
            </React.Fragment>
          ))}
      </QuestionLog>
      
      
    </Base>
  );
};

interface InfoItemProps {
  label: string;
  value: string;
}

const InfoItem: React.FC<InfoItemProps> = ({ label, value }) => (
  <Box sx={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
    <Avatar sx={{
      width: '40px',
      height: '40px',
      backgroundColor: '#e0e0e0',
      marginRight: '10px'
    }} />
    <Box>
      <Typography sx={{ fontSize: '15px', fontWeight: 'bold', color: '#333' }}>{label}</Typography>
      <Typography sx={{ fontSize: '17.5px', fontWeight: 'bold', color: '#333' }}>{value}</Typography>
    </Box>
  </Box>
);

export default ProjectSummary;
