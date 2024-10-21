import React, { useState } from 'react';
import { styled } from '@mui/material/styles';
import { AddProjectProgress } from './AddProjectProgress';
import AddProjectStep1 from './AddProjectStep1';
import AddProjectStep2 from './AddProjectStep2';
import AddProjectStep3 from './AddProjectStep3';

const Base = styled('div')({
  width: '100vw',
  height: '100vh',
  backgroundColor: '#fff',
});

type Person = {
  name: string;
  number: number;
  bgcolor: string;
  id: string;
};

export const AddProject: React.FC = () => {
  const [step, setStep] = useState(1); // ステップの初期値を1に設定
  const [receiverid, setReceiverid] = useState("");
  const [selectedPerson, setSelectedPerson] = useState<Person | null>(null);

  const renderStepComponent = () => {
    switch (step) {
      case 1:
        return <AddProjectStep1 setStep={setStep} setSelectedPerson={setSelectedPerson} />;
      case 2:
        return <AddProjectStep2 setStep={setStep} setReceiverid={setReceiverid} />;
      case 3:
        return <AddProjectStep3 setStep={setStep} receiverid={selectedPerson?.id || receiverid} selectedPerson={selectedPerson!} />;
      default:
        return <AddProjectStep1 setStep={setStep} setSelectedPerson={setSelectedPerson} />;
    }
  };

  return (
    <Base>
      <AddProjectProgress step={step} setStep={setStep} />
      {renderStepComponent()}
    </Base>
  );
};

export default AddProject;
