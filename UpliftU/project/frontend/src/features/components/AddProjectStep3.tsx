import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { styled } from '@mui/material/styles';
import { Box, Button, TextField } from '@mui/material';
import { useAuthContext } from '../auth/AuthContext'; // AuthContext をインポート
import { fetchGPTResponse } from './fetchGPTResponse'; // fetchGPTResponseをインポート
import axios from 'axios';
import dayjs from 'dayjs';

type Props = {
  setStep: (step: number) => void;
  receiverid: string;
  selectedPerson: Person;
};

type Person = {
  name: string;
  number: number;
  bgcolor: string;
  id: string;
};

const TitleArea = styled('div')({
  fontSize: '15px',
  fontWeight: 'bold',
  color: '#333333',
  paddingLeft: "0vw",
  marginTop: "4vw",
  marginBottom: "1vw",
});

const Container = styled('div')({
  width: '100vw',
  padding: '7.5vw',
  boxSizing: 'border-box',
  position: 'relative',
});

const inputProps = {
  style: {
    backgroundColor: '#eee',
    borderRadius: '10px',
    height: "11vw",
    paddingLeft: "1.5vw",
    paddingBottom: '3.5vw',
  },
  disableUnderline: true,
};

const FormContainer = styled(Box)({
  display: 'flex',
  flexDirection: 'column',
});

const FlexContainer = styled(Box)({
  display: 'flex',
  justifyContent: 'space-between',
  marginBottom: '2vw',
});

const HalfWidthTextField = styled(TextField)({
  width: '100%',
});

const ButtonContainer = styled(Box)({
  display: 'flex',
  justifyContent: 'space-between',
  position: 'fixed',
  bottom: '10vw',
  left: '10vw',
  right: '10vw',
});

type FormData = {
  project_name: string;
  budget: number;
  giftPurchaseDate: string;
  giftGivingDate: string;
  present_purpose: string;
  receiver: string;
  user_id: string;
  isCompleted: boolean;
  remark: string;
  question_amount: number;
  genre: string;
  frequency: number;
};

const postMessage = async (message: any) => {
  try {
    const response = await fetch('http://127.0.0.1:8000/message/', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(message),
    });
    if (!response.ok) {
      const errorData = await response.json();
      console.error('Error Data:', errorData);
      throw new Error('Network response was not ok');
    } else {
      const data = await response.json();
      console.log('Message posted:', data);
    }
  } catch (error) {
    console.error('Error posting message:', error);
  }
};

const formatDateToISOString = (date: string): string => {
  const formattedDate = dayjs(date, 'YYYY年MM月DD日').format('YYYY-MM-DDT00:00:00+09:00');
  return formattedDate;
};

export const AddProjectStep3: React.FC<Props> = ({ setStep, receiverid, selectedPerson }) => {
  const navigate = useNavigate();
  const { user } = useAuthContext(); // AuthContext からユーザー情報を取得

  const [formData, setFormData] = useState<FormData>({
    project_name: '',
    budget: 0,
    giftPurchaseDate: '',
    giftGivingDate: '',
    present_purpose: '',
    receiver: receiverid,
    user_id: '',
    isCompleted: false,
    remark: '',
    question_amount: 0,
    genre: '',
    frequency: 0,
  });

  const [description, setDescription] = useState('');
  const [receiverInfo, setReceiverInfo] = useState<any>({});

  useEffect(() => {
    if (user) {
      setFormData((prevData) => ({
        ...prevData,
        user_id: user.id,
      }));
    }
  }, [user]);

  useEffect(() => {
    if (formData.giftPurchaseDate && formData.frequency) {
      const calculateQuestionAmount = () => {
        const currentDate = new Date();
        const purchaseDate = new Date(formData.giftPurchaseDate);
        const timeDifference = purchaseDate.getTime() - currentDate.getTime();
        const daysDifference = timeDifference / (1000 * 3600 * 24);
        const weeksDifference = Math.ceil(daysDifference / 7);
        return weeksDifference * formData.frequency;
      };

      const questionAmount = calculateQuestionAmount();

      setFormData((prevData) => ({
        ...prevData,
        question_amount: questionAmount,
      }));
    }
  }, [formData.giftPurchaseDate, formData.frequency]);

  useEffect(() => {
    const fetchReceiverInfo = async () => {
      try {
        const response = await axios.get(`http://127.0.0.1:8000/receiver/?receiver_id=${receiverid}`);
        setReceiverInfo(response.data);
      } catch (error) {
        console.error('Error fetching receiver info:', error);
      }
    };

    fetchReceiverInfo();
  }, [receiverid]);

  const handleInputChange = (fieldName: keyof FormData, value: string | number) => {
    if (fieldName === 'giftPurchaseDate' || fieldName === 'giftGivingDate') {
      const formattedDate = formatDateToISOString(value as string);
      setFormData((prevData) => ({
        ...prevData,
        [fieldName]: formattedDate,
      }));
    } else {
      setFormData((prevData) => ({
        ...prevData,
        [fieldName]: value,
      }));
    }
  };

  const handleBack = () => {
    setStep(2);
  };

  const handleSubmit = async () => {
    console.log('Form Data Submitted:', JSON.stringify(formData));

    let projectId = null;
    const currentDate = new Date();
    const createdAt = dayjs(currentDate).format();

    try {
      const response = await fetch('http://127.0.0.1:8000/project/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });
      if (!response.ok) {
        const errorData = await response.json();
        console.error('Error Data:', errorData);
        throw new Error('Network response was not ok');
      } else {
        const data = await response.json();
        console.log('Form Data Submitted:', data);
        projectId = data.id; // レスポンスからprojectのidを取得
      }
    } catch (error) {
      console.error('Error submitting form:', error);
    }

    const receiver_data = `[年齢：${receiverInfo.age} 性別：${receiverInfo.gender} 自分との関係：恋人 趣味：${receiverInfo.hobbies} プレゼントの目的：${formData.present_purpose} 予算：${formData.budget} プレゼントを渡す日：${formData.giftGivingDate}]`;

    const gpt_input = [
      { role: 'system', content: 'あなたは相手が欲しいプレゼントが何かを特定するプロです。プレゼントを渡す相手の情報を知り、最適なプレゼントを選んでください。ただし、決して相手にプレゼントを選ぼうとしていることを悟られてはいけないので、直接相手に欲しいものを聞かずにそれとなく詮索してください。送り手との関係性を重要視してください。' },
      { role: 'user', content: '相手の情報： ' + receiver_data +
        ' これらを踏まえた上で相手が欲しいものをさらに詳しく知るために、相手に聞く質問文を1つだけ生成してください。質問以外の文章は出力しないでください。'},
    ];

    try {
      const gptResponse = await fetchGPTResponse(gpt_input);
      if (gptResponse) {
        setDescription(gptResponse);
        console.log('GPT Response:', gptResponse);  // GPTからの質問応答をログに出力

        // frequencyを使ってduedateを計算
        const frequencyHours = 168 / formData.frequency; // 一週間の時間数をfrequencyで割る
        const dueDate = dayjs(currentDate).add(frequencyHours, 'hour').format();

        const message = {
          question: gptResponse,
          answer: '',
          project: projectId,
          createdAt: createdAt,
          dueDate: dueDate,
          isCompleted: false,
        };

        console.log('Message to save:', message);
        await postMessage(message);
      } else {
        console.error('GPT response was null.');
      }

    } catch (error) {
      console.error('Error fetching GPT response or saving message:', error);
    }

    setStep(1);
    navigate('/');
  };

  return (
    <Container>
      <FormContainer>
        <TitleArea>プロジェクト名</TitleArea>
        <TextField placeholder="例：誕生日プロジェクト" variant="filled" InputProps={inputProps} fullWidth value={formData.project_name}
          onChange={(e) => handleInputChange('project_name', e.target.value)} />
        <TitleArea>予算</TitleArea>
        <TextField type="number" placeholder="例：5,000円" variant="filled" InputProps={inputProps} fullWidth value={formData.budget}
          onChange={(e) => handleInputChange('budget', Number(e.target.value))} />
        <FlexContainer>
          <Box sx={{ width: '48%' }}>
            <TitleArea>プレゼントを買う日</TitleArea>
            <HalfWidthTextField placeholder="例：2024年7月12日" variant="filled" InputProps={inputProps} fullWidth value={formData.giftPurchaseDate}
              onChange={(e) => handleInputChange('giftPurchaseDate', e.target.value)} />
          </Box>
          <Box sx={{ width: '48%' }}>
            <TitleArea>プレゼントを渡す日</TitleArea>
            <HalfWidthTextField placeholder="例：2024年8月12日" variant="filled" InputProps={inputProps} fullWidth value={formData.giftGivingDate}
              onChange={(e) => handleInputChange('giftGivingDate', e.target.value)} />
          </Box>
        </FlexContainer>
        <TitleArea>プレゼントの目的</TitleArea>
        <TextField placeholder="例：誕生日プレゼント" variant="filled" InputProps={inputProps} fullWidth value={formData.present_purpose}
          onChange={(e) => handleInputChange('present_purpose', e.target.value)} />
        <FlexContainer>
          <Box sx={{ width: '48%' }}>
            <TitleArea>会う頻度</TitleArea>
            <HalfWidthTextField type="number" placeholder="例：週に1回" variant="filled" InputProps={inputProps} fullWidth value={formData.frequency}
              onChange={(e) => handleInputChange('frequency', Number(e.target.value))} />
          </Box>
          <Box sx={{ width: '48%' }}>
            <TitleArea>ジャンル</TitleArea>
            <HalfWidthTextField placeholder="例：趣味" variant="filled" InputProps={inputProps} fullWidth value={formData.genre}
              onChange={(e) => handleInputChange('genre', e.target.value)} />
          </Box>
        </FlexContainer>
        <TitleArea>備考欄</TitleArea>
        <TextField placeholder="例：特記事項" variant="filled" InputProps={inputProps} fullWidth value={formData.remark}
          onChange={(e) => handleInputChange('remark', e.target.value)} />
      </FormContainer>
      <ButtonContainer>
        <Button variant="contained" sx={{
          backgroundColor: '#A8D1D1',
          color: '#333',
          borderRadius: '25px',
          padding: '8px 35px',
          fontWeight: 'bold',
          fontSize: '17px',
        }} onClick={handleBack}>
          戻る
        </Button>
        <Button variant="contained" sx={{
          backgroundColor: '#FD8A8A',
          color: '#fff',
          borderRadius: '25px',
          padding: '8px 35px',
          fontWeight: 'bold',
          fontSize: '17px',
        }} onClick={handleSubmit}>
          登録
        </Button>
      </ButtonContainer>
    </Container>
  );
};

export default AddProjectStep3;
