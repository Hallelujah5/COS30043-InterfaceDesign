<!-- FILE: src/pages/Medicines.vue -->
<!-- This is the complete, updated Vue component file. -->

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
              <input
                type="text"
                class="form-control ps-5"
                placeholder="Search medicines..."
                v-model="searchTerm"
              />
            </div>
          </div>
          <div class="col-lg-auto">
            <select class="form-select" v-model="selectedCategory">
              <option value="all">All Categories</option>
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
          <div v-for="p in filteredProducts" :key="p.product_id" class="col-sm-6 col-lg-4 d-flex">
            <div class="card h-100 shadow-sm border-0 rounded-3 w-100">
              <!-- Image Section -->
              <div class="position-relative text-center p-3">
                <div class="bg-white shadow-sm d-inline-flex align-items-center justify-content-center overflow-hidden"
                     :style="{ width: '150px', height: '150px' }">
                  <img
                    :src="p.image_url || '/default-product.png'"
                    :alt="p.name"
                    class="img-fluid"
                    style="max-width: 100%; max-height: 100%; object-fit: contain;"
                  />
                </div>
                
                <!-- MODIFIED: Favorite Button and Count -->
                <div class="position-absolute top-0 end-0 m-2 d-flex align-items-center bg-light bg-opacity-75 rounded-pill px-2 py-1 shadow-sm">
                  <span class="text-muted small fw-bold me-1">{{ p.like_count }}</span>
                  <button
                    class="btn btn-sm p-0 border-0 bg-transparent"
                    @click="toggleFavorite(p)"> <!-- Pass the whole product object -->
                    <Heart class="favorite-icon" :class="{ favorited: isFavorited(p.product_id) }" />
                  </button>
                </div>
              </div>

              <!-- Card Body -->
              <div class="card-body px-3">
                <span
                  class="badge mb-2 px-3 py-1"
                  :class="{ 'bg-danger': p.is_prescription_required, 'bg-secondary': !p.is_prescription_required }"
                >
                  {{ p.is_prescription_required ? "Prescription" : "OTC" }}
                </span>
                <h5 class="card-title fw-semibold text-truncate" :title="p.name">{{ p.name }}</h5>
                <p class="text-muted small mb-1">{{ p.category }}</p>
                <p class="text-muted small text-truncate-2" :title="p.description">{{ p.description }}</p>
                <div class="mt-2">
                  <strong class="text-primary fs-5">₫{{ p.price.toFixed(2) }}</strong>
                </div>
              </div>

              <!-- Card Footer -->
              <div class="card-footer bg-white border-0 d-flex flex-row gap-2 px-3 pb-3">
                <button class="btn btn-outline-primary w-50" @click="viewDetails(p.product_id)">
                  View Details
                </button>
                <button class="btn btn-primary w-50" @click="handleAddToCart(p)">
                  <ShoppingCart class="me-2" :size="16" /> Add to Cart
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- No Results Message -->
        <div v-if="!loading && filteredProducts.length === 0" class="text-center py-5">
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
import { ShoppingCart, Search, Filter, Heart } from 'lucide-vue-next';
import { showSuccess, showError } from '@/utils/toast';

export default {
  name: 'MedicinesPage',
  components: { Navbar, Footer, ShoppingCart, Search, Filter, Heart },
  data() {
    return {
      loading: true,
      searchTerm: "",
      selectedCategory: "all",
      products: [],
      favorites: [], // Stores the IDs of favorited medicines
    };
  },
  computed: {
    uniqueCategories() {
      const categories = this.products.map(p => p.category);
      return [...new Set(categories)];
    },
    filteredProducts() {
      if (this.loading) {
        return [];
      }
      return this.products.filter(p => {
        const matchesSearch =
          p.name.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
          (p.description && p.description.toLowerCase().includes(this.searchTerm.toLowerCase()));
        const matchesCategory =
          this.selectedCategory === "all" || p.category === this.selectedCategory;
        return matchesSearch && matchesCategory;
      });
    },
  },
  methods: {
    isFavorited(productId) {
      return this.favorites.includes(productId);    //bool
    },
    async toggleFavorite(product) {
      const user = localStorage.getItem("user");
      if (!user) {
        showError("You must be logged in to like items.");
        this.$router.push('/login');
        return;
      }

      const isCurrentlyFavorited = this.isFavorited(product.product_id);
      
      // update the UI for both like status and count
      if (isCurrentlyFavorited) {
        this.favorites = this.favorites.filter(id => id !== product.product_id);
        product.like_count--; // Decrement like count
      } else {
        this.favorites.push(product.product_id);
        product.like_count++; // Increment like count
      }
  
      try {
        if (isCurrentlyFavorited) {
          await api.delete(`/products/${product.product_id}/like`);
          showSuccess("Removed from favorites!");
        } else {
          await api.post(`/products/${product.product_id}/like`);
          showSuccess("Added to favorites!");
        }
      } catch (err) {
        const msg = err.response?.data?.detail || "Failed to update favorite status.";
        showError(msg);
        // Revert the UI change if the API call fails
        if (isCurrentlyFavorited) {
          this.favorites.push(product.product_id);
          product.like_count++; // Revert increment
        } else {
          this.favorites = this.favorites.filter(id => id !== product.product_id);
          product.like_count--; // Revert decrement
        }
      }
    },
    handleAddToCart(product) {
      const user = localStorage.getItem("user");
      if (!user) {
        showError("Please login before purchasing any medicines.");
        this.$router.push(`/login`);
        return;
      }
      const userParse = user ? JSON.parse(user) : null;
      const hasPrescription = userParse?.has_prescription;

      if (product.is_prescription_required && !hasPrescription) {
        showError("You need an approved prescription to buy this medicine.");
        return;
      }
      
      const cartStore = useCartStore();
      cartStore.addToCart(product);
      showSuccess(`${product.name} added to cart!`);
    },
    viewDetails(productId) {
      this.$router.push(`/medicine/${productId}`);
    },
    async fetchProducts() {
      try {
        const res = await api.get("/products");
        this.products = res.data;
      } catch (err) {
        showError("Failed to load products");
      }
    },
    async fetchFavorites() {
      const token = localStorage.getItem("accessToken");
      if (!token) return; // Don't fetch if no user is logged in
      
      try {
        // Corrected API call to the new endpoint
        const res = await api.get('/products/me/likes');
        this.favorites = res.data.map(fav => fav.product_id);
      } catch (err) {
        // Fail silently. If the token is expired, the user just won't see their favorites.
        console.error("Could not fetch favorites:", err);
      }
    }
  },
  async mounted() {
    // Fetch products and favorites at the same time for a faster load.
    this.loading = true;
    await Promise.all([
      this.fetchProducts(),
      this.fetchFavorites()
    ]);
    this.loading = false;
  },
};
</script>

<style scoped>
.card-footer {
    background-color: white;
    border-top: none;
}

.favorite-icon {
    color: #adb5bd; /* Default color for the heart outline */
    transition: color 0.2s ease-in-out, transform 0.2s ease-in-out;
}

.favorite-icon.favorited {
    color: #dc3545; /* Red color when favorited */
    fill: #dc3545; /* Fill the heart when favorited */
}

.btn:hover .favorite-icon {
    transform: scale(1.1);
}
</style>
