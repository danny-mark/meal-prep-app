<script setup lang="ts">
import { useToastStore } from '@/stores/toast'
import { supabase } from '@/supabase'
import { ref, watchEffect } from 'vue'
import type { Ref } from 'vue'
import type { FavoriteMeal } from '@/custom_types/JournalEntry.type'
import IconTrash from '@/components/icons/IconTrash.vue'
import IconEdit from '@/components/icons/IconEdit.vue'

const toastStore = useToastStore()

const emit = defineEmits(['mealItemSelected', 'editMeal'])

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

const removeFromFavorites = async (meal: FavoriteMeal) => {
  if (!confirm('Remove from favorites?')) return

  const { data, error } = await supabase.from('favorite_meals').delete().eq('id', meal.id)

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  meals.value = meals.value.filter((m) => m.id != meal.id)
}
</script>

<template>
  <div
    class="mb-8 w-1/2 cursor-pointer rounded border-2 p-2 text-left text-sm md:w-1/4"
    @click="$emit('mealItemSelected', null)"
    :class="!selectedMealItem ? 'border-primary' : ''"
  >
    New Meal
  </div>

  <hr class="my-6" />

  <div class="mb-4 w-full">
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
      class="flex cursor-pointer justify-between rounded border-2 p-2 text-sm"
      :class="selectedMealItem && selectedMealItem.id == item.id ? 'border-primary' : ''"
      @click="$emit('mealItemSelected', item)"
    >
      <span>{{ item.name }}</span>

      <div class="flex">
        <div class="cursor-pointer p-2 text-primary" @click.stop="$emit('editMeal', item)" title="Edit meal">
          <IconEdit />
        </div>
        <div class="cursor-pointer p-2 text-danger" @click.stop="removeFromFavorites(item)">
          <IconTrash />
        </div>
      </div>
    </div>
  </div>
</template>
