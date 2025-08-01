<template>
  <div>
    <Navbar />
    <div v-if="!user" class="text-center py-5">Loading...</div>
    <div v-else class="container py-5">
      <h1 class="mb-3">My Profile</h1>
      <p class="text-muted">Manage your account</p>
      <div class="row gy-4">
        <!-- Profile Info -->
        <div class="col-lg-8">
          <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
              <div class="d-flex align-items-center">
                <User class="me-2" />
                <h5 class="mb-0">Profile Information</h5>
              </div>
              <button @click="handleEditToggle" :class="`btn btn-sm btn-${isEditing ? 'danger' : 'outline-secondary'}`">
                <X v-if="isEditing" class="me-1" />
                <Edit3 v-else class="me-1" />
                {{ isEditing ? 'Cancel' : 'Edit' }}
              </button>
            </div>
            <div class="card-body">
              <div class="row g-3">
                <div class="col-md-6">
                  <label class="form-label">First Name</label>
                  <input v-if="isEditing" class="form-control" v-model="form.fname" />
                  <p v-else class="form-control-plaintext">{{ user.first_name }}</p>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Last Name</label>
                  <input v-if="isEditing" class="form-control" v-model="form.lname" />
                  <p v-else class="form-control-plaintext">{{ user.last_name }}</p>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Email</label>
                  <input v-if="isEditing" type="email" class="form-control" v-model="form.email" />
                  <p v-else class="form-control-plaintext">{{ user.email }}</p>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Phone</label>
                  <input v-if="isEditing" class="form-control" v-model="form.phone_number" />
                  <p v-else class="form-control-plaintext">{{ user.phone_number }}</p>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Date of Birth</label>
                  <input v-if="isEditing" type="date" class="form-control" v-model="form.dateOfBirth" />
                  <p v-else class="form-control-plaintext">{{ new Date(user.dateOfBirth).toLocaleDateString() }}</p>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Address</label>
                  <input v-if="isEditing" class="form-control" v-model="form.address" />
                  <p v-else class="form-control-plaintext">{{ user.address }}</p>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Preferred Branch</label>
                    <select class="form-select" v-model="selectedBranch" @change="updateBranch" :disabled="!branches.length">
                        <option v-for="branch in branches" :key="branch.branch_id" :value="branch.branch_id">
                            {{ branch.name }}
                        </option>
                    </select>
                </div>
              </div>
              <div v-if="isEditing" class="text-end mt-3">
                <button @click="handleSave" class="btn btn-primary">
                  <Save class="me-1" /> Save Changes
                </button>
              </div>
            </div>
          </div>
        </div>
        <!-- Account Summary -->
        <div class="col-lg-4">
          <div class="card mb-4">
            <div class="card-body">
              <div class="d-flex align-items-center mb-3">
                <Calendar class="me-2 text-primary" />
                <div>
                  <small class="text-muted">Member Since</small>
                  <div>{{ new Date(user.memberSince).toLocaleDateString() }}</div>
                </div>
              </div>
              <div class="d-flex align-items-center">
                <Package class="me-2 text-success" />
                <div>
                  <small class="text-muted">Total Orders</small>
                  <!-- Placeholder for total orders count -->
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { User, Calendar, Package, Edit3, Save, X } from 'lucide-vue-next';
import Navbar from '@/components/Navbar.vue';
import api from '@/api';
import { showSuccess, showError, showInfo } from '@/utils/toast';

export default {
  name: 'ProfilePage',
  components: { Navbar, User, Calendar, Package, Edit3, Save, X },
  data() {
    return {
      user: null,
      isEditing: false,
      form: {
        fname: '',
        lname: '',
        email: '',
        phone_number: '',
        address: '',
        dateOfBirth: '',
      },
      branches: [],
      selectedBranch: localStorage.getItem('branch_id') || '1',
    };
  },
  methods: {
    async fetchCustomerDetails() {
      console.log("fetching user in /profile...")
      const data = localStorage.getItem('user');
      console.log("User fetched: ", data);
      if (!data) return this.$router.push('/login');
      const parsed = JSON.parse(data);
      console.log("Parsed data: ", parsed);
      try {
        const res = await api.get(`/customers/${parsed.user_id}`);
        this.user = res.data;
        this.form = {
          fname: this.user.first_name,
          lname: this.user.last_name,
          email: this.user.email,
          phone_number: this.user.phone_number,
          address: this.user.address,
          dateOfBirth: this.user.date_of_birth,
        };
      } catch (error) {
        showError('Could not load customer information.');
        this.$router.push('/login');
      }
    },
    async fetchBranches() {
      try {
        const res = await api.get('/branches');
        this.branches = res.data;
      } catch (err) {
        console.error('Failed to load branches', err);
      }
    },
    handleEditToggle() {
      if (this.isEditing) {
        // Reset form on cancel
        this.form = {
          fname: this.user.first_name,
          lname: this.user.last_name,
          email: this.user.email,
          phone_number: this.user.phone_number,
          address: this.user.address,
          dateOfBirth: this.user.dateOfBirth,
        };
      }
      this.isEditing = !this.isEditing;
    },
    handleSave() {
      // Here you would typically make an API call to update the user data
      const updatedUser = {
        ...this.user,
        first_name: this.form.fname,
        last_name: this.form.lname,
        email: this.form.email,
        phone_number: this.form.phone_number,
        address: this.form.address,
        dateOfBirth: this.form.dateOfBirth,
      };
      // For now, we just update local state and localStorage
      this.user = updatedUser;
      localStorage.setItem('user', JSON.stringify(updatedUser));
      this.isEditing = false;
      showSuccess('Profile updated successfully!');
    },
    updateBranch() {
        localStorage.setItem('branch_id', this.selectedBranch);
        showInfo('Branch updated!');
    }
  },
  created() {
    this.fetchCustomerDetails();
    this.fetchBranches();
  },
};
</script>