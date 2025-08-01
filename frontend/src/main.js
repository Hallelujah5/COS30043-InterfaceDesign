import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import { createPinia } from 'pinia';
import Toast from 'vue-toastification'; 
import 'vue-toastification/dist/index.css'; 
import 'bootstrap/dist/css/bootstrap.min.css';

const pinia = createPinia();
const app = createApp(App);



// Register a global custom directive `v-focus`
app.directive('focus', {
  // FOCus ưhen bound element is mounted into the DOM
  mounted(el) {
    el.focus();
  }
});
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

 
