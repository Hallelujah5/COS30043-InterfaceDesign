<!-- FILE: src/pages/ProductManagement.vue -->
<template>
  <div>
    <Navbar />
    <div class="container py-5">
      <h2 class="mb-4">Product Management</h2>

      <!-- Add Product Form -->
      <div class="card mb-5 shadow-sm">
        <div class="card-header">
          <h5 class="mb-0">
            <PlusCircle class="me-2" />Add New Product
          </h5>
        </div>
        <div class="card-body">
          <form @submit.prevent="handleAddNewProduct">
            <div class="row g-3">
              <div class="col-md-6">
                <label for="name" class="form-label">Product Name</label>
                <input type="text" class="form-control" id="name" v-model="newProduct.name" required>
              </div>
              <div class="col-md-6">
                <label for="manufacturer" class="form-label">Manufacturer</label>
                <input type="text" class="form-control" id="manufacturer" v-model="newProduct.manufacturer">
              </div>
              <div class="col-md-6">
                <label for="price" class="form-label">Price</label>
                <input type="number" step="0.01" class="form-control" id="price" v-model.number="newProduct.price" required>
              </div>
              <div class="col-md-6">
  <label for="category" class="form-label">Category</label>
  <select class="form-select" id="category" v-model="newProduct.category">
    <option disabled value="">Select a category</option>
    <option value="Thuốc giảm đau">Thuốc giảm đau</option>
    <option value="Kháng sinh">Kháng sinh</option>
    <option value="Vitamin">Vitamin</option>
    <option value="Chăm sóc mắt">Chăm sóc mắt</option>
    <option value="Vật tư y tế">Vật tư y tế</option>
    <option value="Thuốc ho">Thuốc ho</option>
    <option value="Thuốc dị ứng">Thuốc dị ứng</option>
    <option value="Thuốc tiêu hóa">Thuốc tiêu hóa</option>
    <option value="Thực phẩm chức năng">Thực phẩm chức năng</option>
  </select>
</div>

              <div class="col-12">
                <label for="description" class="form-label">Description</label>
                <textarea class="form-control" id="description" rows="3" v-model="newProduct.description"></textarea>
              </div>
              
              <!-- This is the file input for the product image -->
              <div class="col-12">
                <label for="image_file" class="form-label">Product Image</label>
                <input type="file" class="form-control" id="image_file" @change="handleFileSelect" accept="image/png, image/jpeg">
              </div>

              <div class="col-12">
                <div class="form-check">
                  <input class="form-check-input" type="checkbox" id="is_prescription_required" v-model="newProduct.is_prescription_required">
                  <label class="form-check-label" for="is_prescription_required">
                    Requires Prescription
                  </label>
                </div>
              </div>
              <div class="col-12">
                <button type="submit" class="btn btn-primary">Add Product</button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Product List Table -->
      <div class="card shadow-sm">
        <div class="card-header"> 
          <h5 class="mb-0">
            <List class="me-2" />Existing Products
          </h5>
        </div>
        <div class="card-body">
          <div class="table-responsive">
            <table class="table table-striped table-hover">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Name</th>
                  <th>Category</th>
                  <th>Price</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="product in products" :key="product.product_id">
                  <td>{{ product.product_id }}</td>
                  <td>{{ product.name }}</td>
                  <td>{{ product.category }}</td>
                  <td>₫{{ product.price.toFixed(2) }}</td>
                  <td>
                    <button class="btn btn-danger btn-sm" @click="handleDeleteProduct(product.product_id)">
                      <Trash2 :size="16" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import api from '@/api';
import Navbar from '@/components/Navbar.vue';
import Footer from '@/components/Footer.vue';
import { showSuccess, showError } from '@/utils/toast';
import { PlusCircle, List, Trash2 } from 'lucide-vue-next';

// Reactive state for the list of products and the new product form
const products = ref([]);
const newProduct = ref({
  name: '',
  manufacturer: '',
  description: '',
  price: 0,
  category: '',
  is_prescription_required: false,
});
// This ref will hold the actual file object selected by the user
const selectedFile = ref(null);

// --- METHODS ---

// Fetches all products to display in the table
const fetchProducts = async () => {
  try {
    const res = await api.get('/products?page=1&size=1000'); // Fetch a large number to show all products
    products.value = res.data.items;
  } catch (err) {
    showError('Failed to load products.');
  }
};

// This method is called when the user selects a file in the input
const handleFileSelect = (event) => {
  // event.target.files is a list of files, we only want the first one
  selectedFile.value = event.target.files[0];
};

// This method handles the form submission
const handleAddNewProduct = async () => {
  // We must use FormData to send files along with other data
  const formData = new FormData();
  
  // Append all the text-based product fields to the FormData object
  formData.append('name', newProduct.value.name);
  formData.append('manufacturer', newProduct.value.manufacturer);
  formData.append('description', newProduct.value.description);
  formData.append('price', newProduct.value.price);
  formData.append('category', newProduct.value.category);
  formData.append('is_prescription_required', newProduct.value.is_prescription_required);

  // IMPORTANT: Append the file object if one has been selected
  if (selectedFile.value) {
    formData.append('file', selectedFile.value);
  }

  try {
    // Send the FormData object to the backend.
    // Axios will automatically set the correct 'Content-Type' header for file uploads.
    await api.post('/products', formData);
    
    showSuccess('Product added successfully!');
    
    // Reset the form fields and the selected file
    newProduct.value = { name: '', manufacturer: '', description: '', price: 0, category: '', is_prescription_required: false };
    selectedFile.value = null;
    document.getElementById('image_file').value = null; // Visually clear the file input
    
    await fetchProducts(); // Refresh the product list to show the new item
  } catch (err) {
    showError(err.response?.data?.detail || 'Failed to add product.');
  }
};

// Handles the deletion of a product
const handleDeleteProduct = async (productId) => {
  if (!confirm('Are you sure you want to delete this product? This action cannot be undone.')) {
    return;
  }
  
  try {
    await api.delete(`/products/${productId}`);
    showSuccess('Product deleted successfully!');
    await fetchProducts(); 
  } catch (err) {
    showError(err.response?.data?.detail || 'Failed to delete product.');
  }
};

// Fetch the initial list of products when the component is first mounted
onMounted( () => {
  const staff = localStorage.getItem('user');
  const staffJSON = staff ? JSON.parse(staff) : null;
  const staffId = staffJSON?.user_id;
  const staffrole = staffJSON?.role;

  if (!staffId) {
    showError('Staff ID is invalid. Please log in again.');this.$router.push('/');
    return;
  }

  if (staffrole !== "BranchManager") {
    showError('Staff role is invalid. Please log in again.');this.$router.push('/');
    return;
  }

  fetchProducts;
});
</script>
