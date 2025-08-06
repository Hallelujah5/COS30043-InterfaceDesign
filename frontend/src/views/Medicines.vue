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
                @input="handleSearch"
              />
            </div>
          </div>
          <div class="col-lg-auto">
            <select class="form-select" v-model="selectedCategory" @change="handleSearch">
              <option value="all">All Categories</option>
              <option v-for="cat in uniqueCategories" :key="cat" :value="cat">
                {{ cat }}
              </option>
            </select>
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
          Showing {{ products.length }} of {{ totalProducts }} medicines
        </p>

        <!-- Products Grid -->
        <div class="row g-4">
          <div v-for="p in filteredProducts" :key="p.product_id" class="col-sm-6 col-lg-4 d-flex">
            <!-- Product Card (same as before) -->
            <div class="card h-100 shadow-sm border-0 rounded-3 w-100">
              <div class="position-relative text-center p-3">
                <div class="bg-white shadow-sm d-inline-flex align-items-center justify-content-center overflow-hidden" :style="{ width: '150px', height: '150px' }">
                  <img :src="p.image_url || '/default-product.png'" :alt="p.name" class="img-fluid" style="max-width: 100%; max-height: 100%; object-fit: contain;"/>
                </div>
                <div class="position-absolute top-0 end-0 m-2 d-flex align-items-center bg-light bg-opacity-75 rounded-pill px-2 py-1 shadow-sm">
                  <span class="text-muted small fw-bold me-1">{{ p.like_count }}</span>
                  <button class="btn btn-sm p-0 border-0 bg-transparent" @click="toggleFavorite(p)">
                    <Heart class="favorite-icon" :class="{ favorited: isFavorited(p.product_id) }" />
                  </button>
                </div>
              </div>
              <div class="card-body px-3">
                <span class="badge mb-2 px-3 py-1" :class="{ 'bg-danger': p.is_prescription_required, 'bg-secondary': !p.is_prescription_required }">
                  {{ p.is_prescription_required ? "Prescription" : "OTC" }}
                </span>
                <h5 class="card-title fw-semibold text-truncate" :title="p.name">{{ p.name }}</h5>
                <p class="text-muted small mb-1">{{ p.category }}</p>
                <p class="text-muted small text-truncate-2" :title="p.description">{{ p.description }}</p>
                <div class="mt-2">
                  <strong class="text-primary fs-5">₫{{ p.price.toFixed(2) }}</strong>
                </div>
              </div>
              <div class="card-footer bg-white border-0 d-flex flex-row gap-2 px-3 pb-3">
                <button class="btn btn-outline-primary w-50" @click="viewDetails(p.product_id)">View Details</button>
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
        
        <!-- NEW: Pagination Controls -->
        <nav v-if="totalPages > 1" aria-label="Page navigation" class="d-flex justify-content-center mt-5">
          <ul class="pagination shadow-sm">
            <li class="page-item" :class="{ disabled: currentPage === 1 }">
              <a class="page-link" href="#" @click.prevent="changePage(currentPage - 1)">Previous</a>
            </li>
            <li class="page-item" :class="{ active: pageNum === currentPage }" v-for="pageNum in totalPages" :key="pageNum">
              <a class="page-link" href="#" @click.prevent="changePage(pageNum)">{{ pageNum }}</a>
            </li>
            <li class="page-item" :class="{ disabled: currentPage === totalPages }">
              <a class="page-link" href="#" @click.prevent="changePage(currentPage + 1)">Next</a>
            </li>
          </ul>
        </nav>
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
import { useRouter } from 'vue-router';

const router = useRouter();

export default {
  name: 'MedicinesPage',
  components: { Navbar, Footer, ShoppingCart, Search, Filter, Heart },
  data() {
    return {
      loading: true,
      searchTerm: "",
      selectedCategory: "all",
      allProducts: [], // Holds all products for filtering, not just the current page
      products: [], // Holds the products for the CURRENT page
      favorites: [],
      // NEW: Pagination state
      currentPage: 1,
      totalPages: 0,
      totalProducts: 0,
      pageSize: 9,
    };
  },
  computed: {
    uniqueCategories() {
      // Create categories from all products, not just the current page
      const categories = this.allProducts.map(p => p.category);
      return [...new Set(categories)];
    },
    filteredProducts() {
      // This computed property now filters the `products` array (the current page)
      if (this.loading) return [];
      
      // The backend will handle filtering in a real-world scenario.
      // For now, we filter the client-side data for simplicity.
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
    async fetchProducts(page = 1) {
      this.loading = true;
      try {
        const res = await api.get("/products", {
          params: {
            page: page,
            size: this.pageSize
          }
        });
        this.products = res.data.items;
        this.currentPage = res.data.current_page;
        this.totalPages = res.data.total_pages;
        this.totalProducts = res.data.total_items;
        
        // For client-side filtering demo, we'll also fetch all products once
        // In a real app, the backend would handle filtering via API params
        if (this.allProducts.length === 0) {
            const allRes = await api.get("/products", { params: { page: 1, size: 1000 } }); // Fetch all for categories
            this.allProducts = allRes.data.items;
        }

      } catch (err) {
        showError("Failed to load products");
      } finally {
        this.loading = false;
      }
    },
    changePage(page) {
      if (page > 0 && page <= this.totalPages) {
        this.fetchProducts(page);
      }
    },
    handleSearch() {
        this.changePage(1);
    },
    isFavorited(productId) {
      return this.favorites.includes(productId);
    },
    async toggleFavorite(product) {
      // This logic remains the same
      const user = localStorage.getItem("user");
      if (!user) {
        showError("You must be logged in to like items.");
        this.$router.push('/login');
        return;
      }
      const isCurrentlyFavorited = this.isFavorited(product.product_id);
      if (isCurrentlyFavorited) {
        this.favorites = this.favorites.filter(id => id !== product.product_id);
        product.like_count--;
      } else {
        this.favorites.push(product.product_id);
        product.like_count++;
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
        showError(err.response?.data?.detail || "Failed to update favorite status.");
        if (isCurrentlyFavorited) {
          this.favorites.push(product.product_id);
          product.like_count++;
        } else {
          this.favorites = this.favorites.filter(id => id !== product.product_id);
          product.like_count--;
        }
      }
    },
    handleAddToCart(product) {
      // This logic remains the same
      const user = localStorage.getItem("user");
      if (!user) { showError("Please login before purchasing."); this.$router.push(`/login`); return; };
      const userParse = user ? JSON.parse(user) : null;
      if (product.is_prescription_required && !userParse?.has_prescription) {
        showError("You need an approved prescription to buy this medicine.");
        return;
      }
      useCartStore().addToCart(product);
      showSuccess(`${product.name} added to cart!`);
    },
    viewDetails(productId) {
      this.$router.push(`/medicine/${productId}`);
    },
    async fetchFavorites() {
      // This logic remains the same
      try {
        const res = await api.get('/products/me/likes');
        this.favorites = res.data.map(fav => fav.product_id);
      } catch (err) {
        console.error("Could not fetch favorites:", err);
      }
    }
  },
  async mounted() {
    await Promise.all([
      this.fetchProducts(this.currentPage),
      // this.fetchFavorites()
    ]);
  },
};
</script>

<style scoped>
.card-footer {
    background-color: white;
    border-top: none;
}
.favorite-icon {
    color: #adb5bd;
    transition: color 0.2s ease-in-out, transform 0.2s ease-in-out;
}
.favorite-icon.favorited {
    color: #dc3545;
    fill: #dc3545;
}
.btn:hover .favorite-icon {
    transform: scale(1.1);
}
.page-item.disabled .page-link {
    cursor: not-allowed;
    opacity: 0.7;
}
</style>
