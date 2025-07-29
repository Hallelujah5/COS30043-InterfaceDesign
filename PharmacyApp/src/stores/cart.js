import { defineStore } from 'pinia';

export const useCartStore = defineStore('cart', {
  // State is equivalent to the state managed in React's useState or useReducer
  state: () => ({
    items: [],
    // Add any other state properties you had in your CartContext, e.g.,
    // total: 0,
    // itemCount: 0,
  }),

  // Getters are like computed properties for your store.
  // They can compute derived state based on store state.
  getters: {
    cartItemCount: (state) => state.items.length,
    cartTotal: (state) => {
      return state.items.reduce((total, item) => {
        return total + (item.price * item.quantity);
      }, 0);
    },
  },

  // Actions are methods that can be called to modify the state.
  // They are equivalent to the functions you would dispatch in a React context.
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