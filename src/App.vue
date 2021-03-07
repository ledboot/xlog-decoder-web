<template>
  <Upload />
</template>

<script>
  import Upload from './components/Upload.vue'

  export default {
    name: 'App',
    components: {
      Upload,
    },
  }
</script>

<style>
  #app {
    font-family: Verdana, Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;
    margin-top: 60px;
  }
  ::-webkit-scrollbar {
    width: 0 !important;
  }
  ::-webkit-scrollbar {
    width: 0 !important;
    height: 0;
  }
</style>
