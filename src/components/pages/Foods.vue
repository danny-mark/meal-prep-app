<script setup lang="ts">
import FoodEditorDialog from '@/components/dialogs/FoodEditorDialog.vue'
import FoodList from '../FoodList.vue'
import { ref } from 'vue'
import type { Ref } from 'vue'
import type { FoodItem } from '@/custom_types/FoodItem.type'

const isFoodEditorDialogOpen: Ref<boolean> = ref(false)
const foodEditorItem: Ref<FoodItem | null> = ref(null)
const foodListKey: Ref<number> = ref(0)

const forceFoodListRerender = () => {
  foodListKey.value++
}

const openFoodEditor = (item: FoodItem | null) => {
  foodEditorItem.value = item ? { ...item } : null
  isFoodEditorDialogOpen.value = true
}
</script>

<template>
  <h2 class="mb-10 text-2xl font-bold">Foods</h2>

  <FoodList @food-item-clicked="openFoodEditor" :key="foodListKey" />

  <button class="btn btn-primary mx-auto mb-20 mt-4 block" @click="() => openFoodEditor(null)">
    Add Food
  </button>

  <FoodEditorDialog
    :isOpen="isFoodEditorDialogOpen"
    :foodEditorItem="foodEditorItem"
    @closed="isFoodEditorDialogOpen = false"
    @foodsUpdated="forceFoodListRerender"
  />
</template>
