<script setup lang="ts">
import MealSelector from '../MealSelector.vue'
import { ref } from 'vue'
import type { Ref } from 'vue'
import type { FavoriteMeal } from '@/custom_types/JournalEntry.type'

const foodEditorItem: Ref<FavoriteMeal | null> = ref(null)
const mealSelectorKey: Ref<number> = ref(0)

const forceFoodSelectorRerender = () => {
  mealSelectorKey.value++
}
</script>

<template>
  <h2 class="mb-2 text-2xl font-bold">Meals</h2>
  <h3 class="mb-10">This page is not finished</h3>

  <MealSelector
    @meal-item-selected="() => {}"
    :key="mealSelectorKey"
    :selected-meal-item="foodEditorItem"
  />
</template>
