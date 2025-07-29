
import { createRouter, createWebHistory } from 'vue-router';

// We import the page components.
// Note: These files would need to be created/translated from your React views.
// For now, these are placeholders.
import Index from '../views/Index.vue';
import Login from '../views/Login.vue';
import Medicines from '../views/Medicines.vue';
import Prescriptions from '../views/Prescriptions.vue';
import History from '../views/History.vue';
import Checkout from '../views/Checkout.vue';
import Profile from '../views/Profile.vue';
import MedicineDetail from '../views/MedDetail.vue';
// import CashierCheckout from '../views/Cashier-checkout.vue';
// import ManagerDashboard from '../views/Manager-Dashboard.vue';
// import Restock from '../views/Restock.vue';
// import ValidatePrescription from '../views/ValidatePrescription.vue';
// import WarehouseRestock from '../views/Warehouse-restock.vue';
import Payments from '../views/Payment.vue';
// import TaskDelegation from '../views/Task-delegation.vue';
import NotFound from '../views/NotFound.vue';


const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: Index,
    },
    {
      path: '/login',
      name: 'login',
      component: Login,
    },
    {
      path: '/medicines',
      name: 'medicines',
      component: Medicines,
    },
    {
        path: '/medicine/:id', // Dynamic route for medicine details
        name: 'medicine-detail',
        component: MedicineDetail,
    },
    {
      path: '/prescriptions',
      name: 'prescriptions',
      component: Prescriptions,
    },
    {
      path: '/history',
      name: 'history',
      component: History,
    },
    {
      path: '/checkout',
      name: 'checkout',
      component: Checkout,
    },
    {
        path: '/profile',
        name: 'profile',
        component: Profile,
    },
    // {
    //     path: '/cashier-checkout',
    //     name: 'cashier-checkout',
    //     component: CashierCheckout,
    // },
    // {
    //     path: '/manager-dashboard',
    //     name: 'manager-dashboard',
    //     component: ManagerDashboard,
    // },
    // {
    //     path: '/restock',
    //     name: 'restock',
    //     component: Restock,
    // },
    // {
    //     path: '/validate-prescription',
    //     name: 'validate-prescription',
    //     component: ValidatePrescription,
    // },
    // {
    //     path: '/warehouse-staff-restock',
    //     name: 'warehouse-staff-restock',
    //     component: WarehouseRestock,
    // },
    {
        path: '/payment',
        name: 'payment',
        component: Payments,
    },
    // {
    //     path: '/task-delegation',
    //     name: 'task-delegation',
    //     component: TaskDelegation,
    // },
    {
      path: '/:pathMatch(.*)*',
      name: 'NotFound',
      component: NotFound,
    },
  ],
});

export default router;