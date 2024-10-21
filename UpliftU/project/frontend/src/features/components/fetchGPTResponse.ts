import axios from 'axios';

const API_URL = 'https://api.openai.com/v1/';
const MODEL = 'gpt-4o';
const API_KEY = '';

interface Message {
  role: string;
  content: string;
}

export const fetchGPTResponse = async (messages: Message[]) => {
  try {
    const response = await axios.post(`${API_URL}chat/completions`, {
      model: MODEL,
      messages: messages,
    }, {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${API_KEY}`
      }
    });
    return response.data.choices[0].message.content;
  } catch (error) {
    console.error(error);
    return null;
  }
}
