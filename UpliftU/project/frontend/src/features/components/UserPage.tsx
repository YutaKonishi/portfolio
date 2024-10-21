import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { ToUserProfile } from "./ToUserProfile";
import OngoingProjectBar from "./OngoingProjectBar"; // デフォルトエクスポートとしてインポート
import { CompletedProjectBar } from "./CompletedProjectBar";
import { styled } from "@mui/material/styles";
import { Button } from "@mui/material";
import MissionSlider from "./MissionSlider";
import { useAuthContext } from "../auth/AuthContext"; // AuthContext をインポート

const Base = styled("div")({
  backgroundColor: "#fff",
  width: "100vw",
  height: "100vh",
});

const Title = styled("div")({
  fontSize: "22.5px",
  fontWeight: "bold",
  color: "#333333",
  paddingLeft: "5vw",
  paddingTop: "15vw",
});

const TodaysMission = styled("div")({
  fontSize: "20px",
  fontWeight: "bold",
  color: "#333333",
  paddingLeft: "5vw",
  marginTop: "5vw",
});

const OngoingProject = styled("div")({
  fontSize: "20px",
  fontWeight: "bold",
  color: "#333333",
  paddingLeft: "5vw",
  marginTop: "5vw",
  marginBottom: "2.5vw",
});

const CompletedProjectArea = styled("div")({
  width: "100vw",
  paddingBottom: '25vw',
});

const CompletedProject = styled("div")({
  fontSize: "20px",
  fontWeight: "bold",
  color: "#333333",
  paddingLeft: "5vw",
  marginTop: "5vw",
  marginBottom: "2.5vw",
});

const OngoingProjectArea = styled("div")({
  width: "100vw",
});

const UserPage: React.FC = () => {
  const navigate = useNavigate();
  const { user } = useAuthContext(); // AuthContext からユーザー情報を取得
  const [ongoingProjects, setOngoingProjects] = useState([]);
  const [completedProjects, setCompletedProjects] = useState([]);

  useEffect(() => {
    const fetchProjects = async () => {
      if (user && user.id) {
        try {
          const ongoingResponse = await axios.get(`http://127.0.0.1:8000/project/?is_completed=false&user_id=${user.id}`);
          setOngoingProjects(ongoingResponse.data);

          const completedResponse = await axios.get(`http://127.0.0.1:8000/project/?is_completed=true&user_id=${user.id}`);
          setCompletedProjects(completedResponse.data);
        } catch (error) {
          console.error("Failed to fetch projects:", error);
        }
      }
    };

    fetchProjects();
  }, [user]);

  const handleAddProjectClick = () => {
    navigate("/addproject");
  };

  return (
    <Base>
      <ToUserProfile />
      <Title>こんにちは、{user ? user.user_name : "ゲスト"}さん！</Title>
      <TodaysMission>本日のミッション</TodaysMission>
      <MissionSlider />
      <OngoingProject>進行中のプロジェクト</OngoingProject>
      <OngoingProjectArea>
        {ongoingProjects.map((project: any) => (
          <OngoingProjectBar key={project.id} projectId={project.id} name={project.project_name} progress={project.progress} />
        ))}
      </OngoingProjectArea>
      <CompletedProject>完了したプロジェクト</CompletedProject>
      <CompletedProjectArea>
        {completedProjects.map((project: any) => (
          <CompletedProjectBar key={project.id} projectId={project.id} name={project.project_name} progress={project.progress} />
        ))}
      </CompletedProjectArea>
      <Button
        onClick={handleAddProjectClick}
        sx={{
          position: "fixed",
          right: "7.5vw",
          bottom: "7.5vw",
          backgroundColor: "#FD8A8A",
          fontSize: "14px",
          fontWeight: "bold",
          color: "#333",
          borderRadius: "20px",
          padding: "9px 30px",
        }}
      >
        New Project
      </Button>
    </Base>
  );
};

export default UserPage;
