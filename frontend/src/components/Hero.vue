<template>
  <div class="bg-light py-5 custom-gradient">
    <div class="container">
      <div class="row align-items-center gy-5">
        <!-- Left Side: Marketing text and main call-to-action buttons -->
        <div class="col-lg-6">
          <h1 class="display-4 fw-bold text-dark">
            Your Trusted <span class="text-primary">Pharmaceutical</span> Marketplace
          </h1>
          <p class="lead text-secondary mt-4">
            Buy and sell medicines safely with verified prescriptions. Connect with licensed pharmacies and healthcare providers in your area.
          </p>

          <div class="d-flex flex-column flex-sm-row gap-3 mt-4">
            <router-link to="/medicines" class="btn btn-primary btn-lg d-flex align-items-center">
              <ShoppingCart class="me-2" />
              Browse Medicines
            </router-link>
            <router-link to="/login" class="btn btn-outline-primary btn-lg d-flex align-items-center">
              <User class="me-2" />
              Become a member
            </router-link>
          </div>

          <div class="d-flex justify-content-start mt-5 gap-5">
            <div class="text-center">
              <div class="fs-3 fw-bold text-primary">10k+</div>
              <div class="text-muted">Medicines Available</div>
            </div>
            <div class="text-center">
              <div class="fs-3 fw-bold text-success">500+</div>
              <div class="text-muted">Verified Sellers</div>
            </div>
            <div class="text-center">
              <div class="fs-3 fw-bold text-purple">24/7</div>
              <div class="text-muted">Support</div>
            </div>
          </div>
        </div>

        <!-- Right Side: Quick action links card -->
        <div class="col-lg-6">
          <div class="card shadow-lg">
            <div class="card-body">
              <h5 class="card-title mb-4">Quick Actions</h5>

              <div class="d-grid gap-3">
                <router-link to="/prescriptions" class="text-decoration-none">
                  <div class="d-flex align-items-center p-3 bg-primary bg-opacity-10 rounded">
                    <Upload class="text-primary me-3" />
                    <div>
                      <div class="fw-medium text-dark">Upload Prescription</div>
                      <div class="small text-muted">Get medicines delivered to your door</div>
                    </div>
                  </div>
                </router-link>

                <router-link to="/medicines" class="text-decoration-none">
                  <div class="d-flex align-items-center p-3 bg-success bg-opacity-10 rounded">
                    <ShoppingCart class="text-success me-3" />
                    <div>
                      <div class="fw-medium text-dark">Order Now</div>
                      <div class="small text-muted">Browse our extensive medicine catalog</div>
                    </div>
                  </div>
                </router-link>

                <router-link to="/login" class="text-decoration-none">
                  <div class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded">
                    <User class="text-secondary me-3" />
                    <div>
                      <div class="fw-medium text-dark">Join Community</div>
                      <div class="small text-muted">Connect with healthcare professionals</div>
                    </div>
                  </div>
                </router-link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
// Import components needed for the template
import { RouterLink } from 'vue-router';
import { ShoppingCart, Upload, User } from 'lucide-vue-next';

export default {
  name: 'Hero',
  // Register the imported components
  components: {
    RouterLink,
    ShoppingCart,
    Upload,
    User,
  },
};
</script>

<style scoped>
/* Scoped styles for this component. */
/* Added custom classes that are not part of standard Bootstrap. */
.custom-gradient {
  background: linear-gradient(to bottom, #f8f9fa, #ffffff);
}
.text-purple {
  color: #6f42c1; /* A standard purple color */
}
</style>
