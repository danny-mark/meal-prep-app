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
  mode: 'all' | 'foods' | 'recipes'
}>()

const foods: Ref<FoodItem[]> = ref([])
const search: Ref<String> = ref('')
const categoryFilter: Ref<String> = ref('all')

watchEffect(async () => {
  let query = supabase
    .from('food_items')
    .select(
      `
    *,
    recipe_contents!recipe_food_id(ingredient_food_id(*), amount)`
    )
    .limit(20)
    .order('last_used_at', { ascending: false, nullsFirst: false })

  if (search.value.length) {
    query = query.ilike('name', `%${search.value}%`)
  }

  if (categoryFilter.value != 'all') {
    query = query.eq('category', categoryFilter.value)
  }

  if (props.mode != 'all') {
    query = query.eq('is_recipe', props.mode == 'recipes')
  }

  const { data, error } = await query

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  // Clean up the recursive many-to-many same table join
  data.map((f) => {
    if (!f.is_recipe) return f

    let tmp = []
    for (const ingredient of f.recipe_contents) {
      tmp.push({ ...ingredient.ingredient_food_id, amount: ingredient.amount }) // remove this prop and get its value instead
    }
    f.recipe_contents = tmp
    return f
  })

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
  <div v-else class="grid grid-cols-1 gap-2 text-left sm:grid-cols-3 md:grid-cols-4">
    <div
      v-for="(item, index) in foods"
      class="cursor-pointer rounded border-2 border-l-8 p-2 text-sm"
      :class="selectedFoodItem && selectedFoodItem.id == item.id ? 'border-gray-400' : ''"
      @click="$emit('foodItemSelected', item)"
      :style="{ borderLeftColor: globals.foodCategoryColorMap.get(item.category) }"
    >
      <b>{{ item.name }}</b>
      <span class="ml-2 text-sm text-muted">{{ item.note }}</span>
    </div>
  </div>
</template>
