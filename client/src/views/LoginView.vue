<script setup lang="ts">
import { ref, onMounted } from 'vue'

const email = ref('')
const password = ref('')

const onelogin = {
  authority: 'https://pieterjandemuinck-dev.onelogin.com/oidc/2',
  client_id: 'c5db18d0-c60c-013a-d2cc-0a553c501afd210618',
  redirect_uri: `${window.location.origin}/oauth/callback`,
  response_type: 'id_token token',
  scope: 'openid profile email groups params',

  filterProtocolClaims: true,
  loadUserInfo: true,
}


onMounted(() => {
  //redirectToOneLogin()
})


</script>

<template>
  <div class="login-box">
    <h2 class="">Welcome to DBS Live</h2>
    <button class="onelogin-button">Sign in using OneLogin</button>
    <div class="divider"></div>
    <form class="w-80 mt-3" @submit.prevent="login(email, password)">
      <AppInput class="block mt-3" v-model="email" name="email" type="email" required>Email</AppInput>
      <AppInput class="block mt-3" v-model="password" name="password" type="password" required
      >Password</AppInput
      >
      <AppButton class="login-button" type="submit">Login</AppButton>
    </form>
  </div>


</template>

<style>


.login-box > h2 {
  margin: 5%;
  text-align: center;
}

  .divider {
    margin-top: 5%;
    margin-bottom: 5%;
    border-top: 1px dashed black;
  }

  .login-box {
    position: absolute;
    border: 1px solid gray;
    width: 30%;
    margin-top: 10%;
    left: 35%;
    padding: 2%;
    background-color: lightsteelblue;
  }

  .onelogin-button {
    display: block;
    margin: auto;
    padding: 2%;
  }

  .onelogin-button:hover {
    cursor: pointer;
  }

  .login-button {
    display: block;
    margin-top: 5%;
  }

  .login-button:hover {
    cursor: pointer;
  }

</style>
