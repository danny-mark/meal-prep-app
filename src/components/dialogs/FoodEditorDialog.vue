<script setup lang="ts">
import { supabase } from '@/supabase'
import { ref, watch } from 'vue'
import type { Ref } from 'vue'
import Dialog from './Dialog.vue'
import { useToastStore } from '@/stores/toast'
import type { FoodItem } from '@/custom_types/FoodItem.type'
import { useGlobalStore } from '@/stores/globalStatic'
const globals = useGlobalStore()
const toastStore = useToastStore()

const emit = defineEmits(['closed', 'foodsUpdated'])

const props = defineProps<{
  isOpen: boolean
  foodEditorItem: FoodItem | null
}>()

interface FoodFormType extends Omit<FoodItem, 'created_at' | 'last_used_at' | 'macros_per_100'> {
  macros_per_100: {
    protein?: number
    carbs?: number
    fat?: number
    fiber?: number
    calories?: number
  }
}

let foodFormDefault: FoodFormType = {
  name: '',
  note: '',
  category: 'protein',
  macros_per_100: {},
  is_favorite: false,
  is_recipe: false,
  recipe_contents: []
}

const foodForm: Ref<FoodFormType> = ref({
  ...foodFormDefault,
  macros_per_100: { ...foodFormDefault.macros_per_100 }
})

watch(
  () => props.foodEditorItem,
  (foodItem: FoodItem | null) => {
    if (!foodItem) foodForm.value = { ...foodFormDefault }
    else foodForm.value = { ...foodItem }
  }
)

const upsertFoodItem = async () => {
  let { recipe_contents, ...foodFormVals } = foodForm.value

  const { data, error } = await supabase
    .from('food_items')
    .upsert({
      ...foodFormVals,
      last_used_at: new Date()
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

  toastStore.showToast({ title: 'Food Item Saved' })

  foodForm.value = {
    ...foodFormDefault,
    macros_per_100: { ...foodFormDefault.macros_per_100 }
  }
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
      <h3 class="text-xl font-bold">{{ foodEditorItem ? 'Edit Food' : 'Add Food' }}</h3>
    </template>

    <template #body>
      <form @submit.prevent="upsertFoodItem">
        <div class="grid grid-cols-2 gap-2">
          <div class="mb-4 text-left">
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

          <div class="mb-4 text-left">
            <label class="block text-sm text-gray-700">
              <b>Category</b>
              <select required class="form-select mt-2" v-model="foodForm.category">
                <option v-for="(item, index) in globals.foodCategories">
                  {{ item }}
                </option>
              </select>
            </label>
          </div>

          <div class="col-span-2 mb-4 text-left">
            <label class="block text-sm text-gray-700">
              <b>Note</b>
              <textarea
                class="form-input mt-2"
                v-model.trim="foodForm.note"
                placeholder="(Optional)"
              />
            </label>
          </div>

          <div class="mb-4 text-left">
            <label class="block text-sm text-gray-700">
              <b>Calories (kcal)</b>
              <input
                class="form-input mt-2"
                v-model="foodForm.macros_per_100.calories"
                type="number"
                step="any"
              />
            </label>
          </div>

          <div class="mb-4 text-left">
            <label class="block text-sm text-gray-700">
              <b>Fat (g)</b>
              <input
                class="form-input mt-2"
                v-model="foodForm.macros_per_100.fat"
                type="number"
                step="any"
              />
            </label>
          </div>

          <div class="mb-4 text-left">
            <label class="block text-sm text-gray-700">
              <b>Carbs (g)</b>
              <input
                class="form-input mt-2"
                v-model="foodForm.macros_per_100.carbs"
                type="number"
                step="any"
              />
            </label>
          </div>

          <div class="mb-4 text-left">
            <label class="block text-sm text-gray-700">
              <b>Protein (g)</b>
              <input
                class="form-input mt-2"
                v-model="foodForm.macros_per_100.protein"
                type="number"
                step="any"
              />
            </label>
          </div>

          <div class="mb-4 text-left">
            <label class="block text-sm text-gray-700">
              <b>Fiber (g)</b>
              <input
                class="form-input mt-2"
                v-model="foodForm.macros_per_100.fiber"
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
