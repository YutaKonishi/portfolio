import "./App.css";
import { Route, Routes } from "react-router-dom";
import Signin from "./features/auth/Signin";
import AppLayout from "./layout/AppLayout";
import { PrivateRoute } from "./features/auth/PrivateRoute";
import Home from "./features/home/Home";
import Signup from "./features/auth/Signup";
import StartScreen from "./features/auth/StartScreen";
import { CssBaseline } from "@mui/material";
import AddProject from "./features/components/AddProject";
import ProjectPage from './features/components/ProjectPage'; 
import ProjectSummary from './features/components/ProjectSummary';
import SNSField from "./features/components/SNSField"; 
import GiftSuggestionPage from "./features/components/GiftSuggestionPage";

function App() {
  return (
    <div className="App">
      <>
        <CssBaseline />
        <Routes>
          <Route path="/" element={<PrivateRoute element={<AppLayout />} />}>
            <Route index element={<Home />} />
            <Route path="/addproject" element={<AddProject />} />
            <Route path="/snsfield" element={<SNSField />} />
            <Route path="/project/:projectId" element={<ProjectPage />} />
            <Route path="/project_done/:projectId" element={<ProjectSummary />} />
            <Route path="/gift_suggestion/:projectId" element={<GiftSuggestionPage />} />
          </Route>
          <Route path="/startscreen" element={<StartScreen />} />
          <Route path="/signin" element={<Signin />} />
          <Route path="/signup" element={<Signup />} />
        </Routes>
      </>
    </div>
  );
}

export default App;