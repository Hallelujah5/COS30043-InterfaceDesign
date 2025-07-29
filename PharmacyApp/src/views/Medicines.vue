<!-- FILE: src/pages/Medicines.vue -->
<!-- -->
<!-- This page displays all available medicines, with search and filter functionality. -->

<template>
  <div class="bg-light min-vh-100">
    <Navbar />

    <div class="container py-5">
      <div class="mb-4">
        <h1 class="h3 fw-bold">All Medicines</h1>
        <p class="text-muted">Browse our medicines and health products</p>
      </div>

      <!-- Filter and Search Controls -->
      <div class="bg-white rounded shadow-sm p-4 mb-4">
        <div class="row g-3">
          <div class="col-lg">
            <div class="position-relative">
              <Search class="position-absolute top-50 start-0 translate-middle-y ms-3 text-muted" />
              <!-- v-model provides two-way data binding for the search input -->
              <input
                type="text"
                class="form-control ps-5"
                placeholder="Search medicines..."
                v-model="searchTerm"
              />
            </div>
          </div>
          <div class="col-lg-auto">
            <!-- v-model also binds the selected category -->
            <select class="form-select" v-model="selectedCategory">
              <option value="all">All Categories</option>
              <!-- Loop through the unique categories computed property -->
              <option v-for="cat in uniqueCategories" :key="cat" :value="cat">
                {{ cat }}
              </option>
            </select>
          </div>
          <div class="col-lg-auto">
            <button class="btn btn-outline-secondary">
              <Filter class="me-2" />
              More Filters
            </button>
          </div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="text-center my-5">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
        <p class="mt-2">Loading products…</p>
      </div>

      <!-- Content after loading -->
      <div v-else>
        <p class="text-muted mb-3">
          Showing {{ filteredProducts.length }} of {{ products.length }} medicines
        </p>

        <!-- Products Grid -->
        <div class="row g-4">
          <!-- v-for loops through the computed filteredProducts array -->
          <div v-for="p in filteredProducts" :key="p.product_id" class="col-md-6 col-lg-4 d-flex">
            <div class="card h-100 shadow-sm w-100">
              <div class="card-header">
                <div class="text-center mb-3">
                  <div
                    class="bg-light rounded-circle d-inline-flex align-items-center justify-content-center"
                    :style="{ width: '150px', height: '150px' }"
                  >
                    <img
                      :src="p.image_url || '/default-product.png'"
                      :alt="p.name"
                      style="width: 100%; height: 100%; object-fit: contain;"
                    />
                  </div>
                </div>
                <div class="d-flex justify-content-between align-items-center mb-2">
                  <span
                    class="badge"
                    :class="{ 'bg-danger': p.is_prescription_required, 'bg-secondary': !p.is_prescription_required }"
                  >
                    {{ p.is_prescription_required ? "Prescription" : "OTC" }}
                  </span>
                </div>
                <h5 class="card-title">{{ p.name }}</h5>
                <p class="text-muted mb-1">{{ p.category }}</p>
                <p class="text-muted small">{{ p.description }}</p>
              </div>
              <div class="card-body">
                <div class="d-flex align-items-center mb-2">
                  <strong class="text-primary">₫{{ p.price.toFixed(2) }}</strong>
                </div>
              </div>
              <div class="card-footer d-flex justify-content-between">
                 <button class="btn btn-outline-primary flex-grow-1 me-2" @click="viewDetails(p.product_id)">
                    View details
                </button>
                <button class="btn btn-primary flex-grow-1" @click="handleAddToCart(p)">
                  <ShoppingCart class="me-2" :size="16" />
                  Add to Cart
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- No Results Message -->
        <div v-if="filteredProducts.length === 0" class="text-center py-5">
          <div class="fs-1 text-muted mb-3">🔍</div>
          <h4>No medicines found</h4>
          <p class="text-muted">Try adjusting your search terms or filters</p>
        </div>
      </div>
    </div>

    <Footer />
  </div>
</template>

<script>
import Navbar from '@/components/Navbar.vue';
import Footer from '@/components/Footer.vue';
import { useCartStore } from '@/stores/cart';
import api from '@/api';
import { ShoppingCart, Search, Filter } from 'lucide-vue-next';

export default {
  name: 'MedicinesPage',
  components: { Navbar, Footer, ShoppingCart, Search, Filter },
  data() {
    return {
      loading: true,
      searchTerm: "",
      selectedCategory: "all",
      products: [],
    };
  },
  computed: {
    // Computed properties are reactive and cache their results.
    // They automatically update when their dependencies (like 'products' or 'searchTerm') change.
    uniqueCategories() {
      const categories = this.products.map(p => p.category);
      return [...new Set(categories)];
    },
    filteredProducts() {
      return this.products.filter(p => {
        const matchesSearch =
          p.name.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
          p.description.toLowerCase().includes(this.searchTerm.toLowerCase());
        const matchesCategory =
          this.selectedCategory === "all" || p.category === this.selectedCategory;
        return matchesSearch && matchesCategory;
      });
    },
  },
  methods: {
    handleAddToCart(product) {
      const user = localStorage.getItem("user");
      const userParse = user ? JSON.parse(user) : null;
      const hasPrescription = userParse?.has_prescription;

      if (product.is_prescription_required && !hasPrescription) {
        alert("You need an approved prescription to buy this medicine."); // Placeholder for toast notification
        return;
      }
      
      const cartStore = useCartStore();
      cartStore.addToCart(product);
      alert(`${product.name} added to cart!`); // Placeholder for toast notification
    },
    viewDetails(productId) {
      this.$router.push(`/medicine/${productId}`);
    },
    async fetchProducts() {
      try {
        const res = await api.get("/products");
        this.products = res.data;
      } catch (err) {
        alert("Failed to load products"); // Placeholder for toast notification
      } finally {
        this.loading = false;
      }
    },
  },
  mounted() {
    // mounted() is the hook to call when the component is first loaded,
    // similar to useEffect with an empty dependency array.
    this.fetchProducts();
  },
};
</script>

<style scoped>
.card-footer {
    background-color: white;
    border-top: none;
}
</style>