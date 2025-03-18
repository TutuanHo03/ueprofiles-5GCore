import axios from 'axios';
import { getToken } from '../utils/auth';

const baseURL = process.env.REACT_APP_API_URL || 'http://localhost:8080';
console.log('API baseURL:', baseURL);

const instance = axios.create({
  baseURL: baseURL, 
});

// Add a request interceptor to include the token
instance.interceptors.request.use(
  (config) => {
    const token = getToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

export default instance;
