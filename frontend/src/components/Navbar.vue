<template>
  <nav class="navbar navbar-expand-md navbar-light bg-white shadow-sm sticky-top">
    <div class="container">
      <!-- Logo -->
      <router-link to="/" class="navbar-brand d-flex align-items-center">
        <div class="bg-primary text-white p-2 rounded me-2">
          <!-- The image path is relative to the public folder in a typical Vue setup -->
          <img src="/Longchau2.png" alt="Longchau Pharmacy Logo" width="200" />
        </div>
      </router-link>

      <!-- Mobile Menu Toggler -->
      <button
        class="navbar-toggler"
        type="button"
        @click="toggleMenu"
      >
        <span class="navbar-toggler-icon"></span>
      </button>

      <!-- Navbar Collapse: Vue's class binding is used to toggle the 'show' class -->
      <div
        class="collapse navbar-collapse"
        :class="{ 'show': isMenuOpen }"
      >
        <!-- Left Links -->
        <ul class="navbar-nav me-auto mb-2 mb-md-0">
          <li class="nav-item">
            <router-link to="/medicines" class="nav-link">Medicines</router-link>
          </li>

          <!-- Customer-only links, rendered with v-if -->
          <template v-if="isCustomer">
            <li class="nav-item">
              <router-link to="/prescriptions" class="nav-link">Prescriptions</router-link>
            </li>
            <li class="nav-item">
              <router-link to="/history" class="nav-link">History</router-link>
            </li>
            <li class="nav-item">
              <router-link to="/payment" class="nav-link">Payments</router-link>
            </li>
          </template>

          <!-- Staff-only links based on role -->
          <li v-if="!isCustomer && staffType === 'Pharmacist'" class="nav-item">
            <router-link to="/validate-prescription" class="nav-link">Validate Prescription</router-link>
          </li>
          <li v-if="!isCustomer && staffType === 'Cashier'" class="nav-item">
            <router-link to="/cashier-checkout" class="nav-link">Checkout</router-link>
          </li>
           <li v-if="!isCustomer && staffType === 'BranchManager'" class="nav-item">
            <router-link to="/task-delegation" class="nav-link">Task delegation</router-link>
          </li>
          <li v-if="!isCustomer && staffType === 'BranchManager'" class="nav-item">
            <router-link to="/restock" class="nav-link">Restock</router-link>
          </li>
        </ul>

      

        <!-- Right Side Icons -->
        <div class="d-flex align-items-center gap-3">
          <router-link to="/checkout">
            <!-- The custom Button component is replaced with a standard button with Bootstrap classes -->
            <button class="btn btn-outline-primary position-relative">
              <ShoppingCart class="me-1" />
              <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                {{ cartCount }}
              </span>
            </button>
          </router-link>

          <!-- Conditional rendering for logged-in vs. logged-out users -->
          <template v-if="isLoggedIn">
            <router-link to="/profile">
              <button class="btn btn-outline-secondary">
                <User class="me-1" />
                {{ user?.last_name }}
              </button>
            </router-link>
            <button class="btn btn-danger" @click="logout">
              Logout
            </button>
          </template>
          <template v-else>
            <router-link to="/login">
              <button class="btn btn-primary">
                <LogIn class="me-2" />
                Login
              </button>
            </router-link>
          </template>
        </div>
      </div>
    </div>
  </nav>
</template>

<script>
// Import necessary libraries and components
import { RouterLink } from 'vue-router';
import { useCartStore } from '@/stores/cart';
import { ShoppingCart, User, LogIn, Search } from 'lucide-vue-next'; 

export default {
  name: 'Navbar',
  components: {
    RouterLink,
    ShoppingCart,
    User,
    LogIn,
    Search,
  },
  data() {
    
    return {
      isMenuOpen: false,
      user: null,
    };
  },
  computed: {
    // 'computed' properties are used for derived state, they update automatically
    cartCount() {
      // Accessing a getter from the Pinia cart store
      return useCartStore().cartItemCount;
    },
    isLoggedIn() {
      return !!this.user;   // !! is boolean
    },
    isCustomer() {
      return this.user?.role === 'Customer';
    },
    staffType() {
      return this.user?.role;
    },
  },
  methods: {
    // 'methods' contains functions that can be called from the template
    toggleMenu() {
      this.isMenuOpen = !this.isMenuOpen;
    },
    logout() {
      localStorage.removeItem('accessToken');
      localStorage.removeItem('user');
      // Redirect to login page
      window.location.href = '/';
    },
  },
  mounted() {
    // 'mounted' is a lifecycle hook that runs once the component is added to the DOM.
    // This is the equivalent of React's useEffect with an empty dependency array.
    const storedUser = localStorage.getItem('user');
    // const storedUser = localStorage.getItem('accessToken');
    if (storedUser) {
      this.user = JSON.parse(storedUser);
      console.log("JSON parsed user: ", this.user);
    }
  },
};
</script>

<style scoped>
.gap-3 {
  gap: 1rem; 
}
</style>