<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import type { Ref } from 'vue'
import Dialog from './Dialog.vue'
import { supabase } from '@/supabase'
import TargetsSimple from '../TargetsSimple.vue'
import IngredientsList from '../IngredientsList.vue'
import { sumMealMacros } from '@/shared/calculateMacros'
import type { JournalEntry } from '@/custom_types/JournalEntry.type'
import type { Macros } from '@/custom_types/Macros.type'
import { useToastStore } from '@/stores/toast'

const toastStore = useToastStore()

const emit = defineEmits(['closed', 'saved'])

const props = defineProps<{
  isOpen: boolean
  entry?: JournalEntry
  mealTargets: Macros
}>()

const name: Ref<string> = ref('')

const saveToFavorites = async () => {
  if (!props.entry || !name.value) return
  let data,
    error

    // Create a favorite meal
  ;({ data, error } = await supabase
    .from('favorite_meals')
    .upsert({
      name: name.value,
      contents: props.entry.contents
    })
    .select()
    .single())

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  // Link the entry that sparked this.
  // This is only used for filling out the star in the UI.

  ;({ error } = await supabase
    .from('diary_entries')
    .update({
      favorite_meal_id: data.id
    })
    .eq('id', props.entry.id))

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  emit('closed')
  emit('saved')
}
</script>

<template>
  <Dialog :isOpen="isOpen" @dialog-closed-event="$emit('closed')">
    <template #title>
      <h3 class="text-xl font-bold">Add Meal To Favorites</h3>
    </template>

    <template #body>
      <div v-if="entry">
        <form @submit.prevent="saveToFavorites">
          <div class="grid grid-cols-2 gap-2">
            <div class="mb-4 text-left">
              <label class="block text-sm text-gray-700">
                <b>Name</b>
                <input required class="form-input mt-2" v-model.trim="name" />
              </label>
            </div>
          </div>

          <TargetsSimple :targets="mealTargets" :consumed="sumMealMacros(entry)" />

          <!-- TODO: make these editable from this dialog -->

          <!-- <IngredientsList
            class="mt-6"
            @food-clicked="() => {}"
            @trash-clicked="() => {}"
            @add-clicked="() => {}"
          /> -->

          <button class="btn btn-primary btn-block mt-6" type="submit">Save</button>
        </form>
      </div>
    </template>
  </Dialog>
</template>
