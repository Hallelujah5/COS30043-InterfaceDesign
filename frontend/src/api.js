// ==========CREATE A DEFAULT BASEURL FOR FASTAPI CALLING============
import axios from "axios";

const api = axios.create({
    baseURL: "http://cos30043-interfacedesign-production-ff6f.up.railway.app"
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

