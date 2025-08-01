<template>
  <div>
    <Navbar />
    <div v-if="!medicine" class="text-center py-5">Loading...</div>
    <div v-else class="container py-5">
      <button class="btn btn-outline-secondary mb-4" @click="goBack">
        <ArrowLeft :size="16" class="me-2" />
        Back to Medicines
      </button>
      <div class="row g-4">
        <div class="col-md-6">
          <div class="bg-white rounded shadow p-4">
            <img :src="medicine.image_url" :alt="medicine.name" class="img-fluid rounded" style="width: 100%; height: 100%; object-fit: contain;" />
          </div>
        </div>
        <div class="col-md-6">
          <h2>{{ medicine.name }}</h2>
          <p>{{ medicine.description }}</p>
          <p class="text-muted"><strong>Manufacturer:</strong> {{ medicine.manufacturer }}</p>
          <span class="badge bg-secondary me-2">{{ medicine.category }}</span>
          <span class="badge" :class="stockCount > 0 ? 'bg-success' : 'bg-danger'">
            {{ stockCount > 0 ? "In Stock" : "Out of Stock" }}
          </span>
          <h4 class="text-primary mt-3">₫{{ medicine.price.toFixed(2) }}</h4>
          <div class="card mt-4">
            <div class="card-body">
              <div class="mb-3 d-flex align-items-center gap-3">
                <label class="form-label mb-0">Quantity:</label>
                <div class="btn-group" role="group">
                  <button class="btn btn-outline-secondary" @click="quantity = Math.max(1, quantity - 1)">-</button>
                  <span class="btn">{{ quantity }}</span>
                  <button class="btn btn-outline-secondary" @click="quantity = Math.min(stockCount, quantity + 1)">+</button>
                </div>
                <label class="form-label mb-0 mx-5">
                  Current stock:
                  <span v-if="stockCount !== null" class="fw-bold">{{ stockCount }}</span>
                  <span v-else>Loading...</span>
                </label>
              </div>
              <p class="mb-3 fw-medium">Total: ₫{{ (medicine.price * quantity).toFixed(2) }}</p>
              <div class="d-flex gap-3">
                <button class="btn btn-outline-primary flex-fill" :disabled="!stockCount" @click="handleAddToCart()">
                  <ShoppingCart :size="16" class="me-2" /> Add to Cart
                </button>
                <button class="btn btn-primary flex-fill" :disabled="!stockCount" @click="handleBuyNow">
                  Buy Now
                </button>
              </div>
              <div v-if="medicine.is_prescription_required" class="alert alert-warning d-flex align-items-start mt-4">
                <AlertTriangle class="me-2 mt-1 text-warning" />
                <div>
                  <strong>Prescription Required</strong>
                  <p class="mb-0">This medication requires a valid prescription from a licensed physician.</p>
                </div>
              </div>
            </div>
          </div>
          <div class="d-flex justify-content-between mt-4 bg-light rounded p-3">
            <div class="d-flex align-items-center gap-2"><Shield class="text-success" :size="16" /><small class="text-muted">FDA Approved</small></div>
            <div class="d-flex align-items-center gap-2"><Truck class="text-primary" :size="16" /><small class="text-muted">Free Delivery</small></div>
            <div class="d-flex align-items-center gap-2"><Clock class="text-purple" :size="16" /><small class="text-muted">24/7 Support</small></div>
          </div>
        </div>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script>
import { ShoppingCart, ArrowLeft, Shield, Clock, Truck, AlertTriangle } from 'lucide-vue-next';
import Navbar from '@/components/Navbar.vue';
import Footer from '@/components/Footer.vue';
import { useCartStore } from '@/stores/cart';
import api from '@/api';
import { showSuccess, showError, showInfo } from '@/utils/toast';

export default {
  name: 'MedicineDetailPage',
  components: { Navbar, Footer, ShoppingCart, ArrowLeft, Shield, Clock, Truck, AlertTriangle },
  data() {
    return {
      medicine: null,
      quantity: 1,
      stockCount: null,
    };
  },
  methods: {
    goBack() {
        this.$router.push('/medicines');
    },
    async fetchProduct() {
      try {
        const res = await api.get(`/products/${this.$route.params.id}`);
        this.medicine = res.data;
        console.log("Medicine in question: ",this.medicine);

      } catch (error) {
        showError('Failed to fetch product.');
      }
    },
    async fetchBranchStock() {
      try {
        const branchId = localStorage.getItem('branch_id');
        if (!branchId) return;
        const res = await api.get(`/product_stock/branches/${branchId}`);
        const medStock = res.data.find(item => item.product_id == this.$route.params.id);
        this.stockCount = medStock ? medStock.stock_quantity : 0;
      } catch (error) {
        this.stockCount = 0;
        showError('Error in fetching stock count.');
      }
    },
    handleAddToCart() {
        const user = localStorage.getItem("user");
      if (!user) {showError("Please login before purchasing any medicines.");this.$router.push(`/login`);return};
      console.log("handleAddToCart triggered.")
      const hasPrescription = localStorage.getItem('has_prescription') === 'true';
      if (this.medicine.is_prescription_required && !hasPrescription) {
        showError('You need an approved prescription to buy this medicine.');
        return;
      }
      const cartStore = useCartStore();
      const productWithQty = { ...this.medicine, quantity: this.quantity };
      cartStore.addToCart(productWithQty);
      showSuccess(`${this.quantity} ${this.medicine.name} added to your cart`);
    },
    handleBuyNow() {
      const user = localStorage.getItem("user");
      if (!user) {showError("Please login before purchasing any medicines.");this.$router.push(`/login`);return};
      this.handleAddToCart();
      showInfo('Taking you to secure checkout...');
      this.$router.push('/checkout');
    },
  },
  created() {
    this.fetchProduct();
    this.fetchBranchStock();
  },
};
</script>

<style scoped>
.text-purple {
    color: #6f42c1;
}
</style>


