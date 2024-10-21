import Fab from '@mui/material/Fab';
import Icon from '@mui/material/Icon';
import { useNavigate } from 'react-router-dom';
import AccountCircleRoundedIcon from '@mui/icons-material/AccountCircleRounded'; 
import { styled } from '@mui/material/styles';
import PublicIcon from '@mui/icons-material/Public';

const FabButton = styled(Fab)({
	position: 'fixed',
	right: 15,
	top: 15,
	disableRipple: true,
	zIndex: 15000,
});

export const ToUserProfile: React.FC = () => {
	const navigate = useNavigate();

	const handleClick = () => {
		navigate('/snsfield');
	};

	return (
	<FabButton
		sx={{
			backgroundColor: "transparent",
			'&:hover': {
				backgroundColor: "transparent",
			},
			'&:active': {
				backgroundColor: "transparent",
			},
		}}
		onClick={handleClick}>
		<Icon sx= {{width: '100%', height: '100%'}}>
                <PublicIcon sx= {{fontSize: 56}} /> {/* AccountCircleRoundedアイコンの表示 */}
        </Icon>
	</FabButton>
	);
};

export default ToUserProfile;