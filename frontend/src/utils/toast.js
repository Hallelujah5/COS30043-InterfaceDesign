// My helper functions for showing different types of toast notifications,
// using the vue-toastification library.

import { useToast } from "vue-toastification";

const toast = useToast();

export const showInfo = (msg) => {
  toast.info(msg);
};

export const showSuccess = (msg) => {
  toast.success(msg);
};

export const showError = (msg) => {
  toast.error(msg);
};
