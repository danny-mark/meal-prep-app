import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'

const app = createApp(App)

app.config.globalProperties.$foodCategories = [
  // hardcoded food categories for now
  'protein',
  'carb',
  'fat',
  'meal',
  'supplement',
  'snack',
  'desert',
  'sauce'
]

app.use(createPinia())

app.mount('#app')
