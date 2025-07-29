// Main entry point for the Vue application.

import { createApp } from 'vue';
import App from './App.vue';
import router from './router'; 
import { createPinia } from 'pinia'; 

// Import global CSS files - same as in your React project
import 'bootstrap/dist/css/bootstrap.min.css';
import './assets/main.css'; // Vue's equivalent for index.css

// Create the state management instance
const pinia = createPinia();

// Create the Vue app instance
const app = createApp(App);


app.use(pinia);
app.use(router);

// Mount the app to the DOM element with id="app" in your index.html
app.mount('#app');
