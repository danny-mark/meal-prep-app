import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import Journal from '@/components/pages/Journal.vue'
import Foods from '@/components/pages/Foods.vue'
import Meals from '@/components/pages/Meals.vue'
import Recipes from '@/components/pages/Recipes.vue'
import Targets from '@/components/pages/Targets.vue'
import Account from '@/components/pages/Account.vue'

export const usePageRouterStore = defineStore('router', () => {
  const currentPath = ref(window.location.hash)

  const pageNames: string[] = ['Journal', 'Foods', 'Recipes', 'Meals', 'Targets', 'Account']

  const routes: { [key: string]: any } = {
    journal: Journal,
    foods: Foods,
    recipes: Recipes,
    meals: Meals,
    targets: Targets,
    account: Account
  }

  const currentView = computed(() => {
    return routes[currentPath.value.slice(1) || 'journal'] || Journal
  })

  return { currentPath, currentView, routes, pageNames }
})
