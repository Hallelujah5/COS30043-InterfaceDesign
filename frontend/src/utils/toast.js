// FILE: src/utils/toast.js
// My helper functions for showing different types of toast notifications,
// using the vue-toastification library.

import { useToast } from "vue-toastification";

const toast = useToast();

// The main options are set globally in main.js, so these functions
// just need to be called with a message.
export const showInfo = (msg) => {
  toast.info(msg);
};

export const showSuccess = (msg) => {
  toast.success(msg);
};

export const showError = (msg) => {
  toast.error(msg);
};
