<script setup lang="ts">
import FoodEditorDialog from '@/components/dialogs/FoodEditorDialog.vue'
import FoodSelector from '../FoodSelector.vue'
import { ref } from 'vue'
import type { Ref } from 'vue'
import type { FoodItem } from '@/custom_types/FoodItem.type'
import ActionNavigationBar from '../ActionNavigationBar.vue'

const isFoodEditorDialogOpen: Ref<boolean> = ref(false)
const foodEditorItem: Ref<FoodItem | null> = ref(null)
const foodSelectorKey: Ref<number> = ref(0)

const forceFoodSelectorRerender = () => {
  foodSelectorKey.value++
}

const openFoodEditor = (item: FoodItem | null) => {
  foodEditorItem.value = item ? { ...item } : null
  isFoodEditorDialogOpen.value = true
}
</script>

<template>
  <h2 class="mb-10 text-2xl font-bold">Foods</h2>

  <FoodSelector
    @food-item-selected="openFoodEditor"
    :key="foodSelectorKey"
    :selected-food-item="foodEditorItem"
    mode="foods"
  />

  <FoodEditorDialog
    :isOpen="isFoodEditorDialogOpen"
    :foodEditorItem="foodEditorItem"
    @closed="
      () => {
        isFoodEditorDialogOpen = false
        foodEditorItem = null
      }
    "
    @foodsUpdated="forceFoodSelectorRerender"
  />

  <ActionNavigationBar>
    <template #buttons>
      <button class="btn btn-primary btn-sm" @click="() => openFoodEditor(null)">Add Food</button>
    </template>
  </ActionNavigationBar>
</template>
