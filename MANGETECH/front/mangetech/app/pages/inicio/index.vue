<template>
  <div class="dashboard-container">
    <main class="main-content">

      <!-- GRID SUPERIOR -->
      <div class="top-cards">
        <div class="card chamados-card">
          <h3>Total de Chamados</h3>
          <p class="value">{{ totalChamados }}</p>
          <p class="subtitle">Registrados no sistema</p>
        </div>

        <div class="card map-card">
          <img :src="mapBrasil" class="map-image" alt="Mapa do Brasil" />
        </div>
      </div>

      <!-- BANNER CARROSSEL -->
      <div class="card promo-carousel">
        <div v-for="(slide, index) in slides"
             :key="index"
             class="carousel-slide"
             :class="{ active: index === currentSlide }">

          <div class="text">
            <h2>{{ slide.title }} <span>{{ slide.highlight }}</span></h2>
          </div>
          <div class="device">
            <img :src="slide.image" />
          </div>
        </div>

        <div class="carousel-indicators">
          <span v-for="(slide, index) in slides"
                :key="index"
                @click="currentSlide = index"
                :class="{ active: index === currentSlide }"></span>
        </div>
      </div>

    </main>
  </div>
</template>


<script setup lang="ts">
definePageMeta({ layout: 'dashboard-layout' })

import { ref, onMounted, onUnmounted } from 'vue'

// Imagens
import mapBrasil from '@/assets/images/map.png'
import celularImage from '@/assets/images/telateste1.png'
import computadorImage from '@/assets/images/comp.png'

// ⭐ TOTAL REAL DE CHAMADOS
const totalChamados = ref(0)

async function carregarTotalChamados() {
  try {
    const token = process.client ? localStorage.getItem("auth_token") : null
    if (!token) {
      console.error("Token não encontrado")
      return
    }

    const response = await fetch("http://localhost:8001/api/task/", {
      headers: {
        "Authorization": `Token ${token}`,
        "Content-Type": "application/json"
      }
    })

    if (!response.ok) {
      console.error("Erro ao buscar total de chamados")
      return
    }

    const data = await response.json()

    // 👉 Total verdadeiro retornado pelo DRF
    totalChamados.value = data.count

  } catch (error) {
    console.error("Erro ao carregar total de chamados:", error)
  }
}


// Carrossel
const slides = ref([
  { title: "SUA CENTRAL DE CHAMADOS", highlight: "RÁPIDA", image: celularImage },
  { title: "ORGANIZAÇÃO EM QUALQUER LUGAR", highlight: "INTELIGENTE", image: computadorImage }
])

const currentSlide = ref(0)
let intervalId: any = null

onMounted(() => {
  carregarTotalChamados()

  intervalId = setInterval(() => {
    currentSlide.value = (currentSlide.value + 1) % slides.value.length
  }, 5000)
})

onUnmounted(() => clearInterval(intervalId))
</script>

<style scoped lang="scss">
/* ———— TODO SEU CSS (NÃO ALTEREI NADA) ———— */
.dashboard-container {
  display: flex;
  min-height: 100vh;
  background: #f4f6fa;
  font-family: 'Inter', sans-serif;
}

.main-content {
  flex: 1;
  padding: 2.2rem 3rem;
}

.top-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 28px;
  margin-bottom: 32px;
}

.card {
  background: #fff;
  border-radius: 18px;
  padding: 28px;
  box-shadow: 0px 6px 22px rgba(0, 0, 0, 0.08);
  transition: transform 0.25s ease, box-shadow 0.25s ease;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 10px 28px rgba(0, 0, 0, 0.15);
  }
}

.chamados-card {
  background:  #1e293b;
  color: #f1f5f9;
  text-align: center;
  padding: 40px;
  border-radius: 24px;
  box-shadow: 0 12px 28px rgba(0,0,0,0.22), inset 0 0 18px rgba(255,255,255,0.04);
  backdrop-filter: blur(6px);
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  min-height: 220px;

  h3 {
    font-size: 1.15rem;
    font-weight: 500;
    opacity: 0.9;
    margin-bottom: 10px;
  }

  .value {
    font-size: 3.5rem;
    font-weight: 800;
    margin: 8px 0;
    color: #ffffff;
    text-shadow: 0 3px 10px rgba(0,0,0,0.4);
  }

  .subtitle {
    font-size: 0.95rem;
    opacity: 0.85;
    margin-top: 4px;
  }
}

.map-card {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 18px;
  min-height: 230px;
  border-radius: 22px;

  .map-image {
    max-width: 85%;
    opacity: 0.9;
    filter: drop-shadow(0 6px 16px rgba(0,0,0,0.15));
    transition: transform 0.3s ease;
  }

  &:hover .map-image {
    transform: scale(1.03);
  }
}

.promo-carousel {
  margin-top: 15px;
  border-radius: 24px;
  height: 340px;
  position: relative;
  overflow: hidden;
  background:  #1e293b;
  box-shadow: 0 10px 32px rgba(0,0,0,0.18);
}

.carousel-slide {
  position: absolute;
  width: 100%;
  height: 100%;
  display: flex;
  padding: 50px 60px;
  justify-content: space-between;
  align-items: center;
  opacity: 0;
  transform: translateX(60px);
  transition: all 0.8s ease;

  &.active {
    opacity: 1;
    transform: translateX(0);
  }

  .text h2 {
    font-size: 2.3rem;
    font-weight: 700;
    color: white;
    max-width: 500px;
  }

  span {
    color: #4f7df3;
  }

  .device img {
    max-width: 380px;
    transform: translateY(-30px);
    filter: drop-shadow(0 12px 32px rgba(0,0,0,0.6));
  }
}

.carousel-indicators {
  position: absolute;
  bottom: 16px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 8px;

  span {
    width: 12px;
    height: 12px;
    background: #64748b;
    border-radius: 50%;
    transition: 0.3s ease;
    cursor: pointer;

    &.active {
      background: white;
      transform: scale(1.2);
    }
  }
}
</style>
