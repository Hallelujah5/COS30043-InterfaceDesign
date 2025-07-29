import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import { createPinia } from 'pinia';
import Toast from 'vue-toastification'; 
import 'vue-toastification/dist/index.css'; 
import 'bootstrap/dist/css/bootstrap.min.css';

const pinia = createPinia();
const app = createApp(App);


const options = {
    position: "bottom-right",
    timeout: 4000,
    closeOnClick: true,
    pauseOnFocusLoss: true,
    pauseOnHover: true,
    draggable: true,
    hideProgressBar: true,
    theme: "light",
};

app.use(pinia);
app.use(router);
app.use(Toast, options); 

app.mount('#app');

 
