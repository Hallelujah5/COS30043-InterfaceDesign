<template>
  <div>
    <Navbar />
    <div class="container py-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h2>Task Delegation</h2>
          <h4 v-if="branchName">Branch: {{ branchName }}</h4>
        </div>
      </div>
      <div class="row">
        <div class="col-md-6 mb-4">
          <div class="card">
            <div class="card-header">Prescription Assignments</div>
            <div class="card-body">
              <div v-for="p in prescriptions" :key="p.prescription_id" class="mb-3 border p-3 rounded">
                <h5>Customer's ID: {{ p.customer_id }}</h5>
                <p class="text-muted small"><b>Notes:</b> {{ p.notes }}</p>
                <div class="mt-2">
                  <p v-if="p.assigned_pharmacist_id" class="text-success">
                    Assigned to: {{ getAssignedName(p.assigned_pharmacist_id, pharmacists) }}
                  </p>
                  <select v-else class="form-select" @change="assignPrescription(p.prescription_id, parseInt($event.target.value))" defaultValue="">
                    <option value="" disabled selected>Assign to pharmacist</option>
                    <option v-for="ph in pharmacists" :key="ph.staff_id" :value="ph.staff_id">
                      {{ ph.first_name }} {{ ph.last_name }}
                    </option>
                  </select>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-md-6 mb-4">
          <div class="card">
            <div class="card-header">Order Assignments</div>
            <div class="card-body">
              <div v-for="o in pendingOrders" :key="o.order_id" class="mb-3 border p-3 rounded">
                <h5>Customer ID: {{ o.customer_id }}</h5>
                <p><strong>₫{{ o.total_amount }}</strong></p>
                <p class="text-muted small">Ordered: {{ new Date(o.order_date).toLocaleString() }}</p>
                <div class="mt-2">
                  <p v-if="o.cashier_id" class="text-success">
                    Assigned to: {{ getAssignedName(o.cashier_id, cashiers) }}
                  </p>
                  <select v-else class="form-select" @change="assignOrder(o.order_id, parseInt($event.target.value))" defaultValue="">
                    <option value="" disabled selected>Assign to cashier</option>
                    <option v-for="c in cashiers" :key="c.staff_id" :value="c.staff_id">
                      {{ c.first_name }} {{ c.last_name }}
                    </option>
                  </select>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import { showSuccess, showError } from '@/utils/toast';
import Navbar from '@/components/Navbar.vue';
import Footer from '@/components/Footer.vue';
import { UserCheck, ArrowRight } from 'lucide-vue-next';
import api from '@/api';

const router = useRouter();

const prescriptions = ref([]);
const pendingOrders = ref([]);
const pharmacists = ref([]);
const cashiers = ref([]);
const branchName = ref('');

const user = JSON.parse(localStorage.getItem('user') || '{}');
const isBranchManager = computed(() => user.role === 'BranchManager');

const assignPrescription = async (prescriptionId, pharmacistId) => {
  try {
    await api.put(`/prescriptions/${prescriptionId}/assign-pharmacist`, { pharmacist_id: pharmacistId });
    prescriptions.value = prescriptions.value.filter(p => p.prescription_id !== prescriptionId);
    const pharmacist = pharmacists.value.find(p => p.staff_id === pharmacistId);
    showSuccess(`Prescription assigned to ${pharmacist?.first_name} ${pharmacist?.last_name}`);
  } catch (err) {
    showError('Failed to assign prescription. Please try again.');
  }
};

const assignOrder = async (orderId, cashierId) => {
  try {
    await api.put(`/staff/assign-order-to-cashier`, {
      order_id: orderId,
      cashier_id: cashierId,
      branch_manager_id: user?.id,
    });
    const order = pendingOrders.value.find(o => o.order_id === orderId);
    if(order) order.cashier_id = cashierId;
    
    const cashier = cashiers.value.find(c => c.staff_id === cashierId);
    showSuccess(`Order assigned to ${cashier?.first_name} ${cashier?.last_name}`);
  } catch (err) {
    showError('Error assigning order.');
  }
};

const getAssignedName = (staffId, list) => {
  return list.find(s => s.staff_id === staffId)?.last_name || '';
};

const goToManagerDashboard = () => {
  this.$router.push('/manager-dashboard');
};

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
    showError('403 Forbidden');this.$router.push('/');
    return;
  }



  const storedBranchId = localStorage.getItem('branch_id');
  if (storedBranchId) {
    try {
      // Fetch branch and staff info concurrently
      const [branchRes, staffRes] = await Promise.all([
        api.get(`/branches/${storedBranchId}`),
        api.get(`/staff/branches/${storedBranchId}/staff`)
      ]);
      
      branchName.value = branchRes.data.name;
      pharmacists.value = staffRes.data.filter(s => s.role === 'Pharmacist');
      cashiers.value = staffRes.data.filter(s => s.role === 'Cashier');

      // Fetch pending tasks concurrently
      const [presRes, orderRes] = await Promise.all([
        api.get('/prescriptions/pending-pharmacist-review'),
        api.get('/orders/pending-processing'),
      ]);
      
      prescriptions.value = presRes.data.prescriptions;
      pendingOrders.value = orderRes.data;

    } catch (err) {
      showError('Failed to load initial data for delegation.');
    }
  }
});
</script>