<script setup lang="ts">
import { useToastStore } from '@/stores/toast'
import { supabase } from '@/supabase'
import { ref, watchEffect } from 'vue'
import type { Ref } from 'vue'
import type { FoodItem } from '@/custom_types/FoodItem.type'
import { useGlobalStore } from '@/stores/globalStatic'
const globals = useGlobalStore()
const toastStore = useToastStore()

const emit = defineEmits(['foodItemSelected'])

const props = defineProps<{
  selectedFoodItem: FoodItem | null
}>()

const foods: Ref<FoodItem[]> = ref([])
const search: Ref<String> = ref('')
const categoryFilter: Ref<String> = ref('all')

watchEffect(async () => {
  let query = supabase
    .from('food_items')
    .select()
    .limit(20)
    .order('last_used_at', { ascending: false, nullsFirst: false })

  if (search.value.length) {
    query = query.ilike('name', `%${search.value}%`)
  }

  if (categoryFilter.value != 'all') {
    query = query.eq('category', categoryFilter.value)
  }

  const { data, error } = await query

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  foods.value = data as FoodItem[]
})
</script>

<template>
  <div class="mb-4 grid grid-cols-1 text-sm md:grid-cols-5">
    <div class="md:col-span-3 md:mr-2">
      <div class="text-left">
        <label class="centered block flex text-gray-700">
          <b>Search</b>
          <input
            type="search"
            class="form-input ml-2"
            placeholder="Search"
            @search="(e: Event) => (search = (e.target as HTMLInputElement).value.trim())"
          />
        </label>
      </div>
    </div>
    <div class="md:col-span-2">
      <div class="mb-4 mt-4 text-left md:ml-3 md:mt-0">
        <label class="centered block flex text-gray-700">
          <b>Category</b>
          <select required class="form-select ml-2 text-sm" v-model="categoryFilter">
            <option value="all">all</option>
            <option v-for="(item, index) in globals.foodCategories">
              {{ item }}
            </option>
          </select>
        </label>
      </div>
    </div>
  </div>

  <h4 class="my-8 text-center" v-if="!foods.length">No Results</h4>
  <div v-else class="grid grid-cols-2 gap-2 text-left sm:grid-cols-3 md:grid-cols-4">
    <div
      v-for="(item, index) in foods"
      class="cursor-pointer rounded border-2 p-2 text-sm"
      :class="selectedFoodItem && selectedFoodItem.id == item.id ? 'border-primary' : ''"
      @click="$emit('foodItemSelected', item)"
    >
      {{ item.name }}
    </div>
  </div>
</template>
