<!-- FILE: src/pages/Medicines.vue -->
<!-- -->
<!-- This page displays all available medicines, with search, filter, and favorite functionality. -->

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
          <div v-for="p in filteredProducts" :key="p.product_id" class="col-md-6 col-lg-4 d-flex">
            <div class="card h-100 shadow-sm w-100">
              <div class="card-header">
                <div class="position-relative">
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
                    <!-- My new Favorite button -->
                    <button class="btn btn-light btn-sm position-absolute top-0 end-0 m-2" @click="toggleFavorite(p.product_id)">
                        <Heart class="favorite-icon" :class="{ favorited: isFavorited(p.product_id) }" />
                    </button>
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
      favorites: [], // To store the IDs of favorited medicines
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
          p.description.toLowerCase().includes(this.searchTerm.toLowerCase());
        const matchesCategory =
          this.selectedCategory === "all" || p.category === this.selectedCategory;
        return matchesSearch && matchesCategory;
      });
    },
  },
  methods: {
    isFavorited(productId) {
        // Check if the product ID is in my favorites array
        return this.favorites.includes(productId);
    },
    async toggleFavorite(productId) {
        const user = localStorage.getItem("user");
        if (!user) {
            showError("You must be logged in to favorite items.");
            return;
        }

        const isCurrentlyFavorited = this.isFavorited(productId);
        
        // Optimistically update the UI for a faster user experience
        if (isCurrentlyFavorited) {
            this.favorites = this.favorites.filter(id => id !== productId);
        } else {
            this.favorites.push(productId);
        }

        try {
            // This is where I'd make the real API call to my backend
            // The endpoint would handle adding/removing the favorite for the logged-in user
            await api.post(`/products/${productId}/favorite`);
        } catch (err) {
            showError("Failed to update favorite status.");
            // If the API call fails, revert the change in the UI
            if (isCurrentlyFavorited) {
                this.favorites.push(productId);
            } else {
                this.favorites = this.favorites.filter(id => id !== productId);
            }
        }
    },
    handleAddToCart(product) {
      const user = localStorage.getItem("user");
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
      } finally {
        this.loading = false;
      }
    },
    async fetchFavorites() {
        const user = localStorage.getItem("user");
        if (!user) return; // Don't fetch if no user is logged in
        
        try {
            // My API call to get the list of favorited product IDs for the current user
            const res = await api.get('/favorites');
            this.favorites = res.data.map(fav => fav.product_id); // Assuming the API returns an array of objects
        } catch (err) {
            console.error("Could not fetch favorites.");
            // No need to show an error, the user just won't see their favorites
        }
    }
  },
  mounted() {
    this.fetchProducts();
    this.fetchFavorites();
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
