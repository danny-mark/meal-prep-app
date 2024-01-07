<script setup lang="ts">
import { ref } from 'vue'
import type { Ref } from 'vue'
import Dialog from './Dialog.vue'
import MealSelector from '../MealSelector.vue'
import type { JournalFood } from '@/custom_types/JournalEntry.type'
import type { FavoriteMeal } from '@/custom_types/JournalEntry.type'

const emit = defineEmits(['closed', 'mealAdded'])

const props = defineProps<{
  isOpen: boolean
}>()

const selectedMeal: Ref<FavoriteMeal | null> = ref(null)

const addMeal = () => {
  let contents: JournalFood[] = []
  let favoriteId: number | null = null

  if (selectedMeal.value) {
    contents = selectedMeal.value.contents
    favoriteId = selectedMeal.value.id
  }

  emit('mealAdded', contents, favoriteId)
  emit('closed')
  selectedMeal.value = null
}
</script>

<template>
  <Dialog :isOpen="isOpen" @dialog-closed-event="$emit('closed')">
    <template #title>
      <h3 class="text-xl font-bold">Add Meal</h3>
    </template>

    <template #body>
      <MealSelector
        :selected-meal-item="selectedMeal"
        @meal-item-selected="(meal) => (selectedMeal = meal)"
      />

      <button class="btn btn-primary btn-block mt-6" @click="addMeal">Add Meal</button>
    </template>
  </Dialog>
</template>
