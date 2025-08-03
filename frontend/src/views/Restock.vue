<!-- FILE: src/pages/Restock.vue -->
<template>
  <div>
    <Navbar />
    <div class="container py-4">
      <h3 class="mb-4">📦 Product Stock Management</h3>

      <!-- Branch Selector -->
      <div class="mb-3">
        <label class="form-label">
          <strong>Select Branch</strong>
        </label>
        <select
          class="form-select"
          v-model="branchId"
          @change="handleBranchChange"
          required
        >
          <option value="" disabled>-- Choose Branch --</option>
          <option v-for="branch in branches" :key="branch.branch_id" :value="branch.branch_id">
            {{ branch.name }}
          </option>
        </select>
      </div>

      <!-- Forms Row -->
      <div class="row mb-4">
        <!-- Restock Form -->
        <div class="col-md-6 mb-3">
          <form
            class="border rounded p-3 bg-light h-100"
            @submit.prevent="handleRestock"
          >
            <h5>
              <ArchiveRestore :size="24" class="me-2" />
              Restock Product
            </h5>
            <div class="mb-2">
              <label class="form-label">Select Product</label>
              <select
                class="form-select"
                v-model="selectedProductId"
                required
              >
                <option value="" disabled>-- Choose Product --</option>
                <option v-for="p in sortedBranchProducts" :key="p.id" :value="p.id">
                  #{{ p.id }} - {{ p.name }}
                </option>
              </select>
            </div>
            <div class="mb-2">
              <label class="form-label">Quantity to Add</label>
              <input
                type="number"
                class="form-control"
                v-model="quantityToAdd"
                required
              />
            </div>
            <button type="submit" class="btn btn-primary">Restock</button>
          </form>
        </div>

        <!-- Update Min Stock Level Form -->
        <div class="col-md-6 mb-3">
          <form
            class="border rounded p-3 bg-light h-100"
            @submit.prevent="handleUpdateMinStock"
          >
            <h5>
              <SquarePen :size="24" class="me-2" />
              Update Min Stock Level
            </h5>
            <div class="mb-2">
              <label class="form-label">Select Product</label>
              <select
                class="form-select"
                v-model="minStockProductId"
                required
              >
                <option value="" disabled>-- Choose Product --</option>
                <option v-for="p in sortedBranchProducts" :key="p.id" :value="p.id">
                  #{{ p.id }} - {{ p.name }}
                </option>
              </select>
            </div>
            <div class="mb-2">
              <label class="form-label">New Min Stock Level</label>
              <input
                type="number"
                class="form-control"
                v-model="minStockValue"
                required
              />
            </div>
            <button type="submit" class="btn btn-primary">Update Min Stock</button>
          </form>
        </div>
      </div>

      <!-- Stock Table -->
      <div class="border rounded p-3 bg-light mb-4">
        <h5 class="mb-3">
          <ChartCandlestick :size="24" class="me-2" /> Current Product Stock Status
        </h5>
        <div v-if="stockStatus.length === 0" class="text-muted">
          No product stock data available for this branch.
        </div>
        <div v-else class="table-responsive">
          <table class="table table-striped table-bordered table-sm">
            <thead class="table-secondary">
              <tr>
                <th>Product ID</th>
                <th>Product Name</th>
                <th>Category</th>
                <th>Stock Quantity</th>
                <th>Minimum Stock</th>
                <th>Status Alert</th>
                <th>Last Updated</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in sortedStockStatus" :key="item.product_id" :class="{ 'table-warning': item.stock_quantity < item.min_stock_level }">
                <td>{{ item.product_id }}</td>
                <td>{{ item.product_name }}</td>
                <td>{{ item.category }}</td>
                <td>{{ item.stock_quantity }}</td>
                <td>{{ item.min_stock_level }}</td>
                <td>
                  <span :class="item.stock_quantity < item.min_stock_level ? 'text-danger fw-bold' : 'text-success fw-bold'">
                    {{ item.stock_status_alert }}
                  </span>
                </td>
                <td>{{ new Date(item.last_updated).toLocaleString() }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup>
import { ref, onMounted, watch, computed } from 'vue';
import api from '@/api';
import { ArchiveRestore, ChartCandlestick, SquarePen } from 'lucide-vue-next';
import Navbar from '@/components/Navbar.vue';
import Footer from '@/components/Footer.vue';
import { showSuccess, showError } from '@/utils/toast';

// State Management
const branches = ref([]);
const branchId = ref(localStorage.getItem("branch_id") || "");
const stockStatus = ref([]);
const branchProducts = ref([]);
const selectedProductId = ref("");
const quantityToAdd = ref("");
const minStockProductId = ref("");
const minStockValue = ref("");

// Computed properties for sorting
const sortedBranchProducts = computed(() => {
  return [...branchProducts.value].sort((a, b) => a.id - b.id);
});

const sortedStockStatus = computed(() => {
  return [...stockStatus.value].sort((a, b) => {
    const aLow = a.stock_quantity < a.min_stock_level;
    const bLow = b.stock_quantity < b.min_stock_level;
    if (aLow && !bLow) return -1;
    if (!aLow && bLow) return 1;
    return a.product_id - b.product_id;
  });
});

// Methods
const fetchStockStatus = async () => {
  if (!branchId.value) return;
  try {
    const res = await api.get(`/product_stock/branches/${branchId.value}`);
    stockStatus.value = res.data;
    branchProducts.value = res.data.map((p) => ({ id: p.product_id, name: p.product_name }));
  } catch (err) {
    console.error("Failed to load stock status", err);
    stockStatus.value = [];
  }
};

const handleBranchChange = () => {
  localStorage.setItem("branch_id", branchId.value);
  // The 'watch' function below will automatically trigger fetchStockStatus
};

const handleRestock = async () => {
  try {
    const payload = {
      branch_id: parseInt(branchId.value),
      product_id: parseInt(selectedProductId.value),
      quantity_to_add: parseInt(quantityToAdd.value),
    };
    await api.post("/product_stock/restock", payload);
    showSuccess("Product restocked successfully.");
    selectedProductId.value = "";
    quantityToAdd.value = "";
    await fetchStockStatus(); // Refresh data
  } catch (err) {
    console.error("Failed to restock product:", err);
    showError("Failed to restock! Please check if the product is available in your specified branch and try again.");
  }
};

const handleUpdateMinStock = async () => {
  try {
    const payload = {
      branch_id: parseInt(branchId.value),
      product_id: parseInt(minStockProductId.value),
      min_stock_level: parseInt(minStockValue.value),
    };
    await api.put("/product_stock/update-min-stock-level", payload);
    showSuccess("Min stock level updated successfully.");
    minStockProductId.value = "";
    minStockValue.value = "";
    await fetchStockStatus(); // Refresh data
  } catch (err) {
    console.error("Failed to update min stock level:", err);
    showError("Failed to update! Please ensure your product and branch are selected correctly.");
  }
};

// Lifecycle Hooks
onMounted(async () => {

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



  try {
    const res = await api.get("/branches");
    branches.value = res.data;
  } catch (err) {
    console.error("Failed to load branches", err);
  }
  // Fetch initial stock status if a branch is already selected
  if (branchId.value) {
    await fetchStockStatus();
  }
});

// Watch for changes in branchId to fetch new data
watch(branchId, fetchStockStatus);
</script>
