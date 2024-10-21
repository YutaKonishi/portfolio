import React, { useEffect, useState } from 'react';
import { styled } from '@mui/material/styles';
import { Box, Typography, Avatar, Button, IconButton } from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useAuthContext } from '../auth/AuthContext'; // AuthContext をインポート

type Props = {
  setStep: (step: number) => void;
  setSelectedPerson: (person: Person) => void;
};

type Person = {
  name: string;
  number: number;
  bgcolor: string;
  id: string;
};

const Container = styled('div')({
  width: '100vw',
});

const Title = styled(Typography)({
  display: 'flex',
  alignItems: 'center',
  fontSize: '25px',
  fontWeight: 'bold',
  marginBottom: '5vw',
  marginTop: '5vw',
  color: '#333',
  paddingLeft: '5vw',
  paddingTop: '5vw',
});

const PersonList = styled(Box)({
  display: 'flex',
  flexWrap: 'wrap',
  width: '92vw',
  margin: 'auto',
});

const PersonItem = styled(Box)<{ bgcolor: string }>(({ bgcolor }) => ({
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'space-between',
  borderRadius: '15px',
  minWidth: '43vw',
  maxWidth: '43vw',
  paddingTop: '2px',
  paddingBottom: '2px',
  margin: '1.5vw',
  cursor: 'pointer',
  backgroundColor: bgcolor,
}));

const PersonName = styled(Typography)({
  fontWeight: 'bold',
  marginLeft: '5vw',
  fontSize: '17px',
});

const PersonNumber = styled(Avatar)<{ bgcolor: string }>(({ bgcolor }) => ({
  backgroundColor: bgcolor,
  color: '#fff',
  fontSize: '17.5px',
  fontWeight: 'bold',
}));

const ButtonContainer = styled(Box)({
  display: 'flex',
  justifyContent: 'space-between',
  position: 'fixed',
  bottom: '10vw',
  left: '10vw',
  right: '10vw',
});

const getColorByNumber = (number: number) => {
  if (number === 0) return '#dddddd';
  if (number === 1) return '#ffba08';
  if (number >= 2 && number <= 3) return '#faa307';
  if (number >= 4 && number <= 5) return '#f48c06';
  if (number >= 6 && number <= 10) return '#e85d04';
  if (number >= 11 && number <= 20) return '#dc2f02';
  if (number >= 21) return '#d00000';
  return '#dddddd';
};

export const AddProjectStep1: React.FC<Props> = ({ setStep, setSelectedPerson }) => {
  const navigate = useNavigate();
  const { user } = useAuthContext(); // AuthContext からユーザー情報を取得
  const [persons, setPersons] = useState<Person[]>([]);

  useEffect(() => {
    const fetchData = async () => {
      if (!user || !user.id) return;

      try {
        const receiversResponse = await axios.get(`http://127.0.0.1:8000/receiver/?user_id=${user.id}`);
        const projectsResponse = await axios.get('http://127.0.0.1:8000/project/');

        const projectsData = projectsResponse.data;
        const receiverProjectCount: { [key: string]: number } = {};

        // カウントを初期化
        projectsData.forEach((project: any) => {
          if (receiverProjectCount[project.receiver]) {
            receiverProjectCount[project.receiver]++;
          } else {
            receiverProjectCount[project.receiver] = 1;
          }
        });

        const fetchedPersons = receiversResponse.data.map((receiver: any) => ({
          name: receiver.receiver_name,
          number: receiverProjectCount[receiver.id] || 0,
          bgcolor: getColorByNumber(receiverProjectCount[receiver.id] || 0),
          id: receiver.id
        }));

        setPersons(fetchedPersons);
      } catch (error) {
        console.error('Error fetching data:', error);
      }
    };

    fetchData();
  }, [user]);

  const handleBack = () => {
    navigate('/');
  };

  const handleItemClickTo2 = () => {
    setStep(2); // ステップを2に変更
  };

  const handlePersonSelect = (person: Person) => {
    setSelectedPerson(person);
    setStep(3); // ステップを3に変更
  };

  return (
    <Container>
      <Title>
        New Person
        <IconButton 
          sx={{
            marginLeft: '3vw',
            width: '7.5vw',
            height: '7.5vw',
            backgroundColor: '#ddd'
          }}
          onClick={handleItemClickTo2} // クリックイベントハンドラを追加
        >
          <AddIcon sx={{ color:'#000' }} />
        </IconButton>
      </Title>
      
      <PersonList>
        {persons.map((person, index) => (
          <PersonItem key={index} bgcolor={person.bgcolor} onClick={() => handlePersonSelect(person)}>
            <PersonName>{person.name}</PersonName>
            <PersonNumber bgcolor={person.bgcolor}>{person.number}</PersonNumber>
          </PersonItem>
        ))}
      </PersonList>
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
      </ButtonContainer>
    </Container>
  );
};

export default AddProjectStep1;
