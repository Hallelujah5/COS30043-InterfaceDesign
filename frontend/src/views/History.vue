<template>
  <div class="bg-light min-vh-100">
    <Navbar />
    <div class="container py-5">
      <div class="mb-4">
        <h1 class="h3 fw-bold">Purchase History</h1>
        <p class="text-muted">Review your past medicine orders</p>
      </div>

      <ul class="nav nav-tabs mb-4">
        <li v-for="tab in tabs" :key="tab" class="nav-item">
          <button class="nav-link" :class="{ active: activeTab === tab }" @click="activeTab = tab">
            {{ tab }}
          </button>
        </li>
      </ul>

      <div v-if="loading" class="text-center my-5">Loading order history...</div>
      <div v-else-if="filteredOrders.length > 0" class="row">
        <div v-for="order in filteredOrders" :key="order.id" class="col-md-4 mb-4">
          <div class="card shadow-sm h-100">
            <div class="p-3 d-flex flex-column h-100">
              <div class="d-flex justify-content-between align-items-start">
                 <h5 class="card-title mb-2 d-flex align-items-center">
                    <div class="bg-light rounded-circle d-flex align-items-center justify-content-center me-3" style="width: 40px; height: 40px;">
                        <span class="fs-5">📦</span>
                    </div>
                    Order #{{ order.id }}
                </h5>
                <button v-if="canCancel(order.status)" class="btn btn-sm btn-outline-danger" @click="handleCancelOrder(order.id)">
                  Cancel
                </button>
              </div>
              <div class="text-muted mb-1"><em>{{ order.date }}</em></div>
              <div class="text-muted mb-2">Branch: <strong>{{ order.branch }}</strong></div>
              <hr />
              <div v-for="(med, idx) in order.medicines" :key="idx" class="d-flex justify-content-between border-bottom py-1">
                <span>{{ med.name }}</span>
                <span>{{ med.quantity }} × ₫{{ med.price.toLocaleString() }}</span>
              </div>
              <div class="fw-semibold text-end mt-2">Total: ₫{{ order.total.toLocaleString() }}</div>
              <div class="mt-auto pt-3 border-top">
                <div class="d-flex justify-content-between align-items-center mb-2">
                  <span class="badge" :class="getStatusBadgeClass(order.status)">
                    <component :is="getStatusIcon(order.status)" :size="14" class="me-1" />
                    {{ order.status }}
                  </span>
                  <span v-if="order.trackingNumber" class="text-muted small">#{{ order.trackingNumber }}</span>
                </div>
                <div v-if="order.deliveryStatus" class="bg-info bg-opacity-10 rounded p-3 small text-secondary" style="font-size: 0.875rem;">
                  <div class="mb-1">{{ order.deliveryStatus }} via <strong>{{ order.deliveryParty }}</strong></div>
                  <div>Estimated Delivery: <em>{{ order.estimatedDelivery }}</em></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div v-else class="text-center py-5">
        <div class="fs-1 text-muted mb-3">📭</div>
        <h4>No orders found</h4>
        <p class="text-muted">No items match this category.</p>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script>
import { BadgeCheck, Clock, XCircle } from 'lucide-vue-next';
import Navbar from '@/components/Navbar.vue';
import Footer from '@/components/Footer.vue';
import api from '@/api';
import { showSuccess, showError, showInfo } from '@/utils/toast';
import { useRouter } from 'vue-router';

const router = useRouter();
export default {

  name: 'HistoryPage',
  components: { Navbar, Footer, BadgeCheck, Clock, XCircle },
  data() {
    return {
      activeTab: 'All',
      tabs: ['All', 'Pending', 'Finished', 'Cancelled'],
      orders: [],
      loading: true,
    };
  },
  computed: {
    filteredOrders() {
      switch (this.activeTab) {
        case 'Pending':
          return this.orders.filter(o => ['Pending', 'Processing'].includes(o.status));
        case 'Finished':
          return this.orders.filter(o => ['Delivered', 'Ready for Pickup'].includes(o.status));
        case 'Cancelled':
          return this.orders.filter(o => ['Cancelled', 'Rejected-Refund'].includes(o.status));
        default:
          return this.orders;
      }
    },
  },
  methods: {
    canCancel(status) {
        return !['Delivered', 'Cancelled', 'Rejected-Refund'].includes(status);
    },
    getStatusBadgeClass(status) {
      const statusMap = {
        Pending: 'bg-secondary',
        Paid: 'bg-warning text-dark',
        Processing: 'bg-warning text-dark',
        'Ready for Pickup': 'bg-primary',
        Delivered: 'bg-success',
        Cancelled: 'bg-danger',
        'Rejected-Refund': 'bg-danger',
      };
      return statusMap[status] || 'bg-secondary';
    },
    getStatusIcon(status) {
        const iconMap = {
            Delivered: 'BadgeCheck',
            Cancelled: 'XCircle',
            'Rejected-Refund': 'XCircle'
        }
        return iconMap[status] || 'Clock';
    },
    async fetchOrders() {
      try {
        const userData = localStorage.getItem('user');
        const token = localStorage.getItem('accessToken');
          if (!token){
          showError('Please log in to view your orders.');
          router.push('/login');
          return;
        }
        const { user_id: customerId } = JSON.parse(userData);
        const res = await api.get(`/customers/${customerId}/orders`);
        const rawOrders = res.data;

        const grouped = rawOrders.reduce((acc, item) => {
          let order = acc.find(o => o.id === item.order_id);
          if (!order) {
            order = {
              id: item.order_id,
              date: new Date(item.order_date).toLocaleDateString(),
              total: parseFloat(item.total_amount),
              status: item.order_status,
              branch: item.branch_name,
              deliveryStatus: item.delivery_status,
              deliveryParty: item.delivery_party,
              estimatedDelivery: item.estimated_delivery_date ? new Date(item.estimated_delivery_date).toLocaleString() : null,
              trackingNumber: item.tracking_number,
              medicines: [],
            };
            acc.push(order);
          }
          order.medicines.push({
            name: item.product_name,
            quantity: item.quantity,
            price: parseFloat(item.unit_price),
          });
          return acc;
        }, []);
        this.orders = grouped;
      } catch (error) {
        showError('Failed to load order history.');
      } finally {
        this.loading = false;
      }
    },
    async handleCancelOrder(orderId) {
      try {
        await api.put(`/orders/${orderId}/cancel`);
        const order = this.orders.find(o => o.id === orderId);
        if (order) {
          order.status = 'Cancelled';
        }
      } catch (error) {
        showError('Failed to cancel order.');
      }
    },
  },
  mounted() {
    this.fetchOrders();
  },
};
</script>