// FILE: frontend/src/api.js
// REASON FOR CHANGE: Updated the baseURL to use the secure HTTPS protocol
// to fix the "Mixed Content" error. Also added a global error handler for expired sessions.

import axios from "axios";
import { showError } from '@/utils/toast'; // Assuming you have a toast utility

const api = axios.create({
    // Replace the old http:// URL with your secure Railway URL
    baseURL: "https://cos30043-interfacedesign-production-ff6f.up.railway.app"
});

// Add a response interceptor to handle 401 Unauthorized errors globally
// This is a best practice for deployed applications.
api.interceptors.response.use(
  (response) => response, // Directly return successful responses
  (error) => {
    // Check if the error is a 401 Unauthorized (which means the JWT is invalid or expired)
    if (error.response && error.response.status === 401) {
      
      // Clear the user's session from localStorage to log them out
      localStorage.removeItem('accessToken');
      localStorage.removeItem('user');
      
      // Show a toast message to the user
      showError("Your session has expired. Please log in again.");

      // Redirect to the login page after a short delay
      setTimeout(() => {
        // Check to prevent redirect loops if the login page itself causes a 401
        if (window.location.pathname !== '/login') {
            window.location.href = '/login';
        }
      }, 1500);
    }
    
    // Return the error so that individual .catch() blocks can still handle it if needed
    return Promise.reject(error);
  }
);

export default api;
