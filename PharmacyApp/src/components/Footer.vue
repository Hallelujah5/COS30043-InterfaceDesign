<!-- FILE: src/components/Footer.vue -->
<!-- -->
<!-- The main footer for the application, consistent across all pages. -->

<template>
  <footer class="bg-dark text-light py-5">
    <div class="container">
      <div class="row gy-4">
        <!-- Company Info -->
        <div class="col-md-3">
          <div class="d-flex align-items-center mb-3">
            <!-- Image path assumes 'Longchau.png' is in the 'public' directory -->
            <img src="/Longchau.png" alt="Longchau Pharmacy Logo" width="200"/>
          </div>
          <p class="text-secondary small">
            Your trusted pharmaceutical marketplace connecting patients with licensed pharmacies worldwide.
          </p>
          <div class="d-flex gap-3">
            <a href="#" class="text-secondary" aria-label="Facebook">📘</a>
            <a href="#" class="text-secondary" aria-label="Twitter">🐦</a>
            <a href="#" class="text-secondary" aria-label="Instagram">📷</a>
          </div>
        </div>

        <!-- Quick Links -->
        <div class="col-md-3">
          <h6 class="fw-semibold mb-3">Quick Links</h6>
          <ul class="list-unstyled small">
            <li><router-link to="/medicines" class="text-secondary text-decoration-none">Browse Medicines</router-link></li>
            <li><router-link to="/prescriptions" class="text-secondary text-decoration-none">Upload Prescription</router-link></li>
            <li><router-link to="/sell" class="text-secondary text-decoration-none">Become a Seller</router-link></li>
            <li><router-link to="/about" class="text-secondary text-decoration-none">About Us</router-link></li>
          </ul>
        </div>

        <!-- Customer Service -->
        <div class="col-md-3">
          <h6 class="fw-semibold mb-3">Customer Service</h6>
          <ul class="list-unstyled small">
            <li><a href="#" class="text-secondary text-decoration-none">Help Center</a></li>
            <li><a href="#" class="text-secondary text-decoration-none">Contact Us</a></li>
            <li><a href="#" class="text-secondary text-decoration-none">Return Policy</a></li>
            <li><a href="#" class="text-secondary text-decoration-none">Privacy Policy</a></li>
          </ul>
        </div>

        <!-- Contact Info -->
        <div class="col-md-3">
          <h6 class="fw-semibold mb-3">Contact</h6>
          <ul class="list-unstyled small text-secondary">
            <li>📞 1-800-LONGCHAU-1</li>
            <li>✉️ support@longchau.com</li>
            <li>� 24/7 Customer Support</li>
            <li>🏥 Licensed & Verified</li>
          </ul>
        </div>
      </div>

      <hr class="border-secondary my-4" />
      <div class="text-center text-secondary small">
        &copy; 2024 FPT Long Chau. All rights reserved. Licensed Healthcare Marketplace.
      </div>
    </div>
  </footer>
</template>

<script>
import { RouterLink } from 'vue-router';

export default {
  name: 'Footer',
  components: {
    RouterLink,
  },
};
</script>

<style scoped>
/* Scoped styles for the footer can be added here. */
</style>
�