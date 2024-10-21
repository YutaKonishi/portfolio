import React, { useEffect, useState } from 'react';
import Slider from 'react-slick';
import Mission from './Mission';
import axios from 'axios';
import 'slick-carousel/slick/slick.css';
import 'slick-carousel/slick/slick-theme.css';
import { useAuthContext } from '../auth/AuthContext'; // AuthContext をインポート

type Props = {};

interface MissionData {
  title: string;
  description: string;
  daysLeft: number;
  id: string;
}

const calculateDaysLeft = (dueDate: string): number => {
  const dueDateTime = new Date(dueDate).getTime();
  const currentDateTime = new Date().getTime();
  const timeDifference = dueDateTime - currentDateTime;
  const daysLeft = Math.ceil(timeDifference / (1000 * 60 * 60 * 24));
  return daysLeft;
};

export const MissionSlider: React.FC<Props> = () => {
  const [missions, setMissions] = useState<MissionData[]>([]);
  const { user } = useAuthContext(); // AuthContext からユーザー情報を取得

  useEffect(() => {
    const fetchMissions = async () => {
      if (!user || !user.id) return;

      try {
        const response = await axios.get('http://127.0.0.1:8000/message/?isCompleted=false');
        const missionsWithProjectNames = await Promise.all(response.data.map(async (mission: any) => {
          const projectResponse = await axios.get(`http://127.0.0.1:8000/project/?project_id=${mission.project}`);
          const project = projectResponse.data[0];

          // フィルタリング: プロジェクトのuser_idが現在のユーザーのIDと一致するか確認
          if (project.user_id !== user.id) return null;

          return {
            title: project.project_name,
            description: mission.question,
            daysLeft: calculateDaysLeft(mission.dueDate),
            id: mission.id,
          };
        }));

        // nullを除去し、残り日数が少ない順にソート
        const filteredMissions = missionsWithProjectNames.filter(mission => mission !== null).sort((a, b) => a!.daysLeft - b!.daysLeft);

        setMissions(filteredMissions as MissionData[]);
      } catch (error) {
        console.error('Failed to fetch missions:', error);
      }
    };

    fetchMissions();
  }, [user]);

  const settings = {
    dots: true,
    infinite: false,
    speed: 500,
    slidesToShow: 1,
    slidesToScroll: 1,
    arrows: true
  };

  return (
    <div style={{
        width: '75vw',
        margin: 'auto',
        marginTop: '2.5vw',
        marginBottom: '10vw',
    }}>
      <Slider {...settings}>
        {missions.map((mission, index) => (
          <div key={index}>
            <Mission {...mission} />
          </div>
        ))}
      </Slider>
    </div>
  );
};

export default MissionSlider;
