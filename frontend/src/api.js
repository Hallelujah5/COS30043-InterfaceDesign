// FILE: frontend/src/api.js
// REASON FOR CHANGE: Updated the baseURL to use the secure HTTPS protocol
// to fix the "Mixed Content" browser error.

import axios from "axios";
import { showError } from '@/utils/toast'; // Assuming you have a toast utility

const api = axios.create({
    // Replace the old http:// URL with your secure Railway URL
    baseURL: "https://cos30043-interfacedesign-production-ff6f.up.railway.app"
});

// This interceptor sends the user's authentication token with every request.
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

// This interceptor handles expired sessions, automatically logging the user out.
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      localStorage.removeItem('accessToken');
      localStorage.removeItem('user');
      showError("Your session has expired. Please log in again.");
      setTimeout(() => {
        if (window.location.pathname !== '/login') {
            window.location.href = '/login';
        }
      }, 1500);
    }
    return Promise.reject(error);
  }
);

export default api;
