import type { JournalEntry } from '@/custom_types/JournalEntry.type'
import type { MacroKey, Macros } from '@/custom_types/Macros.type'

const calculateMacrosPerAmount = (macros: Macros, amount: number): Macros => {
  if (!amount) {
    return macros
  }

  return {
    calories: Number(((macros.calories / 100) * amount).toFixed(1)),
    protein: Number(((macros.protein / 100) * amount).toFixed(1)),
    fat: Number(((macros.fat / 100) * amount).toFixed(1)),
    carbs: Number(((macros.carbs / 100) * amount).toFixed(1)),
    fiber: Number(((macros.fiber / 100) * amount).toFixed(1))
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

export { calculateMacrosPerAmount, sumMealMacros }
