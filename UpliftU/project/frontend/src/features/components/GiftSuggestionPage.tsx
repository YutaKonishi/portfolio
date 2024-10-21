import React, { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { styled } from '@mui/material/styles';
import { ToUserProfile } from './ToUserProfile';
import NavigateBeforeIcon from '@mui/icons-material/NavigateBefore';
import { Button } from '@mui/material';
import { fetchGPTResponse } from './fetchGPTResponse';

// 基本コンテナのスタイル
const Base = styled('div')({
  width: "100vw",
  minHeight: "100vh",
  backgroundColor: '#fff',
});

//xxさんのプロジェクト
const Title = styled('div')({
  paddingTop: '20vw',
  marginLeft: '5vw',
  fontSize: "22.5px",
  fontWeight: "bold"
});

// 内容を中央に配置するコンテナのスタイル
const Content = styled('div')({
  flex: 1,
  width: '100%',
  display: 'flex',
  flexDirection: 'column',
  alignItems: 'center',
  padding: '0 5vw',
});

//「プレゼント提案」とイラストを含むコンテナのスタイル
const SubtitleContainer = styled('div')({
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center', // 中央揃え
  marginTop: '50px',
});

// 「プレゼント提案」のタイトルスタイル
const Subtitle = styled('h2')({
  fontSize: '28px',
  fontWeight: 'bold',
  color: '#333333',
  margin: '0 20px', // 左右のマージンを追加してイラストとのスペースを確保
  textAlign: 'center', //中央揃え
});

// 左右のイラストのスタイル
const Illustration = styled('img')({
  width: '100px', // イラストの幅を100pxに設定
  height: 'auto', // 高さを自動調整
});

// 提案するプレゼントの内容のスタイル
const Description = styled('p')({
  fontSize: '24px',  // テキストのサイズ
  color: '#333333',  // テキストの色：濃いグレー
  marginTop: '100px',  // 上部の（「プレゼント提案」文字との）マージン
  padding: '85px',  // 内側の余白を100pxに設定
  borderRadius: '10px',  // 角を10pxの半径で丸くする
  border: '2px solid #A8D1D1',  // 2px幅の淡い青色のボーダーを設定
  boxShadow: '0px 4px 6px rgba(0, 0, 0, 0.1)',  // 軽い影を追加して立体感を演出
  backgroundColor: '#f9f9f9',  // 背景色を薄いグレーに設定
  backgroundImage: 'url(https://www.illust-ai.com/datas/00000112.png?3)',  // 背景画像を設定
  backgroundSize: 'cover',  // 背景画像をコンポーネント全体に合わせてリサイズ
  backgroundPosition: 'center',  // 背景画像を中央に配置
  width: '90%',  // 幅を90%に設定
  maxWidth: '800px',  // 最大幅を800pxに設定
  textAlign: 'center',  // テキストを中央に配置
  height: '234px',  // 高さを固定で400pxに設定
  overflowY: 'auto',  // 内容がボックスサイズを超えた場合に縦スクロールバーを表示
});

// フッターのスタイル
const Footer = styled('div')({
  display: 'flex',
  justifyContent: 'center',
  width: '100%',
  padding: '150px 5vw',
  marginTop: 'auto',
});

// スタイル付きボタンのスタイル
const StyledButton = styled(Button)({
  borderRadius: '20px',
  padding: '10px 30px',
  fontSize: '16px',
  fontWeight: 'bold',
  marginLeft: '10px',
  marginRight: '10px',
  color: '#000000',
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
  isCompleted: boolean;
  remark: string;
  user_id: number;
  present: string;
  prompt: string;
}

interface Receiver {
  id: string;
  age: number;
  gender: string;
  relationship: string;
  receiver_name: string;
  hobbies: string;
}

const GiftSuggestionPage: React.FC = () => {
  const navigate = useNavigate();
  const { projectId } = useParams<{ projectId: string }>();

  const [projectData, setProjectData] = useState<Project | null>(null);
  const [description, setDescription] = useState<string>('');
  const [receiversData, setReceiversData] = useState<Receiver[]>([]);

  useEffect(() => {
    // プロジェクトデータの取得
    fetch('http://127.0.0.1:8000/project/')
      .then(response => response.json())
      .then(data => {
        const project = data.find((project: Project) => project.id === projectId);
        setProjectData(project);
        if (project) {
          setDescription(project.present || "デフォルトのプレゼント");
        }
      })
      .catch(error => console.error('Error fetching project data:', error));
      
    // レシーバーデータの取得
    fetch('http://127.0.0.1:8000/receiver/')
      .then(response => response.json())
      .then(data => setReceiversData(data))
      .catch(error => console.error('Error fetching receiver data:', error));
  }, [projectId]);

  const receiverId = projectData ? projectData.receiver : "xxx";
  const receiver = receiversData.find(receiver => receiver.id === receiverId);
  const recipientName_last = receiver ? receiver.receiver_name : '';

  // GPTから説明文を取得する関数
  const fetchDescription = async () => {
    try {
      const receiverId = projectData ? projectData.receiver : "xxx";
      const receiver = receiversData.find(receiver => receiver.id === receiverId);
      
      if (!receiver) {
        console.error('Receiver not found');
        return;
      }

      const age = receiver.age || 999;
      const gender = receiver.gender || 'undefined';
      const hobbies = receiver.hobbies ? receiver.hobbies.split(',') : [];
      const relationship = receiver.relationship ? [receiver.relationship] : ['不明'];
      const receiverDataString = `[年齢：${age} 性別：${gender} 自分との関係：${relationship} 趣味：${hobbies}]`;
      
      const gptInput = [
        { role: 'system', content: 'あなたは相手が欲しいプレゼントが何かを特定するプロです。プレゼントを渡す相手の情報を知り、最適なプレゼントを選んでください。' },
        { role: 'user', content: `相手の情報：${receiverDataString} これらを踏まえた上で相手が欲しいプレゼントを1つだけ提示してください。ただし、プレゼントのみを出力し、それ以外の不要な文章は一切交えないでください。` },
      ];

      const gptResponse = await fetchGPTResponse(gptInput);
      setDescription(gptResponse);

      const message = {
        message_id: 'unique_message_id',
        question: gptResponse,
        answer: '',
        project_id: projectId,
      };
      console.log('Message to save:', message);
    } catch (error) {
      console.error('Error fetching GPT response or saving message:', error);
    }
  };

  const handleBackClick = () => {
    navigate(-1); // 1つ前のページに戻る
  };

  const handleRegenerateClick = () => {
    console.log('再生成ボタンがクリックされました');
    fetchDescription(); // 説明文を再生成する
  };

  const handleDecideClick = () => {
    console.log('決定ボタンがクリックされました');
    navigate('/'); // トップ画面に遷移する
  };

  if (!projectData) {
    return null; // データが読み込まれるまで何も表示しない
  }

  return (
    <Base>
      <ToUserProfile /> {/* ユーザープロフィールコンポーネント */}
      <NavigateBeforeIcon
        sx={{
          fontSize: "large",
          color: '#333',
          position: 'fixed',
          left: '10vw',
          top: '7.5vw',
        }}
        onClick={handleBackClick} // 戻るボタンクリック時の処理
      />
      <Title>{recipientName_last}さんのプロジェクト</Title>

      <Content>
        <SubtitleContainer>
          <Illustration src="https://stockmaterial.net/wp/wp-content/uploads/img/event_present01_01.png" alt="Left Illustration" />
          <Subtitle>プレゼント提案</Subtitle>
          <Illustration src="https://stockmaterial.net/wp/wp-content/uploads/img/event_present01_01.png" alt="Right Illustration" />
        </SubtitleContainer>
        <Description>{description}</Description>
      </Content>
      <Footer>
        <StyledButton
          variant="contained"
          color="primary"
          onClick={handleRegenerateClick}
          sx={{ backgroundColor: '#A8D1D1' }}
        >
          再生成
        </StyledButton>
        <StyledButton
          variant="contained"
          color="secondary"
          onClick={handleDecideClick}
          sx={{ backgroundColor: '#FD8A8A' }}
        >
          決定
        </StyledButton>
      </Footer>
    </Base>
  );
};

export default GiftSuggestionPage;
