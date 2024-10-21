import React, { useState, useEffect } from 'react';
import { styled } from '@mui/material/styles';
import { createPortal } from 'react-dom';
import { Box, Typography, TextField, Button, Paper } from '@mui/material';
import axios from 'axios';
import { fetchGPTResponse } from './fetchGPTResponse'; // fetchGPTResponseをインポート
import dayjs from 'dayjs'; // dayjsをインポート
import { useNavigate } from 'react-router-dom'; // useNavigateをインポート

const Overlay = styled('div')({
  position: 'fixed',
  top: 0,
  left: 0,
  width: '100vw',
  height: '100vh',
  backgroundColor: 'rgba(0, 0, 0, 0.7)',
  display: 'flex',
  justifyContent: 'center',
  alignItems: 'center',
  zIndex: 1000,
});

const FormContainer = styled(Paper)({
  padding: '20px',
  borderRadius: '20px',
  width: '85vw',
  backgroundColor: '#E2E3F2',
  display: 'flex',
  flexDirection: 'column',
  alignItems: 'center',
});

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

type Props = {
  onClose: () => void;
  description: string;
  id: string;
};

export const AnswerForm: React.FC<Props> = ({ onClose, description, id }) => {
  const [answer, setAnswer] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [messageCount, setMessageCount] = useState(0);
  const [questionAmount, setQuestionAmount] = useState(0);
  const [frequency, setFrequency] = useState(0);
  const navigate = useNavigate(); // useNavigateフックを初期化

  useEffect(() => {
    const fetchMessageCount = async () => {
      try {
        const response = await axios.get(`http://127.0.0.1:8000/message/?id=${id}`);
        console.log('Message response:', response.data); // APIレスポンスを出力して確認
        const project_id = response.data[0].project;
        if (project_id) {
          const projectResponse = await axios.get(`http://127.0.0.1:8000/message/?project_id=${project_id}`);
          setMessageCount(projectResponse.data.length); // message_amountをセット
        }
      } catch (error) {
        console.error('Error fetching message count:', error);
      }
    };

    const fetchQuestionAmount = async () => {
      try {
        const response = await axios.get(`http://127.0.0.1:8000/message/?id=${id}`);
        console.log('Message response:', response.data); // APIレスポンスを出力して確認
        const project_id = response.data[0].project;
        if (project_id) {
          const projectResponse = await axios.get(`http://127.0.0.1:8000/project/?project_id=${project_id}`);
          setQuestionAmount(projectResponse.data[0].question_amount);
          setFrequency(projectResponse.data[0].frequency);
        }
      } catch (error) {
        console.error('Error fetching project question amount:', error);
      }
    };

    fetchMessageCount();
    fetchQuestionAmount();
  }, [id]);

  const getPromptContent = (count: number) => {
    if (count < 3) {
      return '1.抽象的な質問をしてください。';
    } else if (count < 6) {
      return '1.具体的な質問と抽象的な質問を交えた質問をしてください。';
    } else {
      return '1.抽象的な質問をしてください。';
    }
  };

  const handleSubmit = async () => {
    if (!answer.trim()) {
      alert('回答を入力してください。');
      return;
    }

    setIsSubmitting(true);

    try {
      console.log(`Fetching message with id: ${id}`); // デバッグ用にIDを出力
      const response = await axios.get(`http://127.0.0.1:8000/message/?id=${id}`);
      console.log('Message response:', response.data); // APIレスポンスを出力して確認
      const project_id = response.data[0].project;
      if (project_id) {
        const projectResponse = await axios.get(`http://127.0.0.1:8000/project/?project_id=${project_id}`);
        console.log('Project response:', projectResponse.data); // デバッグ用にプロジェクトレスポンスを出力
        const receiver_id = projectResponse.data[0].receiver;
        if (receiver_id) {
          const receiverResponse = await axios.get(`http://127.0.0.1:8000/receiver/?receiver_id=${receiver_id}`);
          console.log('Receiver response:', receiverResponse.data); // デバッグ用に受信者レスポンスを出力
          const age = receiverResponse.data[0].age;
          const gender = receiverResponse.data[0].gender;
          const relationship = receiverResponse.data[0].relationship;
          const hobbies = receiverResponse.data[0].hobbies;
          const purpose = projectResponse.data[0].present_purpose;
          const budget = projectResponse.data[0].budget;
          const giftDate = projectResponse.data[0].giftGivingDate;

          const receiver_data = `年齢：${age} 性別：${gender} 自分との関係：${relationship} 趣味：${hobbies} プレゼントの目的：${purpose} 予算：${budget} プレゼントを渡す日：${giftDate}`;

          const messagesResponse = await axios.get(`http://127.0.0.1:8000/message/?project_id=${project_id}`);
          console.log('Messages response:', messagesResponse.data); // デバッグ用にメッセージレスポンスを出力
          const messages = messagesResponse.data;

          messages.sort((a: any, b: any) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime());
          let conversationHistory = '';

          messages.forEach((msg: any) => {
            conversationHistory += `質問：${msg.question} 回答：${msg.answer}`;
          });

          conversationHistory += `質問：${description} 回答：${answer}`;

          const promptContent = getPromptContent(messageCount);

          const gpt_input = [
            { role: 'system', content: 'あなたは相手が欲しいプレゼントが何かを特定するプロです。プレゼントを渡す相手の情報を知り、最適なプレゼントを選んでください。ただし、決して相手にプレゼントを選ぼうとしていることを悟られてはいけないので、直接相手に欲しいものを聞かずにそれとなく詮索してください。送り手との関係性を重要視してください。' },
            { role: 'user', content: `相手の情報： ${receiver_data} ${conversationHistory}
            これらを踏まえた上で相手が欲しいものをさらに詳しく知るために、相手に聞く質問文を1つだけ生成してください。
            このとき、以下の条件を考慮してください。
            1.${promptContent}
            2.質問以外の文章は出力しないこと。
            3.与えられた情報の中で関係性に基づいた質問をすること。例えば恋人には恋人との会話、子供なら学校のことなど。
            4.具体的なブランドを聞いてはいけない。` }
          ];

          const gptResponse = await fetchGPTResponse(gpt_input);
          console.log(gptResponse);

          const currentDate = new Date();
          const createdAt = dayjs(currentDate).format();

          // frequencyを使ってduedateを計算
          const frequencyHours = 168 / frequency; // 一週間の時間数をfrequencyで割る
          const dueDate = dayjs(currentDate).add(frequencyHours, 'hour').format();

          const messageToPost = {
            question: gptResponse,
            answer: "",
            project: project_id,
            createdAt: createdAt,
            dueDate: dueDate,
            isCompleted: false,
          };

          await postMessage(messageToPost);

          // Updating the answer in the message
          const messageUpdate = {
            answer: answer,
            isCompleted: true
          };

          await axios.patch(`http://127.0.0.1:8000/message/${id}/`, messageUpdate);

          // Update the project prompt
          const promptUpdate = {
            prompt: `相手の情報： ${receiver_data} ${conversationHistory}`
          };

          await axios.patch(`http://127.0.0.1:8000/project/${project_id}/update-fields/`, promptUpdate);

          console.log('回答が送信されました:', response.data);
          onClose();
        } else {
          console.error('Receiver ID not found in project response');
        }
      } else {
        console.error('Project ID not found in message response');
      }
    } catch (error) {
      console.error('Error fetching message, project, or receiver:', error);
      alert('回答の送信に失敗しました。もう一度お試しください。');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleGenerateGift = async () => {
    try {
      console.log(`Fetching message with id: ${id}`); // デバッグ用にIDを出力
      const response = await axios.get(`http://127.0.0.1:8000/message/?id=${id}`);
      console.log('Message response:', response.data); // APIレスポンスを出力して確認
      const project_id = response.data[0].project;
      if (project_id) {
        const projectResponse = await axios.get(`http://127.0.0.1:8000/project/?project_id=${project_id}`);
        console.log('Project response:', projectResponse.data); // デバッグ用にプロジェクトレスポンスを出力
        const receiver_id = projectResponse.data[0].receiver;
        if (receiver_id) {
          const receiverResponse = await axios.get(`http://127.0.0.1:8000/receiver/?receiver_id=${receiver_id}`);
          console.log('Receiver response:', receiverResponse.data); // デバッグ用に受信者レスポンスを出力
          const age = receiverResponse.data[0].age;
          const gender = receiverResponse.data[0].gender;
          const relationship = receiverResponse.data[0].relationship;
          const hobbies = receiverResponse.data[0].hobbies;
          const purpose = projectResponse.data[0].present_purpose;
          const budget = projectResponse.data[0].budget;
          const giftDate = projectResponse.data[0].giftGivingDate;

          const receiver_data = `年齢：${age} 性別：${gender} 自分との関係：${relationship} 趣味：${hobbies} プレゼントの目的：${purpose} 予算：${budget} プレゼントを渡す日：${giftDate}`;

          const messagesResponse = await axios.get(`http://127.0.0.1:8000/message/?project_id=${project_id}`);
          console.log('Messages response:', messagesResponse.data); // デバッグ用にメッセージレスポンスを出力
          const messages = messagesResponse.data;

          messages.sort((a: any, b: any) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime());
          let conversationHistory = '';

          messages.forEach((msg: any) => {
            conversationHistory += `質問：${msg.question} 回答：${msg.answer}`;
          });

          conversationHistory += `質問：${description} 回答：${answer}`;

          const gpt_input = [
            { role: 'system', content: 'あなたは相手が欲しいプレゼントが何かを特定するプロです。プレゼントを渡す相手の情報を知り、最適なプレゼントを選んでください。ただし、決して相手にプレゼントを選ぼうとしていることを悟られてはいけないので、直接相手に欲しいものを聞かずにそれとなく詮索してください。送り手との関係性を重要視してください。' },
            { role: 'user', content: `相手の情報： ${receiver_data} ${conversationHistory} 以上の情報を総合的に分析することで以下の条件で最適なプレゼントを1つ提示してください。（例）シルバーのネックレス
            選んだ理由・ポイントなどは出力せずに、プレゼントの案のみを出力してください。` }
          ];

          const gptResponse = await fetchGPTResponse(gpt_input);
          console.log("プレゼント結果！", gptResponse);

          // Update the project with the generated gift
          const projectUpdate = {
            present: gptResponse,
            isCompleted: true
          };

          await axios.patch(`http://127.0.0.1:8000/project/${project_id}/update-fields/`, projectUpdate);

          // Answer を message に更新
          const messageUpdate = {
            answer: answer,
            isCompleted: true,
          };

          await axios.patch(`http://127.0.0.1:8000/message/${id}/`, messageUpdate);

          // navigate to the gift suggestion page
          navigate(`/gift_suggestion/${project_id}`);

        } else {
          console.error('Receiver ID not found in project response');
        }
      } else {
        console.error('Project ID not found in message response');
      }
    } catch (error) {
      console.error('Error fetching message, project, or receiver:', error);
      alert('プレゼント生成に失敗しました。もう一度お試しください。');
    }
  };

  return createPortal(
    <Overlay onClick={onClose}>
      <FormContainer onClick={(e) => e.stopPropagation()}>
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
              color: '#333',
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
              color: '#333',
            }}>
            {description}
            </Typography>
          </Box>
        </Box>
        <Typography sx={{
          fontWeight: 'bold',
          marginBottom: '10px',
          textAlign: 'left',
          width: '100%',
          marginLeft: '4vw',
          fontSize: '17.5px',
        }}>回答を入力</Typography>
        <TextField
          variant="outlined"
          multiline
          rows={3}
          fullWidth
          value={answer}
          onChange={(e) => setAnswer(e.target.value)}
          sx={{
            marginBottom: '10px',
            backgroundColor: '#fff',
          }}
        />
        {messageCount < questionAmount ? (
          <Button 
            variant="contained" 
            sx={{
              backgroundColor: '#f28b82',
              color: '#fff',
              borderRadius: '20px',
              fontWeight: 'bold',
              fontSize: '17.5px',
              padding: '2.5px 30px',
              marginBottom: '10px',
            }}
            onClick={handleSubmit}
            disabled={isSubmitting}
          >
            {isSubmitting ? '送信中...' : '送信'}
          </Button>
        ) : (
          <Button 
            variant="contained" 
            sx={{
              backgroundColor: '#8bbf28',
              color: '#fff',
              borderRadius: '20px',
              fontWeight: 'bold',
              fontSize: '17.5px',
              padding: '2.5px 30px',
            }}
            onClick={handleGenerateGift}
          >
            生成
          </Button>
        )}
      </FormContainer>
    </Overlay>,
    document.body
  );
};

export default AnswerForm;
