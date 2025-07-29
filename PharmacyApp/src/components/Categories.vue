<!-- FILE: src/components/Categories.vue -->
<!-- -->
<!-- This component displays a grid of product categories on the home page. -->

<template>
  <section class="py-5 bg-light">
    <div class="container">
      <div class="text-center mb-5">
        <h2 class="h3 fw-bold text-dark mb-3">Shop by Category</h2>
        <p class="text-muted fs-5">Find the right medication for your needs</p>
      </div>

      <div class="row g-4">
        <!-- Loop through the categories array using v-for -->
        <div v-for="(category, index) in categories" :key="index" class="col-6 col-md-4 col-lg-2">
          <!-- Bind the dynamic color class using :class -->
          <div class="card text-center border-0 p-3" :class="category.color">
            <div class="card-body">
              <div class="fs-2 mb-2">{{ category.icon }}</div>
              <h6 class="fw-semibold text-dark mb-1">{{ category.name }}</h6>
              <p class="text-muted small mb-0">{{ category.count }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: 'Categories',
  data() {
    // The component's local data
    return {
      categories: [
        {
          name: "Pain Relief",
          icon: "🩹",
          count: "1,200+ items",
          color: "bg-danger-subtle"
        },
        {
          name: "Antibiotics",
          icon: "💊",
          count: "800+ items",
          color: "bg-primary-subtle"
        },
        {
          name: "Vitamins",
          icon: "🌿",
          count: "200+ items",
          color: "bg-success-subtle"
        },
        {
          name: "Heart & Blood",
          icon: "❤️",
          count: "600+ items",
          color: "bg-pink" // Custom class
        },
        {
          name: "Digestive Health",
          icon: "🫁",
          count: "900+ items",
          color: "bg-warning-subtle"
        },
        {
          name: "Skin Care",
          icon: "✨",
          count: "1,500+ items",
          color: "bg-purple" // Custom class
        }
      ]
    };
  }
};
</script>

<style scoped>
/* Define custom background colors that are not in Bootstrap */
.bg-pink {
  background-color: #f8d7da; /* A light pink color */
}
.bg-purple {
  background-color: #e0cffc; /* A light purple color */
}
.card-body {
  /* Overriding Bootstrap's default card-body padding to match the original design */
  padding: 0;
}
</style>
