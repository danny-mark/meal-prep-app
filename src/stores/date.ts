import { ref, computed } from 'vue'
import type { Ref } from 'vue'
import { defineStore } from 'pinia'

export const useDateStore = defineStore('date', () => {
  const date: Ref<Date> = ref(new Date())
  
  const goToPreviousDay = () => {
    const newDate = new Date(date.value)
    newDate.setDate(newDate.getDate() - 1)
    date.value = newDate
  }
  
  const goToNextDay = () => {
    const newDate = new Date(date.value)
    newDate.setDate(newDate.getDate() + 1)
    date.value = newDate
  }
  
  return { date, goToPreviousDay, goToNextDay }
})
