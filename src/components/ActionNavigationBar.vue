<script setup lang="ts">
import Dropdown from '@/components/Dropdown.vue'
import { usePageRouterStore } from '@/stores/pageRouter'

const router = usePageRouterStore()
</script>

<template>
  <div class="fixed bottom-0 left-0 flex w-full border-t bg-gray-50 bg-white p-4">
    <Dropdown
      :options="router.pageNames"
      :current-view="router.currentView"
      class="mr-2 bg-white"
    />

    <slot name="buttons"></slot>
  </div>
</template>
