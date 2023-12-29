<script setup lang="ts">
import { supabase } from '@/supabase'
import { ref, watch } from 'vue'
import type { Ref } from 'vue'
import Dialog from './Dialog.vue'
import { useToastStore } from '@/stores/toast'
import type { FoodItem } from '@/custom_types/FoodItem.type'

const toastStore = useToastStore()

const emit = defineEmits(['closed', 'foodsUpdated'])

const props = defineProps<{
  isOpen: boolean
  foodEditorItem: FoodItem | null
}>()

interface FoodFormType extends Omit<FoodItem, 'created_at' | 'last_used_at'> {}

let foodFormDefault: FoodFormType = {
  name: '',
  note: '',
  category: 'protein',
  macros: {
    protein: 0,
    carbs: 0,
    fat: 0,
    fiber: 0,
    calories: 0,
    fodmap: 0
  },
  is_favorite: false
}

const foodForm: Ref<FoodFormType> = ref({
  ...foodFormDefault,
  macros: { ...foodFormDefault.macros }
})

watch(
  () => props.foodEditorItem,
  (foodItem: FoodItem | null) => {
    if (!foodItem) foodForm.value = { ...foodFormDefault }
    else foodForm.value = { ...foodItem }
  }
)

const upsertFoodItem = async () => {
  const { data, error } = await supabase
    .from('food_items')
    .upsert({
      ...foodForm.value
    })
    .select()

  if (error) {
    let message = error.message
    if (message.includes('unique constraint "food_items_name_key"')) {
      message = 'A food item with this name already exists.'
    }

    toastStore.showErrorToast(message)
    return
  }

  emit('closed')
  emit('foodsUpdated')
}

const deleteFoodItem = async () => {
  if (!props.foodEditorItem) return

  if (!confirm(`Are you sure you want to delete ${props.foodEditorItem.name}?`)) return

  const { data, error } = await supabase
    .from('food_items')
    .delete()
    .eq('id', props.foodEditorItem.id)

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  emit('closed')
  emit('foodsUpdated')
}
</script>

<template>
  <Dialog :isOpen="isOpen" @dialog-closed-event="$emit('closed')">
    <template #title>
      <h3 class="text-xl font-bold">{{ foodEditorItem ? 'Edit food' : 'Add Food' }}</h3>
    </template>

    <template #body>
      <form @submit.prevent="upsertFoodItem">
        <div class="grid grid-cols-2">
          <div class="mb-4 mr-1 text-left">
            <label class="block text-sm text-gray-700">
              <b>Name</b>
              <input
                required
                class="form-input mt-2"
                v-model.trim="foodForm.name"
                placeholder="Whole Egg"
              />
            </label>
          </div>

          <div class="mb-4 ml-1 text-left">
            <label class="block text-sm text-gray-700">
              <b>Category</b>
              <select required class="form-select mt-2" v-model="foodForm.category">
                <option v-for="(item, index) in $foodCategories">
                  {{ item }}
                </option>
              </select>
            </label>
          </div>

          <div class="col-span-2 mb-4 mr-1 text-left">
            <label class="block text-sm text-gray-700">
              <b>Note</b>
              <textarea
                class="form-input mt-2"
                v-model.trim="foodForm.note"
                placeholder="(Optional)"
              />
            </label>
          </div>

          <div class="mb-4 mr-1 text-left">
            <label class="block text-sm text-gray-700">
              <b>Protein</b>
              <input
                required
                class="form-input mt-2"
                v-model="foodForm.macros.protein"
                type="number"
                step="any"
              />
            </label>
          </div>

          <div class="mb-4 ml-1 text-left">
            <label class="block text-sm text-gray-700">
              <b>Carbs</b>
              <input
                required
                class="form-input mt-2"
                v-model="foodForm.macros.carbs"
                type="number"
                step="any"
              />
            </label>
          </div>

          <div class="mb-4 mr-1 text-left">
            <label class="block text-sm text-gray-700">
              <b>Fat</b>
              <input
                required
                class="form-input mt-2"
                v-model="foodForm.macros.fat"
                type="number"
                step="any"
              />
            </label>
          </div>

          <div class="mb-4 ml-1 text-left">
            <label class="block text-sm text-gray-700">
              <b>Fiber</b>
              <input
                required
                class="form-input mt-2"
                v-model="foodForm.macros.fiber"
                type="number"
                step="any"
              />
            </label>
          </div>

          <div class="mb-4 mr-1 text-left">
            <label class="block text-sm text-gray-700">
              <b>Calories</b>
              <input
                required
                class="form-input mt-2"
                v-model="foodForm.macros.calories"
                type="number"
                step="any"
              />
            </label>
          </div>

          <div class="mb-4 ml-1 text-left">
            <label class="block text-sm text-gray-700">
              <b>Fodmap</b>
              <input
                required
                class="form-input mt-2"
                v-model="foodForm.macros.fodmap"
                type="number"
                step="any"
              />
            </label>
          </div>
        </div>

        <button class="btn btn-primary btn-block mt-6" type="submit">
          {{ foodEditorItem ? 'Update' : 'Add' }}
        </button>
      </form>

      <button v-if="foodEditorItem" class="mt-4 px-6 py-2 text-danger" @click="deleteFoodItem">
        Delete
      </button>
    </template>
  </Dialog>
</template>
