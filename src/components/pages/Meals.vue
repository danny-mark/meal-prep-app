<script setup lang="ts">
import MealSelector from '../MealSelector.vue'
import MealEditorDialog from '../dialogs/MealEditorDialog.vue'
import { ref } from 'vue'
import type { Ref } from 'vue'
import type { FavoriteMeal } from '@/custom_types/JournalEntry.type'
import type { Macros } from '@/custom_types/Macros.type'
import ActionNavigationBar from '../ActionNavigationBar.vue'

const selectedMealItem: Ref<FavoriteMeal | null> = ref(null)
const mealSelectorKey: Ref<number> = ref(0)

const mealEditorDialogState: Ref<{
  isOpen: boolean
  meal?: FavoriteMeal
}> = ref({
  isOpen: false
})

const mealTargets: Ref<Macros> = ref({
  protein: 25,
  carbs: 100,
  fat: 20,
  fiber: 10,
  calories: 600
})

const forceMealSelectorRerender = () => {
  mealSelectorKey.value++
}

const openMealEditor = (meal?: FavoriteMeal) => {
  mealEditorDialogState.value = {
    isOpen: true,
    meal
  }
}

const closeMealEditor = () => {
  mealEditorDialogState.value.isOpen = false
  forceMealSelectorRerender()
}
</script>

<template>
  <h2 class="mb-2 text-2xl font-bold">Meals</h2>
  <p class="mb-6 text-gray-600">Create and edit your favorite meals</p>

  <MealSelector
    @meal-item-selected="(meal: FavoriteMeal) => selectedMealItem = meal"
    @edit-meal="openMealEditor"
    :key="mealSelectorKey"
    :selected-meal-item="selectedMealItem"
  />

  <ActionNavigationBar>
    <template #buttons>
      <button class="btn btn-primary btn-sm" @click="openMealEditor()">
        + New Meal
      </button>
    </template>
  </ActionNavigationBar>

  <MealEditorDialog
    :is-open="mealEditorDialogState.isOpen"
    :meal="mealEditorDialogState.meal"
    :meal-targets="mealTargets"
    @closed="closeMealEditor"
    @saved="closeMealEditor"
  />
</template>
