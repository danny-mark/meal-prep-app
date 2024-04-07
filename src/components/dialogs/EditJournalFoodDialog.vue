<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import type { Ref } from 'vue'
import AmountIncrementButtonsRow from '@/components/AmountIncrementButtonsRow.vue'
import Dialog from './Dialog.vue'
import type { Macros, MacroKey } from '@/custom_types/Macros.type'
import { useLocalStorage } from '@vueuse/core'
import type { JournalFood } from '@/custom_types/JournalEntry.type'
import { calculateMacrosPerAmount } from '@/shared/calculateMacros'
import { useGlobalStore } from '@/stores/globalStatic'
const globals = useGlobalStore()

const emit = defineEmits(['closed', 'saved'])

const props = defineProps<{
  isOpen: boolean
  food?: JournalFood
}>()

const rememberedAmounts = useLocalStorage('remembered-amounts', {})
interface DynamicObject {
  [key: string]: number
}
const amount: Ref<number> = ref(100)

watch(
  () => props.food,
  (newSelected) => {
    if (!newSelected?.id) return
    amount.value = newSelected.amount
  }
)

const macrosCalculated: Ref<Macros | null> = computed(() => {
  if (!props.food) return null
  return calculateMacrosPerAmount(props.food.macros_per_100, amount.value)
})

const updateFoodAmount = () => {
  if (!props.food || !macrosCalculated.value) {
    return
  }

  // Save the amount to localStorage.
  // This is useful for things that are of set weight,
  // e.g. a slice of cheese that is always 30g
  // TODO: doing this in localStorage was not necessary, we do a DB write anyway to save the last_used_at
  ;(rememberedAmounts.value as DynamicObject)[props.food.id] = amount.value

  let updatedFood = { ...props.food }
  updatedFood.amount = amount.value
  updatedFood.macros_calculated = macrosCalculated.value

  emit('saved', updatedFood)
  emit('closed')
}
</script>

<template>
  <Dialog :isOpen="isOpen" @dialog-closed-event="$emit('closed')">
    <template #title>
      <h3 class="text-xl font-bold">Edit Food</h3>
    </template>

    <template #body>
      <div v-if="food && macrosCalculated">
        <div class="flex justify-between">
          <div class="mr-8 text-left" style="width: 120px">
            <h5 class="font-bold">{{ food.name }}</h5>
            <p class="mb-2 text-xs text-muted">{{ food.category }}</p>
            <p class="text-sm" v-if="food.note">{{ food.note }}</p>
            <label>
              <b class="mt-4 block">Amount (g)</b>
              <input class="form-input" v-model="amount" step="any" type="number" />
            </label>
          </div>

          <div style="width: 160px" class="text-left">
            <b>Macros per {{ amount || 100 }} g</b>
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

        <AmountIncrementButtonsRow
          :amount="amount"
          :set-amount="
            (newVal: number) => {
              amount = newVal
            }
          "
        />

        <button class="btn btn-primary btn-block mt-6" @click="updateFoodAmount">Save</button>
      </div>
    </template>
  </Dialog>
</template>
