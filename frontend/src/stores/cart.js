// This file defines my Pinia store for managing the shopping cart state across my Vue app.

import { defineStore } from 'pinia';

export const useCartStore = defineStore('cart', {
  state: () => ({
    items: [],
  }),
  getters: {
    cartItemCount: (state) => state.items.length,
    cartTotal: (state) => {
      return state.items.reduce((total, item) => {
        return total + (item.price * item.quantity);
      }, 0);
    },
  },
  actions: {
    addToCart(product) {
      const existingItem = this.items.find(item => item.product_id === product.product_id);
      if (existingItem) {
        existingItem.quantity++;
      } else {
        this.items.push({ ...product, quantity: 1 });
      }
    },
     // Update quantity manually
    updateQuantity(productId, newQuantity) {
      const item = this.items.find((item) => item.product_id === productId);
      if (item) {
        item.quantity = newQuantity > 0 ? newQuantity : 1;
      }
    },
    removeFromCart(productId) {
      this.items = this.items.filter(item => item.product_id !== productId);
    },
    clearCart() {
      this.items = [];
    },
  },
});