<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import type { Ref } from 'vue'
import Dialog from './Dialog.vue'
import { supabase } from '@/supabase'
import TargetsSimple from '../TargetsSimple.vue'
import IngredientsList from '../IngredientsList.vue'
import AddJournalFoodDialog from './AddJournalFoodDialog.vue'
import EditJournalFoodDialog from './EditJournalFoodDialog.vue'
import { sumMealMacros } from '@/shared/calculateMacros'
import type { FavoriteMeal, JournalFood } from '@/custom_types/JournalEntry.type'
import type { Macros } from '@/custom_types/Macros.type'
import { useToastStore } from '@/stores/toast'

const toastStore = useToastStore()

const emit = defineEmits(['closed', 'saved'])

const props = defineProps<{
  isOpen: boolean
  meal?: FavoriteMeal
  mealTargets: Macros
}>()

const name: Ref<string> = ref('')
const contents: Ref<JournalFood[]> = ref([])

const addFoodDialogState: Ref<{
  isOpen: boolean
}> = ref({
  isOpen: false
})

const editFoodDialogState: Ref<{
  editedFoodIndex?: number
  isOpen: boolean
}> = ref({
  isOpen: false
})

watch(() => props.meal, (newMeal) => {
  if (newMeal) {
    name.value = newMeal.name
    contents.value = [...newMeal.contents]
  } else {
    name.value = ''
    contents.value = []
  }
})

const saveMeal = async () => {
  if (!name.value || !contents.value.length) return

  let data, error

  if (props.meal) {
    // Update existing meal
    ;({ data, error } = await supabase
      .from('favorite_meals')
      .update({
        name: name.value,
        contents: contents.value
      })
      .eq('id', props.meal.id))
  } else {
    // Create new meal
    ;({ data, error } = await supabase
      .from('favorite_meals')
      .insert({
        name: name.value,
        contents: contents.value
      }))
  }

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  emit('closed')
  emit('saved')
}

const addFoodToMeal = (food: JournalFood) => {
  contents.value.push(food)
}

const editFood = (index: number) => {
  editFoodDialogState.value = {
    isOpen: true,
    editedFoodIndex: index
  }
}

const updateFood = (updatedFood: JournalFood) => {
  const index = editFoodDialogState.value.editedFoodIndex
  if (index !== undefined) {
    contents.value[index] = updatedFood
  }
}

const removeFood = (index: number) => {
  contents.value.splice(index, 1)
}

const mealMacros = computed(() => {
  return {
    protein: contents.value.reduce((sum, food) => sum + food.macros_calculated.protein, 0),
    carbs: contents.value.reduce((sum, food) => sum + food.macros_calculated.carbs, 0),
    fat: contents.value.reduce((sum, food) => sum + food.macros_calculated.fat, 0),
    fiber: contents.value.reduce((sum, food) => sum + food.macros_calculated.fiber, 0),
    calories: contents.value.reduce((sum, food) => sum + food.macros_calculated.calories, 0)
  }
})
</script>

<template>
  <Dialog :isOpen="isOpen" @dialog-closed-event="$emit('closed')">
    <template #title>
      <h3 class="text-xl font-bold">{{ meal ? 'Edit Meal' : 'Create New Meal' }}</h3>
    </template>

    <template #body>
      <form @submit.prevent="saveMeal">
        <div class="mb-4 text-left">
          <label class="block text-sm text-gray-700">
            <b>Name</b>
            <input required class="form-input mt-2" v-model.trim="name" />
          </label>
        </div>

        <TargetsSimple :targets="mealTargets" :consumed="mealMacros" />

        <IngredientsList
          class="mt-6"
          :foods="contents"
          @food-clicked="editFood"
          @trash-clicked="removeFood"
          @add-clicked="addFoodDialogState.isOpen = true"
        />

        <div class="mt-6 flex gap-2">
          <button class="btn btn-primary flex-1" type="submit" :disabled="!name || !contents.length">
            {{ meal ? 'Update Meal' : 'Create Meal' }}
          </button>
          <button class="btn btn-secondary" type="button" @click="$emit('closed')">
            Cancel
          </button>
        </div>
      </form>
    </template>
  </Dialog>

  <AddJournalFoodDialog
    :is-open="addFoodDialogState.isOpen"
    mode="all"
    @closed="addFoodDialogState.isOpen = false"
    @foodAdded="addFoodToMeal"
  />

  <EditJournalFoodDialog
    :is-open="editFoodDialogState.isOpen"
    :food="editFoodDialogState.editedFoodIndex !== undefined ? contents[editFoodDialogState.editedFoodIndex] : undefined"
    @closed="editFoodDialogState.isOpen = false"
    @saved="updateFood"
  />
</template>
