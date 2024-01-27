<script setup lang="ts">
import { ref } from 'vue'
import type { ComponentOptions } from 'vue'

const props = defineProps<{
  options: string[]
  currentView: ComponentOptions
}>()

const isOptionsExpanded = ref(false)

const onMenuItemClick = (option: string) => {
  window.location.hash = option.toLowerCase()
  isOptionsExpanded.value = false
}
</script>

<template>
  <div class="relative z-50 items-center justify-center">
    <div class="relative w-36">
      <button
        class="btn btn-outline btn-sm flex w-full items-center justify-between"
        @click="isOptionsExpanded = !isOptionsExpanded"
        @blur="isOptionsExpanded = false"
      >
        <span>{{ currentView.__name }}</span>
        <svg
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          class="h-4 w-4 transform transition-transform duration-200 ease-in-out"
          :class="isOptionsExpanded ? 'rotate-180' : 'rotate-0'"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M19 9l-7 7-7-7"
          />
        </svg>
      </button>
      <ul
        v-show="isOptionsExpanded"
        class="absolute bottom-full left-0 right-0 mb-4 mt-1 overflow-hidden rounded-lg border bg-white py-2 shadow-lg"
      >
        <li
          v-for="(option, index) in options"
          :key="index"
          class="hover:text-gray cursor-pointer px-6 py-2 transition-colors duration-300"
          :class="[currentView.__name == option ? 'text-primary' : '', '']"
          @mousedown="onMenuItemClick(option)"
        >
          {{ option }}
        </li>
      </ul>
    </div>
  </div>
</template>

<style></style>
