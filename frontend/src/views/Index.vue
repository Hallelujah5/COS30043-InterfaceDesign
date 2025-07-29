<template>
  <div class="min-h-screen">
    <Navbar />
    <Hero />
    <Categories />
    <FeaturedMedicines />
    <Footer />
  </div>
</template>

<script>
import Navbar from '../components/Navbar.vue';
import Hero from '../components/Hero.vue';
import Categories from '../components/Categories.vue';
import FeaturedMedicines from '../components/FeaturedMedicines.vue';
import Footer from '../components/Footer.vue';

export default {
  name: 'IndexPage',
  
  components: {
    Navbar,
    Hero,
    Categories,
    FeaturedMedicines,
    Footer,
  },
};
</script>
