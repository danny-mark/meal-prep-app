<script setup lang="ts">
import { useToastStore } from '@/stores/toast'
const toast = useToastStore()
</script>

<template>
  <div
    v-if="toast.isShown"
    class="toast absolute bottom-4 right-4 rounded px-8 py-4 text-white"
    :class="{
      'bg-primary': toast.style === 'primary',
      'bg-danger': toast.style === 'danger'
    }"
  >
    <h4 class="text-lg">{{ toast.title }}</h4>
    <p v-if="toast.message" class="text-sm">{{ toast.message }}</p>
  </div>
</template>

<style scoped></style>
