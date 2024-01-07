<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue'
import { supabase } from '@/supabase'
import { useToastStore } from '@/stores/toast'
import { useDateStore } from '@/stores/date'
import TargetsChart from '../TargetsChart.vue'
import TargetsSimple from '../TargetsSimple.vue'
import AddJournalFoodDialog from '../dialogs/AddJournalFoodDialog.vue'
import EditJournalFoodDialog from '../dialogs/EditJournalFoodDialog.vue'
import FavoriteMealEditorDialog from '../dialogs/FavoriteMealEditorDialog.vue'
import AddJournalMealDialog from '../dialogs/AddJournalMealDialog.vue'
import MealContentsList from '../MealContentsList.vue'
import IconRepeat from '@/components/icons/IconRepeat.vue'
import IconTrash from '@/components/icons/IconTrash.vue'
import IconStarOutline from '@/components/icons/IconStarOutline.vue'
import IconStarFilled from '@/components/icons/IconStarFilled.vue'
import { sumMealMacros } from '@/shared/calculateMacros'
import type { Ref } from 'vue'
import type { MacroKey, Macros } from '@/custom_types/Macros.type'
import type { JournalEntry, JournalFood } from '@/custom_types/JournalEntry.type'

const toastStore = useToastStore()
const dateStore = useDateStore()

const addFoodDialogState: Ref<{
  entry: JournalEntry | null
  isOpen: boolean
}> = ref({
  entry: null,
  isOpen: false
})
const editFoodDialogState: Ref<{
  entry?: JournalEntry
  editedFoodIndex?: number
  isOpen: boolean
}> = ref({
  isOpen: false
})
const favoriteMealDialogState: Ref<{
  entry?: JournalEntry
  isOpen: boolean
}> = ref({
  isOpen: false
})
const addJournalMealDialogState: Ref<{
  isOpen: boolean
}> = ref({
  isOpen: false
})

const dailyTargets: Ref<Macros> = ref({
  protein: 70,
  carbs: 300,
  fat: 60,
  fiber: 30,
  calories: 2000
})
const mealTargets: Ref<Macros> = ref({
  protein: 25,
  carbs: 100,
  fat: 20,
  fiber: 10,
  calories: 600
})

const entries: Ref<JournalEntry[]> = ref([])

const dailyConsumed = computed<Macros>(() => {
  let m = {
    protein: 0,
    carbs: 0,
    fat: 0,
    fiber: 0,
    calories: 0
  } as Macros

  for (const entry of entries.value) {
    for (const food of entry.contents) {
      m.protein += food.macros_calculated.protein
      m.carbs += food.macros_calculated.carbs
      m.fat += food.macros_calculated.fat
      m.fiber += food.macros_calculated.fiber
      m.calories += food.macros_calculated.calories
    }
  }

  return m
})

const dateFormatted = computed<string>(() => {
  return new Intl.DateTimeFormat('en-US', {
    day: 'numeric',
    month: 'short',
    year: 'numeric'
  }).format(dateStore.date)
})

onMounted(async () => {
  // Get targets

  const { data, error } = await supabase.from('targets').select()

  if (error) {
    return toastStore.showErrorToast(error.message)
  }

  if (data.length) {
    for (const dbTarget of data) {
      if (dbTarget.type == 'daily') dailyTargets.value = { ...dbTarget.macros }
      if (dbTarget.type == 'meal') mealTargets.value = { ...dbTarget.macros }
    }
  }

  fetchEntries()
})

watch(dateStore, (newDate) => {
  fetchEntries()
})

const fetchEntries = async () => {
  // TODO: optimize the refresh

  const { data, error } = await supabase
    .from('diary_entries')
    .select(
      `*, favorite_meals (
      name, id
    )`
    )
    .eq('date', dateStore.date.toISOString().slice(0, 10))
    .order('id', { ascending: true })

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  entries.value = data
}

const addFoodToEntry = async (addedFood: JournalFood) => {
  let entry = addFoodDialogState.value.entry
  let data, error

  if (!entry) {
    // Create a new entry with type "food". The addedFood will be the only item in it.

    ;({ data, error } = await supabase.from('diary_entries').insert({
      date: dateStore.date,
      contents: [addedFood],
      type: 'food'
    }))
  } else {
    // Meal entry -> add the food to contents

    let contents = entry.contents
    contents.push(addedFood)
    ;({ data, error } = await supabase
      .from('diary_entries')
      .update({
        contents
      })
      .eq('id', entry.id))
  }

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  fetchEntries()

  // Update the food's last_used_at column
  await supabase.from('food_items').update({ last_used_at: new Date() }).eq('id', addedFood.id)
}

const repeatEntry = async (entry: JournalEntry) => {
  const { data, error } = await supabase.from('diary_entries').insert({
    date: dateStore.date,
    contents: entry.contents,
    type: entry.type,
    favorite_meal_id: entry.favorite_meals?.id
  })

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  fetchEntries()
}

const editJournalFood = async (entry: JournalEntry, foodIndex: number) => {
  editFoodDialogState.value = {
    isOpen: true,
    entry: entry,
    editedFoodIndex: foodIndex
  }
}

const updateJournalEntry = async (updatedFood: JournalFood) => {
  let entry = editFoodDialogState.value.entry
  let index = editFoodDialogState.value.editedFoodIndex

  if (!entry || index == undefined) {
    return
  }

  let newContents = entry.contents
  newContents[index] = updatedFood

  const { data, error } = await supabase
    .from('diary_entries')
    .update({
      contents: newContents
    })
    .eq('id', entry.id)

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  fetchEntries()
}

const addMealEntry = async (contents: JournalFood[], favoriteID: number) => {
  const { data, error } = await supabase.from('diary_entries').insert({
    date: dateStore.date,
    type: 'meal',
    favorite_meal_id: favoriteID,
    contents
  })

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  fetchEntries()
}

const removeFoodFromMeal = async (entry: JournalEntry, indexToRemove: number) => {
  if (!confirm('Delete food from entry?')) return

  let newContents = entry.contents.filter((_, i) => i !== indexToRemove)

  const { data, error } = await supabase
    .from('diary_entries')
    .update({
      contents: newContents
    })
    .eq('id', entry.id)

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  fetchEntries()
}

const deleteEntry = async (entry: JournalEntry) => {
  // Deletes an entire entry.
  if (entry.contents.length && !confirm('Delete journal entry?')) return

  const { data, error } = await supabase.from('diary_entries').delete().eq('id', entry.id)

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  fetchEntries()
}
</script>

<template>
  <div style="max-width: 200px" class="m-auto mb-6 border-b-2 border-primary pb-1 font-bold">
    {{ dateFormatted }}
  </div>

  <TargetsChart :targets="dailyTargets" :consumed="dailyConsumed" />

  <hr class="my-6" />

  <div class="m-auto mb-20 max-w-xl px-6">
    <div v-for="(entry, index) in entries" :key="index" class="border-b p-2 last:border-b-0">
      <div
        v-if="entry.type == 'food'"
        class="flex justify-between"
        @click="editJournalFood(entry, 0)"
      >
        <div class="text-left">
          <b>{{ entry.contents[0].name }}</b>
          <p>{{ entry.contents[0].amount }} g</p>
        </div>
        <div class="centered flex text-xl">
          <div class="mr-4 cursor-pointer p-4 text-primary" @click.stop="repeatEntry(entry)">
            <IconRepeat />
          </div>
          <div class="cursor-pointer p-4 text-danger" @click.stop="deleteEntry(entry)">
            <IconTrash />
          </div>
        </div>
      </div>

      <div v-else>
        <div class="flex content-start justify-between text-left">
          <div>
            <b>{{ entry.favorite_meals ? entry.favorite_meals.name : 'Meal' }}</b>
            <TargetsSimple :targets="mealTargets" :consumed="sumMealMacros(entry)" />
          </div>

          <div class="centered flex text-xl">
            <div v-if="entry.favorite_meals" class="mr-4 p-4 text-primary">
              <!-- TODO this needs more work -->
              <IconStarFilled />
            </div>
            <div
              v-else
              class="mr-4 cursor-pointer p-4 text-primary"
              @click.stop="
                () => {
                  favoriteMealDialogState = {
                    isOpen: true,
                    entry
                  }
                }
              "
            >
              <IconStarOutline />
            </div>

            <div class="mr-4 cursor-pointer p-4 text-primary" @click.stop="repeatEntry(entry)">
              <IconRepeat />
            </div>
            <div class="cursor-pointer p-4 text-danger" @click.stop="deleteEntry(entry)">
              <IconTrash />
            </div>
          </div>
        </div>

        <MealContentsList
          class="my-4"
          :entry="entry"
          @food-clicked="editJournalFood"
          @trash-clicked="removeFoodFromMeal"
          @add-clicked="() => (addFoodDialogState = { isOpen: true, entry })"
        />
      </div>
    </div>
  </div>

  <div class="fixed bottom-0 left-0 w-full border-t bg-white p-4">
    <button
      class="btn-primary mr-4 inline-block rounded px-8 py-2"
      @click="addJournalMealDialogState.isOpen = true"
    >
      Add Meal
    </button>
    <button
      class="btn-primary inline-block rounded px-8 py-2"
      @click="() => (addFoodDialogState = { isOpen: true, entry: null })"
    >
      Add Food
    </button>
  </div>

  <AddJournalFoodDialog
    :is-open="addFoodDialogState.isOpen"
    @closed="addFoodDialogState.isOpen = false"
    @foodAdded="addFoodToEntry"
  />

  <EditJournalFoodDialog
    :is-open="editFoodDialogState.isOpen"
    :food="
      editFoodDialogState.entry && editFoodDialogState.editedFoodIndex != undefined
        ? editFoodDialogState.entry.contents[editFoodDialogState.editedFoodIndex]
        : undefined
    "
    @closed="editFoodDialogState.isOpen = false"
    @saved="updateJournalEntry"
  />

  <AddJournalMealDialog
    :is-open="addJournalMealDialogState.isOpen"
    @closed="addJournalMealDialogState.isOpen = false"
    @meal-added="addMealEntry"
  />

  <FavoriteMealEditorDialog
    :is-open="favoriteMealDialogState.isOpen"
    :entry="favoriteMealDialogState.entry"
    :mealTargets="mealTargets"
    @closed="favoriteMealDialogState.isOpen = false"
    @saved="fetchEntries"
  />
</template>
