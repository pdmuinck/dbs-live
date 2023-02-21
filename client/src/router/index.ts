import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'dbs-live',
      component: import('../views/DBSLiveView.vue')
    },
    {
      path: '/login',
      name: 'login',
      component: import('../views/LoginView.vue'),
    },
    {
      path: '/oauth/callback',
      name: 'callback',
      component: import('../views/DBSLiveView.vue'),
      props: route => ({ query: route.query.id_token })
    }
  ]
})

router.beforeEach(async (to) => {

/*
  if (!isAuthenticated.value && to.name !== 'login') {
    return { name: 'login' }
  }

  if (isAuthenticated.value && to.name === 'login') {
    return { name: 'dbs-live' }
  }


 */


})

export default router
