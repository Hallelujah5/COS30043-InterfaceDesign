<template>
  <div>
    <Navbar />
    <div class="container py-5">
      <button @click="goBack" class="btn btn-link mb-4 d-flex align-items-center">
        <ArrowLeft :size="16" class="me-2" />
        <span v-if="cartStore.cartItemCount > 0">Continue Shopping</span>
        <span v-else>Back to Shopping</span>
      </button>

      <div v-if="cartStore.cartItemCount === 0" class="text-center">
        <h3>Your Cart is Empty</h3>
        <p>Add some medicines to your cart to continue.</p>
        <button class="btn btn-primary" @click="goToMedicines">
          Continue Shopping
        </button>
      </div>

      <div v-else class="row g-4">
        <!-- Left Column -->
        <div class="col-lg-8">
          <!-- Cart Items -->
          <div class="card mb-4">
            <div class="card-header">
              <h5 class="card-title mb-0 d-flex align-items-center">
                <CreditCard :size="20" class="me-2" />
                Your Order ({{ cartStore.cartItemCount }} items)
              </h5>
            </div>
            <div class="card-body">
              <div v-for="item in cartStore.items" :key="item.product_id" class="d-flex align-items-center justify-content-between border-bottom py-3">
                <img :src="item.image_url" :alt="item.name" width="64" height="64" class="rounded me-3" />
                <div class="flex-grow-1">
                  <h6 class="mb-1">{{ item.name }}</h6>
                  <small class="text-muted">{{ item.manufacturer }}</small>
                  <div>
                    <span class="badge bg-secondary mt-1">{{ item.category }}</span>
                  </div>
                </div>
                <div class="d-flex align-items-center gap-2">
                  <button class="btn btn-outline-secondary btn-sm" @click="handleQuantityChange(item.product_id, item.quantity - 1)">
                    <Minus :size="16" />
                  </button>
                  <span class="mx-2">{{ item.quantity }}</span>
                  <button class="btn btn-outline-secondary btn-sm" @click="handleQuantityChange(item.product_id, item.quantity + 1)">
                    <Plus :size="16" />
                  </button>
                </div>
                <div class="text-end mx-3">
                  <strong>₫{{ (item.price * item.quantity).toFixed(2) }}</strong>
                  <br />
                  <small>₫{{ item.price }} each</small>
                </div>
                <button class="btn btn-outline-danger btn-sm" @click="removeItem(item.product_id)">
                  <Trash2 :size="16" />
                </button>
              </div>
            </div>
          </div>

          <!-- Billing Info -->
          <div class="card mb-4">
            <div class="card-header">
              <h5 class="card-title d-flex align-items-center mb-0">
                <User :size="20" class="me-2" />
                Contact & Delivery Details
              </h5>
            </div>
            <div class="card-body">
              <form class="row g-3" @submit.prevent="handlePlaceOrder">
                <div class="col-12">
                  <label for="deliveryParty" class="form-label d-flex align-items-center">
                    <Package :size="16" class="me-2 text-muted" /> Delivery Option
                  </label>
                  <select class="form-select" id="deliveryParty" v-model="orderFormData.delivery_party" required>
                    <option value="XanhSM">XanhSM</option>
                    <option value="Be">Be</option>
                    <option value="Grab">Grab</option>
                    <option value="Shopee">Shopee</option>
                  </select>
                </div>
                <div class="col-12">
                  <label for="deliveryAddress" class="form-label d-flex align-items-center">
                    <MapPin :size="16" class="me-2 text-muted" /> Delivery Address
                  </label>
                  <input type="text" class="form-control" id="deliveryAddress" v-model="orderFormData.delivery_address" placeholder="Street address, apartment, etc." required />
                </div>
              </form>
            </div>
          </div>
        </div>

        <!-- Right Column - Summary -->
        <div v-if="cartStore.cartItemCount > 0" class="col-lg-4">
          <div class="card">
            <div class="card-header">
              <h5 class="card-title mb-0">Order Summary</h5>
            </div>
            <div class="card-body">
              <div class="d-flex justify-content-between mb-2">
                <span>Subtotal</span>
                <strong>₫{{ subtotal.toFixed(2) }}</strong>
              </div>
              <div class="d-flex justify-content-between mb-2">
                <span>Shipping</span>
                <strong>{{ shipping === 0 ? "Free" : `₫${shipping.toFixed(2)}` }}</strong>
              </div>
              <hr />
              <div class="d-flex justify-content-between mb-4">
                <span class="fw-bold">Total</span>
                <strong class="fs-5">₫{{ total.toFixed(2) }}</strong>
              </div>
              <button type="submit" @click="handlePlaceOrder" class="btn btn-success w-100">
                Place Order
              </button>
              <div class="text-muted text-center mt-3 small">
                Free shipping over ₫50 · Secure SSL checkout
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ArrowLeft, Minus, Plus, Trash2, CreditCard, MapPin, User, Package, ShowerHead } from 'lucide-vue-next';
import Navbar from '@/components/Navbar.vue';
import { useCartStore } from '@/stores/cart';
import api from '@/api';
import { showSuccess, showError, showInfo } from '@/utils/toast';
import { useRouter } from 'vue-router';


const router = useRouter();
export default {
  name: 'CheckoutPage',
  components: { Navbar, ArrowLeft, Minus, Plus, Trash2, CreditCard, MapPin, User, Package },
  data() {
    return {
      orderFormData: {
        delivery_party: 'XanhSM',
        delivery_address: '',
        order_source: 'Online',
      },
      cartStore: useCartStore(),
    };
  },
  computed: {
    subtotal() {
      return this.cartStore.cartTotal;
    },
    shipping() {
      return this.subtotal > 50000 ? 0 : 15000; 
    },
    total() {
      return this.subtotal + this.shipping;
    },
  },
  methods: {
    goBack() {
      this.$router.back();
    },
    goToMedicines() {
      this.$router.push('/medicines');
    },
    handleQuantityChange(id, newQuantity) {
      if (newQuantity <= 0) {
        this.cartStore.removeFromCart(id);
      } else {
        this.cartStore.updateQuantity(id, newQuantity);
      }
    },
    removeItem(id) {
      this.cartStore.removeFromCart(id);
    },
    async handlePlaceOrder() {
      if (this.cartStore.items.length === 0) {
        showError('Your cart is empty.');
        return;
      }

      const user = JSON.parse(localStorage.getItem('user'));
      const branchId = localStorage.getItem('branch_id');

      const payload = {
        customer_id: user?.user_id || 1,
        branch_id: parseInt(branchId),
        product_details: this.cartStore.items.map(item => ({
          product_id: item.product_id,
          quantity: item.quantity,
        })),
        ...this.orderFormData,
      };

      try {
        await api.post('/orders/place', payload);
        showSuccess('Order placed successfully!');
        this.cartStore.clearCart();
        this.$router.push('/');
      } catch (err) {
        const msg = err.response?.data?.detail || 'Failed to place order.';
        showError(msg);
      }
    },
  },
  created(){
      const user = localStorage.getItem("user");
      if (!user) {showError("Please login before purchasing any medicines.");this.$router.push(`/login`);return};
  }
};
</script>