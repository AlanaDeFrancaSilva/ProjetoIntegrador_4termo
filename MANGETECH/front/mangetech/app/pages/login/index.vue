<template>
  <div class="login-container">
    <div class="login-image"></div>
    <div class="login-form-container">
      <div class="logo">
        <img src="@/assets/images/logoAzul.png" alt="Logo" />
      </div>

      <div class="login-box">
        <h2>Acesse o portal</h2>
        <p>Entre usando seu e-mail e senha cadastrados.</p>
        <form @submit.prevent="login">
          <input
            type="email"
            v-model="email"
            placeholder="E-MAIL"
            required
            aria-label="Email"
          />
          <input
            type="password"
            v-model="password"
            placeholder="SENHA"
            required
            aria-label="Senha"
          />
          <button type="submit" class="btn-login">Entrar</button>
        </form>
      </div>

      <div class="signup-box">
        <p>Ainda não tem uma conta?</p>
        <NuxtLink to="/signup" class="btn-signup">Criar conta</NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'login-layout',
})

import { ref } from 'vue'
import { useRouter } from 'vue-router'

const email = ref('')
const password = ref('')
const router = useRouter()

async function login() {
  try {
    const response = await fetch('http://localhost:8001/api/auth/token/login/', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: email.value,
        password: password.value
      })
    })

    if (!response.ok) {
      throw new Error('Erro no login: ' + response.statusText)
    }

    const data = await response.json()
    console.log('Resposta do login:', data)

    if (data.auth_token) {
      localStorage.setItem('auth_token', data.auth_token)
      alert('Login bem sucedido!')
      router.push('/inicio') // redireciona 
    } else {
      alert('Token não recebido no login')
    }
  } catch (error) {
    console.error('Erro no login:', error)
    alert('Falha ao fazer login: ' + error.message)
  }
}
</script>





<style scoped lang="scss">
.login-container {
  display: flex;
  min-height: 100vh;

  /* Imagem na lateral esquerda */
  .login-image {
    flex: 1;
    background-color: #0883ff;
    background-image: url('~/assets/images/fundo.png');
    background-size: cover;
    background-position: center;
  }

  .login-form-container {
    flex: 0.45;
    background-color: white;
    padding: 30px;
    border-radius: 10px;
    box-shadow: 0 4px 6px rgba(255, 0, 0, 0.1);
    margin-top: 100px;
    display: flex;
    flex-direction: column;
    align-items: center;

    .logo img {
      width: 260px;
      margin-bottom: 20px;
    }

    .login-box,
    .signup-box {
      width: 100%;
      margin-bottom: 20px;
    }

    /* ------------ LOGIN BOX ------------ */
    .login-box {
      background-color: #f9f9f9;
      padding: 20px;
      border-radius: 10px;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);

      h2 {
        font-size: 1.5rem;
        margin-bottom: 10px;
        color: #0d1224;
      }

      p {
        font-size: 1rem;
        color: #727272;
        margin-bottom: 15px;
      }

      input {
        width: 100%;
        padding: 12px;
        margin-bottom: 20px;
        border: 1px solid #e2e7ef;
        border-radius: 8px;
        font-size: 1rem;

        background-color: #ffffff !important;
        color: #0d1224 !important;
      }

      /* Placeholder */
      input::placeholder {
        color: #8f8f8f !important;
      }

      /* Autofill Chrome corrige o fundo cinza */
      input:-webkit-autofill,
      input:-webkit-autofill:hover,
      input:-webkit-autofill:focus {
        -webkit-box-shadow: 0 0 0px 1000px #ffffff inset !important;
        -webkit-text-fill-color: #0d1224 !important;
      }

      .btn-login {
        width: 100%;
        padding: 12px;
        background-color: #0d1224;
        color: white;
        border: none;
        border-radius: 8px;
        font-size: 1rem;
        font-weight: 600;
        cursor: pointer;
        transition: background-color 0.3s;

        &:hover {
          background-color: #00076d;
        }
      }
    }

    /* ------------ SIGNUP BOX ------------ */
    .signup-box {
      text-align: center;

      p {
        font-size: 0.95rem;
        color: #727272;
        margin-bottom: 10px;
      }

      .btn-signup {
        display: inline-block;
        width: 100%;
        padding: 12px;
        background-color: #0d1224;
        color: white;
        border: none;
        border-radius: 8px;
        font-size: 1rem;
        font-weight: 600;
        text-decoration: none;
        cursor: pointer;
        transition: background-color 0.3s;

        &:hover {
          background-color: #00076d;
        }
      }
    }
  }
}

/* ------------ RESPONSIVO ------------ */
@media (max-width: 768px) {
  .login-container {
    flex-direction: column;

    .login-image {
      display: none;
    }

    .login-form-container {
      width: 100%;
      margin-top: 20px;
    }
  }
}
</style>
