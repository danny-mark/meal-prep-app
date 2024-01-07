<script setup lang="ts">
import { useToastStore } from '@/stores/toast'
import { supabase } from '@/supabase'
import { ref, watchEffect } from 'vue'
import type { Ref } from 'vue'
import type { FavoriteMeal } from '@/custom_types/JournalEntry.type'

const toastStore = useToastStore()

const emit = defineEmits(['mealItemSelected'])

const props = defineProps<{
  selectedMealItem: FavoriteMeal | null
}>()

const meals: Ref<FavoriteMeal[]> = ref([])
const search: Ref<String> = ref('')

watchEffect(async () => {
  let query = supabase
    .from('favorite_meals')
    .select()
    .limit(20)
    .order('last_used_at', { ascending: false, nullsFirst: false })

  if (search.value.length) {
    query = query.ilike('name', `%${search.value}%`)
  }

  const { data, error } = await query

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  meals.value = data as FavoriteMeal[]
})
</script>

<template>
  <div
    class="mb-8 w-1/4 cursor-pointer rounded border-2 p-3 text-left"
    @click="$emit('mealItemSelected', null)"
    :class="!selectedMealItem ? 'border-primary' : ''"
  >
    New Meal
  </div>

  <hr class="my-6" />

  <div class="mb-4 w-1/2">
    <input
      type="search"
      class="form-input"
      placeholder="Search"
      @search="(e: Event) => (search = (e.target as HTMLInputElement).value.trim())"
    />
  </div>

  <h4 class="my-8 ml-2 text-left" v-if="!meals.length">No Results</h4>
  <div v-else class="grid grid-cols-2 gap-2 text-left sm:grid-cols-3 md:grid-cols-4">
    <div
      v-for="(item, index) in meals"
      class="mb-4 cursor-pointer rounded border-2 p-3"
      :class="selectedMealItem && selectedMealItem.id == item.id ? 'border-primary' : ''"
      @click="$emit('mealItemSelected', item)"
    >
      {{ item.name }}
    </div>
  </div>
</template>
