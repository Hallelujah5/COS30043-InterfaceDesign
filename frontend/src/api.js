// ==========CREATE A DEFAULT BASEURL FOR FASTAPI CALLING============
import axios from "axios";

const api = axios.create({
    baseURL: "http://127.0.0.1:8000"
});

// Use an interceptor to add the token to every request
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken');
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

export default api;

