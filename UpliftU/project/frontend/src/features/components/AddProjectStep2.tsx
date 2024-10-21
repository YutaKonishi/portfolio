import { styled } from '@mui/material/styles';
import { Box, Button, TextField } from '@mui/material';
import FormControl from '@mui/material/FormControl';
import Select, { SelectChangeEvent } from '@mui/material/Select';
import MenuItem from '@mui/material/MenuItem';
import React, { useState, useEffect } from 'react';
import { useAuthContext } from '../auth/AuthContext'; // AuthContext をインポート

type Props = {
  setStep: (step: number) => void;
  setReceiverid: (receiverid: string) => void;
};

const TitleArea = styled('div')({
  fontSize: '17.5px',
  fontWeight: 'bold',
  color: '#333333',
  paddingLeft: "5vw",
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

const ButtonContainer = styled(Box)({
  display: 'flex',
  justifyContent: 'space-between',
  position: 'fixed',
  bottom: '10vw',
  left: '10vw',
  right: '10vw',
});

type FormData = {
  age: number | string;
  gender: string;
  relationship: string;
  receiver_name: string;
  hobbies: string;
  user_id: string;
};

export const AddProjectStep2: React.FC<Props> = ({ setStep, setReceiverid }) => {
  const { user } = useAuthContext(); // AuthContext からユーザー情報を取得

  const [formData, setFormData] = useState<FormData>({
    age: '',
    gender: '',
    relationship: '',
    receiver_name: '',
    hobbies: '',
    user_id: '', // Initialize with an empty user_id
  });

  useEffect(() => {
    if (user) {
      setFormData((prevData) => ({
        ...prevData,
        user_id: user.id, // ユーザーIDを設定
      }));
    }
  }, [user]);

  const handleInputChange = (fieldName: keyof FormData, value: string | number) => {
    setFormData((prevData) => ({
      ...prevData,
      [fieldName]: value,
    }));
  };

  const handleAgeChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = event.target.value;
    const intValue = parseInt(value, 10);
    if (!isNaN(intValue)) {
      handleInputChange('age', intValue);
    } else {
      handleInputChange('age', '');
    }
  };

  const handleGenderChange = (event: SelectChangeEvent<string>) => {
    handleInputChange('gender', event.target.value as string);
  };

  const handleBack = () => {
    setStep(1);
  };

  const handleReceiverid = (id: string) => {
    setReceiverid(id);
  };

  const handleNext = async () => {
    console.log('Form Data Submitted:', JSON.stringify(formData));
    let result = "";

    try {
      const response = await fetch('http://127.0.0.1:8000/receiver/', {
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
        result = data;
        const id = data.id;
        handleReceiverid(id);
      }
      console.log('Form Data Submitted:', result);
    } catch (error) {
      console.error('Error submitting form:', error);
    }

    setStep(3);
  };

  return (
    <Container>
      <FormContainer>
        <TitleArea>名前</TitleArea>
        <TextField placeholder="例：田中　花子" variant="filled" InputProps={inputProps} fullWidth value={formData.receiver_name}
          onChange={(e) => handleInputChange('receiver_name', e.target.value)} />
        <TitleArea>年齢</TitleArea>
        <TextField placeholder="例：18" variant="filled" InputProps={inputProps} fullWidth value={formData.age}
          onChange={handleAgeChange} />
        <TitleArea>性別</TitleArea>
        <FormControl fullWidth>
          <Select
            labelId="gender-label"
            id="gender-select"
            value={formData.gender}
            onChange={handleGenderChange}
            variant="filled"
          >
            <MenuItem value="M">男</MenuItem>
            <MenuItem value="F">女</MenuItem>
            <MenuItem value="O">秘密</MenuItem>
          </Select>
        </FormControl>

        <TitleArea>趣味</TitleArea>
        <TextField placeholder="例：ランニング、登山、料理" variant="filled" InputProps={inputProps} fullWidth value={formData.hobbies}
          onChange={(e) => handleInputChange('hobbies', e.target.value)} />
        <TitleArea>関係</TitleArea>
        <TextField placeholder="例：友人" variant="filled" InputProps={inputProps} fullWidth value={formData.relationship}
          onChange={(e) => handleInputChange('relationship', e.target.value)} />
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
        }} onClick={handleNext}>
          次へ
        </Button>
      </ButtonContainer>
    </Container>
  );
};

export default AddProjectStep2;
