<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import SocialSignIn from './components/SocialSignIn.vue'
import IconLogo from './components/icons/IconLogo.vue'
import Journal from './components/pages/Journal.vue'
import Foods from './components/pages/Foods.vue'
import Meals from './components/pages/Meals.vue'
import Targets from './components/pages/Targets.vue'
import Account from './components/pages/Account.vue'
import Dropdown from './components/Dropdown.vue'
import Toast from './components/Toast.vue'
import Datepicker from './components/Datepicker.vue'
import { supabase } from '@/supabase'
import { useSessionStore } from '@/stores/session'

const routes: { [key: string]: any } = {
  journal: Journal,
  foods: Foods,
  meals: Meals,
  targets: Targets,
  account: Account
}

const currentPath = ref(window.location.hash)

window.addEventListener('hashchange', () => {
  currentPath.value = window.location.hash
})

const currentView = computed(() => {
  return routes[currentPath.value.slice(1) || 'journal'] || Journal
})

const session = useSessionStore()

onMounted(() => {
  supabase.auth.getSession().then(({ data }) => {
    session.setUser(data.session)
  })

  supabase.auth.onAuthStateChange((_, _session) => {
    session.setUser(_session)
  })
})
</script>

<template>
  <div v-if="session.user" class="w-full">
    <!-- App -->

    <nav class="mb-12 border-b p-3">
      <div class="container flex justify-between">
        <div>
          <Dropdown
            :options="['Journal', 'Foods', 'Meals', 'Targets', 'Account']"
            :current-view="currentView"
          />
        </div>

        <div>
          <Datepicker v-if="currentView == Journal" />
        </div>
      </div>
    </nav>

    <main class="container p-4 text-center">
      <component :is="currentView" />
    </main>
  </div>

  <div v-else class="w-full">
    <!-- Guest website -->

    <main class="centered container flex h-screen flex-col">
      <div class="mb-8 flex">
        <div class="h-12 w-12"><IconLogo /></div>
        <h1 class="ml-3 text-5xl">Meal Plan App</h1>
      </div>

      <ul class="mb-10 grid grid-cols-2 p-2 md:grid-cols-3">
        <li class="border-gray centered w-30 m-2 flex rounded border-2 p-4 md:m-4 md:w-60 md:p-6">
          Keep a daily food journal and follow your progress.
        </li>
        <li class="border-gray centered w-30 m-2 flex rounded border-2 p-4 md:m-4 md:w-60 md:p-6">
          Track calories, protein, carb and fat content.
        </li>
        <li class="border-gray centered w-30 m-2 flex rounded border-2 p-4 md:m-4 md:w-60 md:p-6">
          Set goals for daily macros, as well as per-meal macros.
        </li>
        <li class="border-gray centered w-30 m-2 flex rounded border-2 p-4 md:m-4 md:w-60 md:p-6">
          Create custom foods or select from the spoontacular API.
        </li>
        <li class="border-gray centered w-30 m-2 flex rounded border-2 p-4 md:m-4 md:w-60 md:p-6">
          Add barcodes to saved foods to quickly find them in the future.
        </li>
        <li class="border-gray centered w-30 m-2 flex rounded border-2 p-4 md:m-4 md:w-60 md:p-6">
          Set recurring meals to automatically add them to the journal every day.
        </li>
      </ul>

      <SocialSignIn provider="google" />
      <SocialSignIn provider="github" />
    </main>
  </div>

  <Toast />
</template>
