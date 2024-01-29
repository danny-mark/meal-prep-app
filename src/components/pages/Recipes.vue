<script setup lang="ts">
import RecipeEditorDialog from '@/components/dialogs/RecipeEditorDialog.vue'
import FoodSelector from '../FoodSelector.vue'
import { ref } from 'vue'
import type { Ref } from 'vue'
import type { FoodItem } from '@/custom_types/FoodItem.type'
import ActionNavigationBar from '../ActionNavigationBar.vue'

const isRecipeEditorDialogOpen: Ref<boolean> = ref(false)
const recipeEditorItem: Ref<FoodItem | null> = ref(null)
const foodSelectorKey: Ref<number> = ref(0)

const forceFoodSelectorRerender = () => {
  foodSelectorKey.value++
}

const openRecipeEditor = (item: FoodItem | null) => {
  recipeEditorItem.value = item ? { ...item } : null
  isRecipeEditorDialogOpen.value = true
}
</script>

<template>
  <h2 class="mb-2 text-2xl font-bold">Recipes</h2>
  <h3 class="mb-1">
    Recipes are foods comprised of other foods. <br />
    After creating a recipe, it can be added to the journal via the foods menu.
  </h3>
  <p class="text-bold mb-10 text-xs text-muted">
    Updating foods does not auto-update recipes that have them as ingredients
  </p>

  <FoodSelector
    @food-item-selected="openRecipeEditor"
    :key="foodSelectorKey"
    :selected-food-item="recipeEditorItem"
    mode="recipes"
  />

  <RecipeEditorDialog
    :isOpen="isRecipeEditorDialogOpen"
    :recipeEditorItem="recipeEditorItem"
    @closed="
      () => {
        isRecipeEditorDialogOpen = false
        recipeEditorItem = null
      }
    "
    @foodsUpdated="forceFoodSelectorRerender"
  />

  <ActionNavigationBar>
    <template #buttons>
      <button class="btn btn-primary btn-sm" @click="() => openRecipeEditor(null)">
        Add Recipe
      </button>
    </template>
  </ActionNavigationBar>
</template>
