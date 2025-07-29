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
      const existingItem = this.items.find(item => item.id === product.id);
      if (existingItem) {
        existingItem.quantity++;
      } else {
        this.items.push({ ...product, quantity: 1 });
      }
    },
    removeFromCart(productId) {
      this.items = this.items.filter(item => item.id !== productId);
    },
    clearCart() {
      this.items = [];
    },
  },
});