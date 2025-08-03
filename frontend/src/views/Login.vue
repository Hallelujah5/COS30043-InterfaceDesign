<template>
  <div
    class="min-vh-100 d-flex align-items-center justify-content-center"
    style="background: linear-gradient(to bottom right, #ebf8ff, #e6fffa);"
  >
    <div class="w-100" style="max-width: 450px; padding: 1rem;">
      <div class="text-center mb-4">
        <h2>Welcome to FPT Long Chau!</h2>
        <p class="text-muted">Your trusted pharmaceutical marketplace</p>
      </div>

      <!-- Login/Register Tabs -->
      <div class="nav nav-tabs mb-3">
        <div class="col-6">
          <button
            class="nav-link w-100"
            :class="{ active: activeTab === 'login' }"
            @click="activeTab = 'login'"
          >
            Login
          </button>
        </div>
        <div class="col-6">
          <button
            class="nav-link w-100"
            :class="{ active: activeTab === 'register' }"
            @click="activeTab = 'register'"
            :disabled="activeRole === 'Staff'"
          >
            Register
          </button>
        </div>
      </div>

      <!-- Login Form -->
      <div v-if="activeTab === 'login'" class="card my-3">
        <div class="card-body">
          <h4 class="card-title mb-3 d-flex align-items-center">
            <LogIn class="me-2" /> Sign In
          </h4>
          <form @submit.prevent="handleLogin" noValidate>
            <div class="mb-3">
              <h5 class="form-label my-2">I am a:</h5>
              <div class="nav nav-tabs mb-3">
                <div class="col-6">
                  <button
                    type="button"
                    class="nav-link w-100"
                    :class="{ active: activeRole === 'Customer' }"
                    @click="activeRole = 'Customer'"
                  >
                    Customer
                  </button>
                </div>
                <div class="col-6">
                  <button
                    type="button"
                    class="nav-link w-100"
                    :class="{ active: activeRole === 'Staff' }"
                    @click="activeRole = 'Staff'"
                  >
                    Staff
                  </button>
                </div>
              </div>
            </div>
            <div class="mb-3">
              <label for="loginEmail" class="form-label">Email</label>
              <input v-focus 
                id="loginEmail"
                type="email"
                class="form-control"
                placeholder="Enter your email"
                v-model="loginData.email"
                required
              />
            </div>
            <div class="mb-3">
              <label for="loginPassword" class="form-label">Password</label>
              <input
                id="loginPassword"
                type="password"
                class="form-control"
                placeholder="Enter your password"
                v-model="loginData.password"
                required
              />
            </div>
            <button type="submit" class="btn btn-primary w-100">Sign In</button>
          </form>
          <div class="text-center mt-2">
            <a href="#" class="link-secondary">Forgot your password?</a>
          </div>
        </div>
      </div>

      <!-- Register Form -->
      <div v-if="activeTab === 'register'" class="card my-3">
        <div class="card-body">
          <h5 class="card-title mb-3 d-flex align-items-center">
            <User class="me-2" /> Create Account
          </h5>
          <form @submit.prevent="handleRegister">
            <div class="row">
                <div class="col-md-6 mb-3">
                    <label for="registerFName" class="form-label">First Name</label>
                    <input v-focus id="registerFName" type="text" class="form-control" placeholder="First Name" v-model="registerData.fname" required />
                </div>
                <div class="col-md-6 mb-3">
                    <label for="registerLName" class="form-label">Last Name</label>
                    <input id="registerLName" type="text" class="form-control" placeholder="Last Name" v-model="registerData.lname" required />
                </div>
            </div>
            <div class="mb-3">
              <label for="registerEmail" class="form-label">Email</label>
              <input id="registerEmail" type="email" class="form-control" placeholder="Enter your email" v-model="registerData.email" required />
            </div>
            <div class="mb-3">
              <label for="registerPassword" class="form-label">Password</label>
              <input id="registerPassword" type="password" class="form-control" placeholder="Create a password" v-model="registerData.password" required />
            </div>
            <div class="mb-3">
              <label for="confirmPassword" class="form-label">Confirm Password</label>
              <input id="confirmPassword" type="password" class="form-control" placeholder="Confirm your password" v-model="registerData.confirmPassword" required />
            </div>
            <div class="mb-3">
              <label for="registerPhone" class="form-label">Phone Number (Optional)</label>
              <input id="registerPhone" type="text" class="form-control" placeholder="Enter your phone number" v-model="registerData.phone_number" />
            </div>
            <div class="mb-3">
              <label for="registerAddress" class="form-label">Address (Optional)</label>
              <input id="registerAddress" type="text" class="form-control" placeholder="Enter your address" v-model="registerData.address" />
            </div>
            <button type="submit" class="btn btn-success w-100">Create Account</button>
          </form>
        </div>
      </div>

      <p class="text-center small text-muted mt-3">
        By continuing, you agree to our
        <router-link to="/terms" class="text-decoration-none">Terms of Service</router-link>
        and
        <router-link to="/privacy" class="text-decoration-none">Privacy Policy</router-link>.
      </p>
    </div>
  </div>
</template>

<script>
import { LogIn, User } from 'lucide-vue-next';
import api from '@/api';
// Importing my toast utility functions
import { showInfo, showSuccess, showError } from '@/utils/toast';

export default {
  name: 'LoginPage',
  components: { LogIn, User },
  data() {
    return {
      activeRole: 'Customer',
      activeTab: 'login',
      loginData: { email: '', password: '' },
      registerData: {
        fname: '',
        lname: '',
        email: '',
        password: '',
        confirmPassword: '',
        phone_number: '',
        address: '',
      },
    };
  },
  methods: {
    async handleLogin() {
      const { email, password } = this.loginData;
      if (!email || !password) {
        showError('Please enter email and password!');
        return;
      }
      showInfo('Logging in...');

      const endpoint = this.activeRole === 'Customer' ? '/auth/customers/login' : '/auth/staff/login';

      try {
        const res = await api.post(endpoint, { email, password });

        // 1. Destructure the token and user info from the response data.
        const { access_token, token_type, ...userInfo } = res.data;

        // 2. Store the token and user data separately in localStorage.
        localStorage.setItem('accessToken', access_token);
        localStorage.setItem('user', JSON.stringify(userInfo));
        if (!localStorage.getItem("branch_id")) {localStorage.setItem("branch_id", "1")}
        showSuccess('Login successful!');
        this.$router.push('/');
      } catch (err) {
        const msg = err.response?.data?.detail || 'Login failed. Please try again.';
        showError(msg);
      }
    },
    async handleRegister() {
      const { fname, lname, email, password, confirmPassword, phone_number, address } = this.registerData;
      if (!fname || !lname || !email || !password || !confirmPassword) {
        showError('Please fill out all required fields!');
        return;
      }
      if (password !== confirmPassword) {
        showError('Passwords do not match!');
        return;
      }

      const payload = {
        first_name: fname,
        last_name: lname,
        email,
        password,
        phone_number: phone_number || null,
        address: address || null,
        image_url: null,
      };

      try {
        showInfo('Registering... Please wait.');
        const res = await api.post('/customers/register', payload);
        showSuccess(res.data.message || 'Registration successful!');
        this.activeTab = 'login';
      } catch (err) {
        const msg = err.response?.data?.detail || 'Registration failed.';
        showError(msg);
      }
    },
  },
};
</script>
