
<template>
  <div class="min-h-screen d-flex align-items-center justify-content-center bg-light">
    <div class="text-center">
      <h1 class="display-1 fw-bold">404</h1>
      <p class="fs-3"> <span class="text-danger">Opps!</span> Page not found.</p>
      <p class="lead">
        The page you’re looking for doesn’t exist.
      </p>
      <router-link to="/" class="btn btn-primary">Go Home</router-link>
    </div>
  </div>
</template>

<script>
export default {
  name: 'NotFoundPage',
  created() {
    console.error(
      '404 Error: User attempted to access non-existent route:',
      this.$route.fullPath
    );
  },
};
</script>

<style scoped>
.min-h-screen {
  min-height: 100vh;
}
</style>