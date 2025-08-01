<template>
  <div>
    <Navbar />
    <div class="container py-5">
      <h2 class="mb-4">Cashier Checkout Management</h2>

      <div class="row mb-4">
        <div class="col-md-8">
          <label class="form-label">Search Orders</label>
          <div class="input-group">
            <span class="input-group-text"><Search size="16" /></span>
            <input
              type="text"
              class="form-control"
              placeholder="Search by order ID"
              v-model="searchTerm"
            />
          </div>
        </div>
        <div class="col-md-4">
          <label class="form-label">Filter by Status</label>
          <select class="form-select" v-model="selectedStatus">
            <option value="all">All</option>
            <option value="Processing">Processing</option>
            <option value="Ready for Pickup">Ready for Pickup</option>
            <option value="Rejected-Refund">Rejected-Refund</option>
            <option value="Delivered">Delivered</option>
          </select>
        </div>
      </div>

      <div v-if="filteredOrders.length > 0">
        <div class="card mb-4" v-for="order in filteredOrders" :key="order.order_id">
          <div class="card-header d-flex justify-content-between align-items-center">
            <div>
              <h5 class="card-title mb-0">Order #{{ order.order_id }}</h5>
              <small class="text-muted">
                Placed on {{ new Date(order.order_date).toLocaleDateString() }}
              </small>
            </div>
            <span :class="['badge', 'p-2', 'text-uppercase', getStatusClass(order.order_status)]">
              {{ order.order_status }}
            </span>
          </div>
          <div class="card-body">
            <div class="row mb-3">
              <div class="col-md-6">
                <h6><User size="16" class="me-1" /> Customer Info</h6>
                <p class="mb-1">First name: {{ order.customer_first_name }}</p>
                <p class="mb-1">Last name: {{ order.customer_last_name }}</p>
              </div>
            </div>

            <h6>Items</h6>
            <ul class="list-group mb-3">
              <li v-for="(item, idx) in order.order_items" :key="idx" class="list-group-item d-flex justify-content-between">
                <span>{{ item.product_name }}</span>
                <span>Qty: {{ item.quantity }} × ₫{{ item.unit_price.toFixed(2) }}</span>
              </li>
            </ul>

            <div class="d-flex justify-content-between mb-3">
              <strong>Total: ₫{{ order.total_amount.toFixed(2) }}</strong>
            </div>

            <div class="d-flex gap-2">
              <template v-if="order.order_status === 'Processing'">
                <button class="btn btn-success" @click="handleStatusChange(order.order_id, 'Ready for Pickup')">
                  <CheckCircle size="16" class="me-2" /> Approve
                </button>
                <button class="btn btn-danger" @click="handleStatusChange(order.order_id, 'Rejected-Refund')">
                  <XCircle size="16" class="me-2" /> Reject
                </button>
              </template>
              <template v-if="order.order_status === 'Ready for Pickup'">
                <button class="btn btn-primary" @click="handleStatusChange(order.order_id, 'Delivered')">
                  <Package size="16" class="me-2" /> Mark as Delivered
                </button>
              </template>
            </div>
          </div>
        </div>
      </div>
      <div v-else class="alert alert-info text-center">
        <Package size="24" class="mb-2" /> No orders found matching your criteria.
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { CheckCircle, XCircle, Search, Package, User } from 'lucide-vue-next';
import { showSuccess, showError } from '@/utils/toast';
import Navbar from '@/components/Navbar.vue';
import Footer from '@/components/Footer.vue';
import api from '@/api';

const orders = ref([]);
const searchTerm = ref('');
const selectedStatus = ref('all');

const fetchOrders = async () => {
  const user = JSON.parse(localStorage.getItem('user'));
  const cashierId = user?.user_id;

  if (!cashierId) {
    showError('Cashier not logged in.');
    return;
  }

  try {
    const res = await api.get('/orders/pending-cashier-review', {
      params: { cashier_id: cashierId },
    });
    orders.value = res.data.orders;
  } catch (err) {
    showError('Failed to load orders.');
    console.error('Checkout fetch failed:', err);
  }
};

onMounted(fetchOrders);

const handleStatusChange = async (id, newStatus) => {
  try {
    const response = await api.put(`/orders/${id}/status`, { status: newStatus });
    const updatedOrder = response.data;

    // Update the local state directly for instant UI feedback
    const orderIndex = orders.value.findIndex(o => o.order_id === id);
    if (orderIndex !== -1) {
      orders.value[orderIndex].order_status = updatedOrder.order_status;
    }
    showSuccess(`Order #${id} marked as ${updatedOrder.order_status}`);
  } catch (error) {
    showError(`Failed to update order #${id}: ${error.response?.data?.detail || 'Unknown error'}`);
  }
};

const filteredOrders = computed(() => {
  return orders.value.filter(order => {
    const matchesSearch = order.order_id.toString().includes(searchTerm.value);
    const matchesStatus = selectedStatus.value === 'all' || order.order_status === selectedStatus.value;
    return matchesSearch && matchesStatus;
  });
});

const getStatusClass = (status) => {
  switch (status) {
    case 'Processing': return 'bg-warning text-dark';
    case 'Ready for Pickup': return 'bg-success text-white';
    case 'Rejected-Refund': return 'bg-danger text-white';
    case 'Delivered': return 'bg-primary text-white';
    default: return 'bg-secondary text-white';
  }
};
</script>