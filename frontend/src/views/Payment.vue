<template>
  <div class="bg-light min-vh-100 d-flex flex-column">
    <Navbar />
    <div class="container py-5 flex-grow-1">
      <div class="mb-4">
        <h1 class="h3 fw-bold text-dark">Payment Center</h1>
        <p class="text-muted">Manage your unpaid orders and complete payments</p>
      </div>

      <div class="card mb-4">
        <div class="card-header d-flex align-items-center gap-2">
          <DollarSign :size="20" />
          <h5 class="mb-0">Payment Summary</h5>
        </div>
        <div class="card-body">
          <div class="row text-center">
            <div class="col-md-4">
              <p class="fs-4 fw-bold text-danger">₫{{ totalAmount.toFixed(2) }}</p>
              <p class="text-muted">Total Outstanding</p>
            </div>
            <div class="col-md-4">
              <p class="fs-4 fw-bold text-warning">{{ unpaidOrders.length }}</p>
              <p class="text-muted">Pending Orders</p>
            </div>
          </div>
        </div>
      </div>

      <div v-if="loading" class="text-center">Loading unpaid orders...</div>
      <div v-else-if="unpaidOrders.length === 0" class="card text-center py-5">
        <div class="card-body">
          <Package class="text-secondary mb-3" :size="40" />
          <h4 class="fw-semibold">No Pending Payments</h4>
          <p class="text-muted">All your orders have been paid for!</p>
        </div>
      </div>
      <div v-else>
        <div v-for="order in unpaidOrders" :key="order.order_id" class="card border-start border-4 border-warning mb-4">
          <div class="card-header d-flex justify-content-between align-items-start">
            <div>
              <h5 class="mb-1 d-flex align-items-center gap-2">
                <Package :size="18" /> Order #{{ order.order_id }}
              </h5>
              <small class="text-muted d-flex align-items-center gap-1">
                <Clock :size="14" /> Placed on {{ new Date(order.order_date).toLocaleDateString() }}
              </small>
            </div>
            <span class="badge bg-warning text-dark">
              <Clock :size="12" class="me-1" /> Pending Payment
            </span>
          </div>
          <div class="card-body">
            <div class="mb-3">
              <label class="form-label fw-semibold">Payment Method</label>
              <select class="form-select" v-model="paymentMethods[order.order_id]">
                <option value="" disabled >Select a method</option>
                <option value="Credit Card">Credit Card</option>
                <option value="Debit Card">Debit Card</option>
                <option value="Cash">Cash</option>
                <option value="E-Wallet">E-Wallet</option>
              </select>
            </div>
            <div class="d-flex justify-content-between align-items-center border-top pt-3">
              <span class="fw-bold fs-6">Total: ₫{{ parseFloat(order.order_total).toFixed(2) }}</span>
              <button class="btn btn-outline-primary d-flex align-items-center gap-2" @click="processPayment(order.order_id)" :disabled="loading">
                <CreditCard :size="16" /> Pay Now
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script>
import { CreditCard, Package, Clock, DollarSign } from 'lucide-vue-next';
import Navbar from '@/components/Navbar.vue';
import Footer from '@/components/Footer.vue';
import api from '@/api';
import { showSuccess, showError, showInfo } from '@/utils/toast';

export default {
  name: 'PaymentsPage',
  components: { Navbar, Footer, CreditCard, Package, Clock, DollarSign },
  data() {
    return {
      unpaidOrders: [],
      loading: false,
      paymentMethods: {},
    };
  },
  computed: {
    totalAmount() {
      return this.unpaidOrders.reduce((sum, order) => sum + parseFloat(order.order_total), 0);
    },
  },
  methods: {
    async fetchUnpaidOrders(customerId) {
      this.loading = true;
      try {
        const response = await api.get(`/payments/${customerId}/pending-payments`);
        console.log(response.data);
        const { pending_payments } = response.data;
        console.log("Pending payments", pending_payments);
        this.unpaidOrders = pending_payments;
        this.unpaidOrders.forEach(order => {
          this.paymentMethods[order.order_id]= '';
        });
      } catch (error) {
        const msg = error.response?.data?.detail || 'Failed to load unpaid orders.';
        showError(msg);
        console.log(error);
      } finally {
        this.loading = false;
      }
    },
    async processPayment(orderId) {
      const method = this.paymentMethods[orderId];
      if (!method) {
        showError(`Please select a payment method for Order #${orderId}`);
        return;
      }
      try {
        await api.post('/payments/process', {
          order_id: orderId,
          payment_method: method,
        });
        showSuccess(`Order #${orderId} has been paid with ${method}.`);
        this.unpaidOrders = this.unpaidOrders.filter(o => o.order_id !== orderId);
      } catch (error) {
        showError(`Failed to pay for order #${orderId}.`);
      }
    },
  },
  created() {
    const storedUser = localStorage.getItem('user');
    if (!storedUser) {showError("Please login before purchasing any medicines.");this.$router.push(`/login`);return};
    if (storedUser) {
      const customer = JSON.parse(storedUser);
      this.fetchUnpaidOrders(customer.user_id);
    }
  },
};
</script>