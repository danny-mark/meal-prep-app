<script setup lang="ts">
import { useSessionStore } from '@/stores/session'
import { ref, onMounted } from 'vue'
import type { Macros } from '@/custom_types/Macros.type'
import type { Ref } from 'vue'
import { supabase } from '@/supabase'
import { useToastStore } from '@/stores/toast'
import ActionNavigationBar from '../ActionNavigationBar.vue'

const toastStore = useToastStore()

interface Target {
  type: 'daily' | 'meal'
  macros: Macros
}

let defaultMacros: Macros = {
  protein: 0,
  carbs: 0,
  fat: 0,
  fiber: 0,
  calories: 0
}

const dailyTargetForm: Ref<Target> = ref({
  type: 'daily',
  macros: { ...defaultMacros }
})
const mealTargetForm: Ref<Target> = ref({
  type: 'meal',
  macros: { ...defaultMacros }
})

onMounted(async () => {
  const { data, error } = await supabase.from('targets').select()

  if (error) {
    return toastStore.showErrorToast(error.message)
  }

  if (data.length) {
    for (const dbTarget of data) {
      if (dbTarget.type == 'daily') dailyTargetForm.value = { ...dbTarget }
      if (dbTarget.type == 'meal') mealTargetForm.value = { ...dbTarget }
    }
  }
})

const upsertTarget = async (type: 'daily' | 'meal') => {
  const { data, error } = await supabase
    .from('targets')
    .upsert(type == 'daily' ? { ...dailyTargetForm.value } : { ...mealTargetForm.value })
    .select()

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  toastStore.showToast({ title: 'Target Saved' })
}
</script>

<template>
  <form @submit.prevent="upsertTarget('daily')" class="text-left">
    <h3 class="text-xl font-bold capitalize">Daily Target</h3>

    <div class="mt-6 grid grid-cols-2 gap-2">
      <div class="mb-4 mr-1 text-left">
        <label class="block text-sm text-gray-700">
          <b>Protein (g)</b>
          <input
            required
            class="form-input mt-2"
            v-model="dailyTargetForm.macros.protein"
            type="number"
            min="1"
            step="any"
          />
        </label>
      </div>

      <div class="mb-4 ml-1 text-left">
        <label class="block text-sm text-gray-700">
          <b>Carbs (g)</b>
          <input
            required
            class="form-input mt-2"
            v-model="dailyTargetForm.macros.carbs"
            type="number"
            min="1"
            step="any"
          />
        </label>
      </div>

      <div class="mb-4 mr-1 text-left">
        <label class="block text-sm text-gray-700">
          <b>Fat (g)</b>
          <input
            required
            class="form-input mt-2"
            v-model="dailyTargetForm.macros.fat"
            type="number"
            min="1"
            step="any"
          />
        </label>
      </div>

      <div class="mb-4 ml-1 text-left">
        <label class="block text-sm text-gray-700">
          <b>Fiber (g)</b>
          <input
            required
            class="form-input mt-2"
            v-model="dailyTargetForm.macros.fiber"
            type="number"
            min="1"
            step="any"
          />
        </label>
      </div>

      <div class="mb-4 mr-1 text-left">
        <label class="block text-sm text-gray-700">
          <b>Calories (kcal)</b>
          <input
            required
            class="form-input mt-2"
            v-model="dailyTargetForm.macros.calories"
            type="number"
            min="1"
            step="any"
          />
        </label>
      </div>
    </div>

    <button class="btn btn-primary mt-4 w-36 text-sm" type="submit">Save</button>
  </form>

  <hr class="my-10" />

  <form @submit.prevent="upsertTarget('meal')" class="text-left">
    <h3 class="text-xl font-bold capitalize">Meal Target</h3>

    <div class="mt-6 grid grid-cols-2 gap-2">
      <div class="mb-4 mr-1 text-left">
        <label class="block text-sm text-gray-700">
          <b>Protein (g)</b>
          <input
            required
            class="form-input mt-2"
            v-model="mealTargetForm.macros.protein"
            type="number"
            min="0"
            step="any"
          />
        </label>
      </div>

      <div class="mb-4 ml-1 text-left">
        <label class="block text-sm text-gray-700">
          <b>Carbs (g)</b>
          <input
            required
            class="form-input mt-2"
            v-model="mealTargetForm.macros.carbs"
            type="number"
            min="0"
            step="any"
          />
        </label>
      </div>

      <div class="mb-4 mr-1 text-left">
        <label class="block text-sm text-gray-700">
          <b>Fat (g)</b>
          <input
            required
            class="form-input mt-2"
            v-model="mealTargetForm.macros.fat"
            type="number"
            min="0"
            step="any"
          />
        </label>
      </div>

      <div class="mb-4 ml-1 text-left">
        <label class="block text-sm text-gray-700">
          <b>Fiber (g)</b>
          <input
            required
            class="form-input mt-2"
            v-model="mealTargetForm.macros.fiber"
            type="number"
            min="0"
            step="any"
          />
        </label>
      </div>

      <div class="mb-4 mr-1 text-left">
        <label class="block text-sm text-gray-700">
          <b>Calories (kcal)</b>
          <input
            required
            class="form-input mt-2"
            v-model="mealTargetForm.macros.calories"
            type="number"
            min="0"
            step="any"
          />
        </label>
      </div>
    </div>

    <button class="btn btn-primary mb-8 mt-4 w-36 text-sm" type="submit">Save</button>
  </form>

  <ActionNavigationBar></ActionNavigationBar>
</template>
