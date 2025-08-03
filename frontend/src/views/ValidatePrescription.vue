<template>
  <div class="bg-light min-vh-100 d-flex flex-column">
    <Navbar />
    <main class="container py-5 flex-grow-1">
      <div class="mb-4">
        <h1 class="h3">Prescription Validation</h1>
        <p class="text-muted">Review and validate customer prescriptions</p>
      </div>

      <div class="row mb-4 g-3">
        <div class="col-md-8">
          <label for="search" class="form-label">Search Prescriptions</label>
          <div class="input-group">
            <span class="input-group-text"><Search size="16" /></span>
            <input
              type="text"
              id="search"
              class="form-control"
              placeholder="Search by patient or medication..."
              v-model="searchTerm"
            />
          </div>
        </div>
        <div class="col-md-4">
          <label for="status" class="form-label">Filter by Status</label>
          <select id="status" class="form-select" v-model="selectedStatus">
            <option value="all">All Status</option>
            <option value="Pending">Pending</option>
            <option value="Approved">Approved</option>
            <option value="Rejected">Rejected</option>
          </select>
        </div>
      </div>

      <div v-if="filteredPrescriptions.length > 0">
        <div v-for="p in filteredPrescriptions" :key="p.prescription_id" class="card mb-4 shadow-sm">
          <div class="card-header d-flex justify-content-between align-items-center">
            <div class="d-flex align-items-center gap-3">
              <FileText size="20" class="text-primary" />
              <div>
                <h5 class="mb-0">Prescription #{{ p.prescription_id }}</h5>
                <small class="text-muted">Uploaded on {{ new Date(p.upload_date).toLocaleDateString() }}</small>
              </div>
            </div>
            <span :class="['badge', getStatusClass(p.validation_status)]" v-html="getStatusIcon(p.validation_status)"></span>
          </div>
          <div class="card-body">
            <div class="row mb-3">
              <div class="col-md-6">
                <h6 class="text-muted">Patient Information:</h6>
                <p class="mb-1"><strong>Name:</strong> {{ p.customer_first_name }} {{ p.customer_last_name }}</p>
                <p class="mb-1"><strong>Customer ID:</strong> {{ p.customer_id }}</p>
              </div>
              <div class="col-md-6">
                <h6 class="text-muted">Prescription Image:</h6>
                <img :src="p.file_path" alt="Prescription Image" style="width: 90%; height: 90%; object-fit: contain;" />
              </div>
            </div>

            <div v-if="p.customer_notes" class="mb-3">
              <h6 class="text-muted">Customer Notes</h6>
              <p class="bg-light border p-2 rounded">{{ p.customer_notes }}</p>
            </div>
            
            <div v-if="p.validation_status.toLowerCase() === 'pending'" class="d-flex gap-2">
              <button class="btn btn-success" @click="handleStatusChange(p.prescription_id, 'Approved')">
                <CheckCircle size="16" class="me-2" /> Approve
              </button>
              <button class="btn btn-danger" @click="handleStatusChange(p.prescription_id, 'Rejected')">
                <XCircle size="16" class="me-2" /> Reject
              </button>
            </div>
          </div>
        </div>
      </div>
      <div v-else class="text-center py-5">
        <FileText size="48" class="text-muted mb-3" />
        <h5>No prescriptions found</h5>
        <p class="text-muted">Try adjusting your search or filters.</p>
      </div>
    </main>
    <Footer />
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { CheckCircle, XCircle, Clock, Search, FileText } from 'lucide-vue-next';
import Navbar from '@/components/Navbar.vue';
import Footer from '@/components/Footer.vue';
import { showSuccess, showInfo, showError } from '@/utils/toast';
import api from '@/api';

const prescriptions = ref([]);
const searchTerm = ref('');
const selectedStatus = ref('all');

onMounted(async () => {
  const staff = localStorage.getItem('user');
  const staffJSON = staff ? JSON.parse(staff) : null;
  const staffId = staffJSON?.user_id;
  const staffrole = staffJSON?.role;

  if (!staffId) {
    showError('Staff ID is invalid. Please log in again.');
    return;
  }

  if (staffrole !== "Pharmacist") {
    showError('Staff role is invalid. Please log in again.');
    return;
  }
  try {
    const res = await api.get(`/prescriptions/pharmacist/${staffId}/pending-review`);
    prescriptions.value = res.data.prescriptions;
  } catch (error) {
    showError('Failed to fetch prescriptions.');
  }
});

const handleStatusChange = async (id, newStatus) => {
    const staff = localStorage.getItem('user');
  const staffJSON = staff ? JSON.parse(staff) : null;
  const staffId = staffJSON?.user_id;
  try {
    console.log(id, newStatus, staffId);
    await api.put(`/prescriptions/${id}/validate`, {
      pharmacist_id: staffId,
      validation_status: newStatus,
      note: '',
    });
    

    const prescription = prescriptions.value.find(p => p.prescription_id === id);
    if (prescription) {
      prescription.validation_status = newStatus;
    }

    showSuccess(`Prescription ${newStatus.toLowerCase()} successfully.`);
  } catch (error) {
    showError('Something went wrong while updating status.');
  }
};

const filteredPrescriptions = computed(() => {
  return prescriptions.value.filter(p => {
    const matchesStatus = selectedStatus.value === 'all' || p.validation_status === selectedStatus.value;
    return matchesStatus;
  });
});

const getStatusClass = (status) => {
  switch (status) {
    case 'Pending': return 'bg-warning text-dark';
    case 'Approved': return 'bg-success';
    case 'Rejected': return 'bg-danger';
    default: return 'bg-secondary';
  }
};

const getStatusIcon = (status) => {
  // Using v-html for simplicity to inject icon markup. Be cautious with this if data isn't trusted.
  // In a real app, you might use dynamic components instead.
  switch (status) {
    case 'Pending': return `<i class="lucide-icon"><svg...></svg></i> Pending`; // Placeholder for actual icon SVG
    case 'Approved': return `✓ Approved`;
    case 'Rejected': return `✗ Rejected`;
    default: return `? Unknown`;
  }
}
</script>