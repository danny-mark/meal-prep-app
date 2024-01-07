import { ref, computed } from 'vue'
import type { Ref } from 'vue'
import { defineStore } from 'pinia'

export const useDateStore = defineStore('date', () => {
  const date: Ref<Date> = ref(new Date())
  return { date }
})
