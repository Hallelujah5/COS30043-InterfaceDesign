<!-- FILE: src/App.vue -->
<!-- -->
<!-- This is the root component of your application. It replaces `App.jsx`. -->
<!-- It contains the main layout and the <router-view> which displays the current page. -->

<template>
  <router-view  />
</template>

<script>
// This component is very simple and may not even need a script section
// if it's only holding the router-view.
export default {
  name: 'App',
};
</script>


