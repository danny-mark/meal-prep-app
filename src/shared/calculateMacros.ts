import type { JournalEntry } from '@/custom_types/JournalEntry.type'
import type { MacroKey, Macros } from '@/custom_types/Macros.type'
import type { Ingredient } from '@/custom_types/FoodItem.type'

const calculateMacrosPerAmount = (macros: Macros, amount: number): Macros => {
  if (!amount) {
    return macros
  }

  return {
    calories: macros.calories ? Number(((macros.calories / 100) * amount).toFixed(1)) : 0,
    protein: macros.protein ? Number(((macros.protein / 100) * amount).toFixed(1)) : 0,
    fat: macros.fat ? Number(((macros.fat / 100) * amount).toFixed(1)) : 0,
    carbs: macros.carbs ? Number(((macros.carbs / 100) * amount).toFixed(1)) : 0,
    fiber: macros.fiber ? Number(((macros.fiber / 100) * amount).toFixed(1)) : 0
  }
}

const sumMealMacros = (meal: JournalEntry): Macros => {
  let macros: Macros = {
    protein: 0,
    carbs: 0,
    fat: 0,
    fiber: 0,
    calories: 0
  }

  for (const food of meal.contents) {
    for (const m of ['calories', 'protein', 'fat', 'carbs', 'fiber']) {
      macros[m as MacroKey] += food.macros_calculated[m as MacroKey]
    }
  }

  return macros
}

const sumRecipeMacrosPer100 = (ingredients: Ingredient[]): Macros => {
  let totalMacros: Macros = {
    protein: 0,
    carbs: 0,
    fat: 0,
    fiber: 0,
    calories: 0
  }
  let macrosPer100 = totalMacros

  if (!ingredients.length) return macrosPer100

  let totalWeight = 0

  for (const ingredient of ingredients) {
    let ms = calculateMacrosPerAmount(ingredient.macros_per_100, ingredient.amount)

    for (const m of ['calories', 'protein', 'fat', 'carbs', 'fiber']) {
      totalMacros[m as MacroKey] += ms[m as MacroKey]
    }

    totalWeight += ingredient.amount
  }

  for (const m of ['calories', 'protein', 'fat', 'carbs', 'fiber']) {
    macrosPer100[m as MacroKey] = Number(
      ((totalMacros[m as MacroKey] / totalWeight) * 100).toFixed(1)
    )
  }

  return totalMacros
}

export { calculateMacrosPerAmount, sumMealMacros, sumRecipeMacrosPer100 }
