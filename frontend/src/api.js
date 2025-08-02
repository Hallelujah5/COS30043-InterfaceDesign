// FILE: frontend/src/api.js
// REASON FOR CHANGE: This is the final, complete version. It sets the secure HTTPS
// baseURL and adds the request interceptor to send the user's auth token with every API call.

import axios from "axios";
import { showError } from '@/utils/toast'; // Assuming you have a toast utility

const api = axios.create({
    // Correctly uses the secure HTTPS URL for your Railway backend
    baseURL: "https://cos30043-interfacedesign-production-ff6f.up.railway.app"
});

// --- CRITICAL ADDITION: Request Interceptor ---
// This code runs BEFORE every API request is sent.
// api.interceptors.request.use(
//   (config) => {
//     // Get the authentication token from localStorage
//     const token = localStorage.getItem('accessToken');
    
//     // If the token exists, add it to the 'Authorization' header
//     if (token) {
//       config.headers['Authorization'] = `Bearer ${token}`;
//     }
    
//     return config;
//   },
//   (error) => {
//     // Handle any errors that occur during the request setup
//     return Promise.reject(error);
//   }
// );


// This is the response interceptor for handling expired sessions.
// api.interceptors.response.use(
//   (response) => response,
//   (error) => {
//     if (error.response && error.response.status === 401) {
//       localStorage.removeItem('accessToken');
//       localStorage.removeItem('user');
//       showError("Your session has expired. Please log in again.");
//       setTimeout(() => {
//         if (window.location.pathname !== '/login') {
//             window.location.href = '/login';
//         }
//       }, 1500);
//     }
//     return Promise.reject(error);
//   }
// );

export default api;
