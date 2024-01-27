<script setup lang="ts">
import { useToastStore } from '@/stores/toast'
const toast = useToastStore()
</script>

<template>
  <div
    v-if="toast.isShown"
    class="toast absolute left-4 right-4 top-4 rounded px-6 py-2 text-center text-white"
    :class="{
      'bg-primary': toast.style === 'primary',
      'bg-danger': toast.style === 'danger'
    }"
  >
    <h4 class="text-sm">{{ toast.title }}</h4>
    <p v-if="toast.message" class="text-xs">{{ toast.message }}</p>
  </div>
</template>

<style scoped></style>
