
<template>
  <div class="min-vh-100 bg-light">
    <Navbar />
    <div class="container py-5">
      <div class="mb-5">
        <h1 class="display-5 fw-bold mb-3">Upload Prescription</h1>
        <p class="text-muted">Upload your prescription and get your medicines delivered to your doorstep</p>
      </div>
      <div class="row g-4">
        <div class="col-lg-8">
          <div class="card shadow-sm">
            <div class="card-header">
              <h5 class="card-title d-flex align-items-center">
                <Upload class="me-2" :size="20" /> Prescription Details
              </h5>
            </div>
            <div class="card-body">
              <form @submit.prevent="handleSubmit" class="vstack gap-4">
                <div>
                  <label class="form-label">Upload Prescription Images</label>
                  <div class="border border-2 border-secondary border-dashed rounded p-4 text-center">
                    <Upload class="text-secondary mb-3" :size="40" />
                    <p class="text-muted">
                      Drop your prescription files here, or
                      <label for="prescription-files-input" class="text-primary text-decoration-underline" style="cursor: pointer;">browse</label>
                    </p>
                    <p class="small text-muted">Supports JPG, PNG images up to 10MB each</p>
                    <input id="prescription-files-input" type="file" accept=".jpg,.jpeg,.png" @change="handleFileUpload" class="d-none" />
                  </div>
                </div>
                <div v-if="uploadedFile">
                  <label class="form-label">Uploaded File</label>
                  <div class="d-flex justify-content-between align-items-center bg-success bg-opacity-10 p-3 rounded">
                    <div class="d-flex align-items-center">
                      <FileText class="text-success me-2" :size="18" />
                      <span class="fw-medium">{{ uploadedFile.name }}</span>
                      <span class="text-muted ms-2 small">({{ (uploadedFile.size / 1024 / 1024).toFixed(2) }} MB)</span>
                    </div>
                    <button type="button" class="btn btn-sm btn-outline-danger" @click="removeFile">Remove</button>
                  </div>
                </div>
                <div>
                  <label for="notes" class="form-label">Additional Notes (Optional)</label>
                  <textarea id="notes" class="form-control" rows="3" v-model="notes" placeholder="Any special instructions or notes"></textarea>
                </div>
                <button type="submit" class="btn btn-primary w-100" :disabled="!uploadedFile">Submit Prescription</button>
              </form>
            </div>
          </div>
        </div>
        <div class="col-lg-4">
          <div class="vstack gap-4">
            <div class="card">
              <div class="card-header"><h6 class="card-title mb-0">How it works</h6></div>
              <div class="card-body vstack gap-3">
                <div v-for="(step, i) in howItWorks" :key="i" class="d-flex">
                  <div class="bg-primary bg-opacity-25 rounded-circle d-flex align-items-center justify-content-center me-3" style="width: 32px; height: 32px;">
                    <span class="text-primary fw-bold small">{{ i + 1 }}</span>
                  </div>
                  <div>
                    <h6 class="mb-1 fw-semibold">{{ step.title }}</h6>
                    <p class="text-muted small mb-0">{{ step.description }}</p>
                  </div>
                </div>
              </div>
            </div>
            <div class="card">
              <div class="card-header"><h6 class="card-title mb-0 d-flex align-items-center"><CheckCircle class="me-2 text-success" :size="20" /> Why Choose Us?</h6></div>
              <div class="card-body vstack gap-2">
                <div v-for="(point, i) in whyChooseUs" :key="i" class="d-flex align-items-center">
                  <CheckCircle class="me-2 text-success" :size="16" />
                  <span class="small">{{ point }}</span>
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

<script>
import Navbar from '@/components/Navbar.vue';
import Footer from '@/components/Footer.vue';
import { Upload, FileText, CheckCircle } from 'lucide-vue-next';
import api from '@/api';
import { showSuccess, showError, showInfo } from '@/utils/toast';

export default {
  name: 'PrescriptionsPage',
  components: { Navbar, Footer, Upload, FileText, CheckCircle },
  data() {
    return {
      uploadedFile: null,
      notes: '',
      howItWorks: [
        { title: 'Upload Prescription', description: 'Upload clear images of your prescription' },
        { title: 'Verification', description: 'Our pharmacists verify your prescription' },
        { title: 'Quick Delivery', description: 'Get your medicines delivered within 24 hours' },
      ],
      whyChooseUs: [
        'Licensed pharmacists',
        'Secure prescription handling',
        'Fast home delivery',
        '24/7 customer support',
        'Best prices guaranteed',
      ],
    };
  },
  methods: {
    handleFileUpload(event) {
      const file = event.target.files?.[0];
      if (!file) return;
      this.uploadedFile = file;
      showSuccess(`File "${file.name}" selected.`);
    },
    removeFile() {
      this.uploadedFile = null;
    },
    async handleSubmit() {
      if (!this.uploadedFile) {
        showError('Please upload a prescription file.');
        return;
      }
      const storedUser = localStorage.getItem('user');
      const token = localStorage.getItem('accessToken');
        if (!token) {
        showError('You must be logged in to upload a prescription.');
        this.$router.push('/login');
        return;
      }
      
      const customerId = JSON.parse(storedUser).user_id;
      const formData = new FormData();
      formData.append('customer_id', customerId);
      formData.append('notes', this.notes);
      formData.append('file', this.uploadedFile);

      showInfo('Uploading prescription...');

      try {
        await api.post('/prescriptions/upload', formData, {
          headers: { 'Content-Type': 'multipart/form-data' },
        });
        showSuccess('Prescription uploaded successfully!');
        this.uploadedFile = null;
        this.notes = '';
      } catch (error) {
        showError('Upload failed. Please try again.');
      }
    },
  },
  created() {
    // This hook checks if the user is logged in when the component is created.
    if (!localStorage.getItem('accessToken')) {
      showError('Please log in to access this page.');
      this.$router.push('/login');
    }
  },
};
</script>
