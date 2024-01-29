<script setup lang="ts">
import { supabase } from '@/supabase'
import { ref, watch, computed } from 'vue'
import type { Ref } from 'vue'
import Dialog from './Dialog.vue'
import { useToastStore } from '@/stores/toast'
import type { JournalEntry, JournalFood } from '@/custom_types/JournalEntry.type'
import type { FoodItem, Ingredient } from '@/custom_types/FoodItem.type'
import type { Macros, MacroKey } from '@/custom_types/Macros.type'
import { useGlobalStore } from '@/stores/globalStatic'
import { sumRecipeMacrosPer100 } from '@/shared/calculateMacros'
import AddJournalFoodDialog from '../dialogs/AddJournalFoodDialog.vue'
import EditJournalFoodDialog from '../dialogs/EditJournalFoodDialog.vue'
import IngredientsList from '../IngredientsList.vue'

const globals = useGlobalStore()
const toastStore = useToastStore()

const emit = defineEmits(['closed', 'foodsUpdated'])

const props = defineProps<{
  isOpen: boolean
  recipeEditorItem: FoodItem | null
}>()

interface RecipeFormType
  extends Omit<
    FoodItem,
    'created_at' | 'last_used_at' | 'macros_per_100' | 'is_recipe' | 'is_favorite'
  > {}
let recipeFormDefault: RecipeFormType = {
  name: '',
  note: '',
  recipe_contents: [],
  category: 'complete meal'
}

const macrosCalculated: Ref<Macros | null> = computed(() => {
  if (!props.recipeEditorItem) return null
  return sumRecipeMacrosPer100(recipeForm.value.recipe_contents)
})

const recipeForm: Ref<RecipeFormType> = ref({
  ...recipeFormDefault
})

const addFoodDialogState: Ref<{
  isOpen: boolean
}> = ref({
  isOpen: false
})
const editFoodDialogState: Ref<{
  editedFoodIndex?: number
  isOpen: boolean
}> = ref({
  isOpen: false
})

watch(
  () => props.recipeEditorItem,
  (recipe: FoodItem | null) => {
    if (!recipe) recipeForm.value = { ...recipeFormDefault }
    else recipeForm.value = { ...recipe }
  }
)

const addFoodToRecipe = async (addedFood: Ingredient) => {
  recipeForm.value.recipe_contents.push({ ...addedFood })
}

const updateRecipeIngredient = async (updatedFood: Ingredient) => {
  let index = editFoodDialogState.value.editedFoodIndex
  if (!recipeForm.value || index == undefined) {
    return
  }
  let newContents = recipeForm.value.recipe_contents
  newContents[index] = { ...updatedFood }
  recipeForm.value.recipe_contents = newContents
}

const upsertRecipe = async () => {
  let { recipe_contents, ...restOfRecipeForm } = recipeForm.value

  let data,
    error

    // Upsert the recipe
  ;({ data, error } = await supabase
    .from('food_items')
    .upsert({
      ...restOfRecipeForm,
      macros_per_100: { ...macrosCalculated.value },
      is_recipe: true,
      last_used_at: new Date()
    })
    .select()
    .single())

  if (error) {
    let message = error.message
    if (message.includes('unique constraint "food_items_name_key"')) {
      message = 'A food item with this name already exists.'
    }

    toastStore.showErrorToast(message)
    return
  }

  const recipeID = data.id

  // Delete old ingredients

  ;({ error } = await supabase.from('recipe_contents').delete().eq('recipe_food_id', recipeID))

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  // Add new ingredients

  let pivotData = []
  for (const ingredient of recipe_contents) {
    pivotData.push({
      recipe_food_id: recipeID,
      ingredient_food_id: ingredient.id,
      amount: ingredient.amount
    })
  }
  ;({ error } = await supabase.from('recipe_contents').insert(pivotData))

  if (error) {
    toastStore.showErrorToast(error.message)
    return
  }

  emit('closed')
  emit('foodsUpdated')

  toastStore.showToast({ title: 'Recipe Saved' })

  recipeForm.value = {
    ...recipeFormDefault
  }
}

const removeFoodFromRecipe = async (indexToRemove: number) => {
  if (!confirm('Delete food from recipe?')) return
  recipeForm.value.recipe_contents = recipeForm.value.recipe_contents.filter(
    (_, i) => i !== indexToRemove
  )
}

const deleteRecipe = async () => {
  if (!props.recipeEditorItem) return

  if (!confirm(`Are you sure you want to delete ${props.recipeEditorItem.name}?`)) return

  const { data, error } = await supabase
    .from('food_items')
    .delete()
    .eq('id', props.recipeEditorItem.id)

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
      <h3 class="text-xl font-bold">{{ recipeEditorItem ? 'Edit Recipe' : 'Add Recipe' }}</h3>
    </template>

    <template #body>
      <form @submit.prevent="upsertRecipe">
        <div class="grid grid-cols-2 gap-2">
          <div class="mb-4 text-left">
            <label class="block text-sm text-gray-700">
              <b>Name</b>
              <input
                required
                class="form-input mt-2"
                v-model.trim="recipeForm.name"
                placeholder="Whole Egg"
              />
            </label>
          </div>

          <div class="mb-4 text-left">
            <label class="block text-sm text-gray-700">
              <b>Category</b>
              <select required class="form-select mt-2" v-model="recipeForm.category">
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
                v-model.trim="recipeForm.note"
                placeholder="(Optional)"
              />
            </label>
          </div>

          <div class="col-span-2 mb-4 text-left" v-if="macrosCalculated">
            <div class="text-left">
              <b class="block text-sm text-gray-700">Macros per 100g</b>
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

          <div class="col-span-2 mb-4 text-left">
            <b class="block text-sm text-gray-700">Foods</b>

            <IngredientsList
              :foods="recipeForm.recipe_contents"
              @food-clicked="
                (index: number) => {
                  editFoodDialogState = {
                    isOpen: true,
                    editedFoodIndex: index
                  }
                }
              "
              @trash-clicked="removeFoodFromRecipe"
              @add-clicked="() => (addFoodDialogState = { isOpen: true })"
            ></IngredientsList>
          </div>
        </div>

        <button class="btn btn-primary btn-block mt-6" type="submit">Save Recipe</button>
      </form>

      <button v-if="recipeEditorItem" class="mt-4 px-6 py-2 text-danger" @click="deleteRecipe">
        Delete
      </button>
    </template>
  </Dialog>

  <AddJournalFoodDialog
    :is-open="addFoodDialogState.isOpen"
    mode="foods"
    @closed="addFoodDialogState.isOpen = false"
    @foodAdded="addFoodToRecipe"
  />

  <EditJournalFoodDialog
    :is-open="editFoodDialogState.isOpen"
    :food="
      (() => {
        if (
          !editFoodDialogState.isOpen ||
          !recipeForm.recipe_contents.length ||
          editFoodDialogState.editedFoodIndex == undefined
        ) {
          return undefined
        }

        // Transform the foodItem into journalFood
        let food = recipeForm.recipe_contents[editFoodDialogState.editedFoodIndex] as Ingredient

        let jf = {} as JournalFood

        jf.id = food.id as number
        jf.name = food.name
        jf.note = food.note
        jf.category = food.category
        jf.amount = food.amount
        jf.macros_per_100 = food.macros_per_100
        jf.macros_calculated = food.macros_per_100

        return jf
      })()
    "
    @closed="editFoodDialogState.isOpen = false"
    @saved="updateRecipeIngredient"
  />
</template>
