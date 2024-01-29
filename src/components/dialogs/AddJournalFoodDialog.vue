<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import type { Ref } from 'vue'
import Dialog from './Dialog.vue'
import FoodSelector from '../FoodSelector.vue'
import type { FoodItem } from '@/custom_types/FoodItem.type'
import type { Macros, MacroKey } from '@/custom_types/Macros.type'
import { useLocalStorage } from '@vueuse/core'
import type { JournalFood } from '@/custom_types/JournalEntry.type'
import { calculateMacrosPerAmount } from '@/shared/calculateMacros'
import { useGlobalStore } from '@/stores/globalStatic'
const globals = useGlobalStore()

const emit = defineEmits(['closed', 'foodAdded'])

const props = defineProps<{
  isOpen: boolean
  mode: 'all' | 'foods' | 'recipes'
}>()

const selectedFood: Ref<FoodItem | null> = ref(null)
const foodSelectorKey: Ref<number> = ref(0)

const rememberedAmounts = useLocalStorage('remembered-amounts', {})
interface DynamicObject {
  [key: string]: number
}
const selectedFoodAmount: Ref<number> = ref(100)

watch(selectedFood, (newSelected) => {
  if (!newSelected?.id) return

  // Check in localStorage for a record of the last used
  // amount for the currently selected food item.

  selectedFoodAmount.value = (rememberedAmounts.value as DynamicObject)[newSelected.id] || 100
})

const macrosCalculated: Ref<Macros | null> = computed(() => {
  if (!selectedFood.value) return null
  return calculateMacrosPerAmount(selectedFood.value.macros_per_100, selectedFoodAmount.value)
})

const addFood = () => {
  if (!selectedFood.value?.id) {
    return
  }

  // Save the amount to localStorage.
  // This is useful for things that are of set weight,
  // e.g. a slice of cheese that is always 30g
  // TODO: doing this in localStorage was not necessary, we do a DB write anyway to save the last_used_at
  ;(rememberedAmounts.value as DynamicObject)[selectedFood.value.id] = selectedFoodAmount.value

  let { id, name, macros_per_100, category, note } = selectedFood.value
  let amount = selectedFoodAmount.value
  let foodEntry: JournalFood = {
    id,
    name,
    category,
    note,
    macros_per_100,
    macros_calculated: macrosCalculated.value,
    amount
  } as JournalFood

  emit('foodAdded', foodEntry)

  closeAndResetDialog()
}

const cancelFoodSelection = () => {
  selectedFood.value = null
}

const closeAndResetDialog = () => {
  emit('closed')
  selectedFood.value = null
  foodSelectorKey.value++
}
</script>

<template>
  <Dialog :isOpen="isOpen" @dialog-closed-event="closeAndResetDialog">
    <template #title>
      <h3 class="text-xl font-bold">Add Food</h3>
    </template>

    <template #body>
      <div v-if="selectedFood && macrosCalculated" class="mb-8">
        <hr class="my-6" />

        <div class="flex justify-between">
          <div class="mr-8 text-left" style="width: 120px">
            <h5 class="font-bold">{{ selectedFood.name }}</h5>
            <p class="mb-2 text-xs text-muted">{{ selectedFood.category }}</p>
            <p class="text-sm" v-if="selectedFood.note">{{ selectedFood.note }}</p>
            <input class="form-input mt-4" v-model="selectedFoodAmount" step="any" type="number" />
          </div>

          <div style="width: 160px" class="text-left">
            <b>Macros per {{ selectedFoodAmount || 100 }} g</b>
            <div v-for="(item, index) in globals.macros">
              <div class="flex justify-between">
                <span class="text-muted">{{ item }}:</span>
                <span
                  >{{ macrosCalculated[item as MacroKey] }}
                  {{ item == 'calories' ? 'kcal' : 'g' }}</span
                >
              </div>
            </div>
          </div>
        </div>

        <div class="mt-6 flex">
          <button class="btn btn-outline btn-sm mr-2" @click="cancelFoodSelection">Back</button>
          <button class="btn btn-primary btn-sm" @click="addFood">Add Food</button>
        </div>
      </div>

      <FoodSelector
        v-else
        @food-item-selected="(food) => (selectedFood = food)"
        :selected-food-item="selectedFood"
        :key="foodSelectorKey"
        :mode="mode"
      />
    </template>
  </Dialog>
</template>
