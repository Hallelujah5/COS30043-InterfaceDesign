<!-- FILE: src/components/FeaturedMedicines.vue -->
<!-- -->
<!-- This component displays a grid of featured medicines on the home page. -->

<template>
  <section class="py-5 bg-white">
    <div class="container">
      <div class="text-center mb-5">
        <h2 class="h3 fw-bold">Featured Medicines</h2>
        <p class="text-muted">
          Discover our most popular and trusted medications
        </p>
      </div>

      <!-- The v-for directive is used to loop through the medicines array -->
      <div class="row g-4">
        <div v-for="medicine in medicines" :key="medicine.product_id" class="col-12 col-md-6 col-lg-3 d-flex">
          <!-- Using standard Bootstrap card classes instead of a custom Card component -->
          <div class="card h-100 shadow-sm w-100">
            <div class="card-header pb-0">
              <div class="d-flex justify-content-center mb-3">
                <div
                  class="bg-light rounded-circle d-flex align-items-center justify-content-center"
                  :style="{ width: '150px', height: '150px' }"
                >
                  <img
                    :src="medicine.image_url"
                    :alt="medicine.name"
                    :style="{ width: '100%', height: '100%', objectFit: 'contain' }"
                  />
                </div>
              </div>

              <div class="d-flex justify-content-between align-items-center mb-2">
                <!-- Vue's :class binding is used for conditional classes -->
                <span
                  class="badge"
                  :class="{ 'bg-danger': medicine.prescription, 'bg-secondary': !medicine.prescription }"
                >
                  {{ medicine.prescription ? "Prescription" : "OTC" }}
                </span>
                <small class="text-warning">
                  ★
                  <span class="text-muted ms-1">{{ medicine.rating }}</span>
                </small>
              </div>

              <h5 class="card-title">{{ medicine.name }}</h5>
              <p class="text-muted">{{ medicine.category }}</p>
            </div>

            <div class="card-body">
              <div class="d-flex align-items-center mb-2">
                <span class="fw-bold text-primary">
                  ₫{{ medicine.price.toFixed(2) }}
                </span>
                <span class="text-muted text-decoration-line-through ms-2">
                  ₫{{ medicine.originalPrice }}
                </span>
              </div>
              <p
                class="small"
                :class="{ 'text-success': medicine.inStock, 'text-danger': !medicine.inStock }"
              >
                {{ medicine.inStock ? "In Stock" : "Out of Stock" }}
              </p>
            </div>

            <div class="card-footer d-flex justify-content-between">
              <!-- @click is Vue's equivalent of onClick -->
              <button
                class="btn btn-outline-primary flex-grow-1 me-2"
                @click="viewDetails(medicine.product_id)"
              >
                View details
              </button>
              <button
                class="btn btn-primary flex-grow-1"
                :disabled="!medicine.inStock"
                @click="handleAddToCart(medicine)"
              >
                🛒 Add to Cart
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="text-center mt-5 pt-4">
        <router-link to="/medicines" class="btn btn-outline-primary px-4">
          View All Medicines
        </router-link>
      </div>
    </div>
  </section>
</template>

<script>
import { useCartStore } from '@/stores/cart';
// Importing my toast utility functions
import { showSuccess, showError } from '@/utils/toast';

export default {
  name: 'FeaturedMedicines',
  data() {
    return {
      medicines: [
        {
          product_id: 1,
          name: "Paracetamol 500mg",
          category: "Pain Relief",
          price: 16500.0,
          originalPrice: 20000,
          rating: 4.5,
          inStock: true,
          prescription: false,
          image_url: "/src/assets/Paracetamol.jpg",
        },
        {
          product_id: 2,
          name: "Amoxicillin 250mg",
          category: "Antibiotic",
          price: 30000.0,
          originalPrice: 35000,
          rating: 4.8,
          inStock: true,
          prescription: true,
          image_url: "/src/assets/amoxi.jpg",
        },
        {
          product_id: 3,
          name: "Vitamin C 1000mg",
          category: "Supplements",
          price: 80000,
          originalPrice: 87000,
          rating: 4.6,
          inStock: true,
          prescription: false,
          image_url: "/src/assets/vitaminC.jpg",
        },
        {
          product_id: 6,
          name: "Siro ho Astex",
          category: "Pain Relief",
          price: 65000.0,
          originalPrice: 75000,
          rating: 4.4,
          inStock: true,
          prescription: false,
          image_url: "/src/assets/siro.jpg",
        },
      ],
    };
  },
  methods: {
    handleAddToCart(medicine) {
      if (!medicine.inStock) return;
      const hasPrescription = localStorage.getItem("has_prescription") === "true";
      if (medicine.prescription && !hasPrescription) {
        showError("You need an approved prescription to buy this medicine.");
        return;
      }

      const cartStore = useCartStore();
      cartStore.addToCart(medicine);

      showSuccess(`${medicine.name} added to cart!`);
    },
    viewDetails(productId) {
      this.$router.push(`/medicine/${productId}`);
    },
  },
};
</script>

<style scoped>
/* Scoped styles for this component */
.card-footer {
  background-color: white;
  border-top: none;
}
</style>
