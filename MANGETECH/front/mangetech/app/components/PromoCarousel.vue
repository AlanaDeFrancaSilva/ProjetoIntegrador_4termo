<template>
  <div class="promo-carousel" @mouseenter="pauseAutoPlay" @mouseleave="resumeAutoPlay">
    
    <!-- Botão Anterior -->
    <button class="nav-btn left" @click="prevSlide">‹</button>

    <!-- CONTEÚDO DO SLIDE -->
    <transition name="fade-slide" mode="out-in">
      <div class="carousel-content" :key="currentSlide">
        <div class="text">
          <h2>{{ slides[currentSlide].title }}</h2>
        </div>
        <div class="image">
          <img :src="slides[currentSlide].image" alt="Banner" />
        </div>
      </div>
    </transition>

    <!-- Botão Próximo -->
    <button class="nav-btn right" @click="nextSlide">›</button>

    <!-- Dots Navegação -->
    <div class="dots">
      <span
        v-for="(slide, index) in slides"
        :key="index"
        :class="['dot', { active: currentSlide === index }]"
        @click="setSlide(index)"
      ></span>
    </div>

  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from 'vue'

const slides = [
  {
    id: 1,
    title: "SUA CENTRAL DE CHAMADOS RÁPIDA E ORGANIZADA",
    image: "@/assets/images/telateste1.png",
  },
  {
    id: 2,
    title: "AGILIDADE E CONTROLE NO SEU COMPUTADOR",
    image: "/assets/images/mockupdesktop.png",
  }
]

const currentSlide = ref(0)
let intervalId: any = null

const nextSlide = () => {
  currentSlide.value = (currentSlide.value + 1) % slides.length
}

const prevSlide = () => {
  currentSlide.value = (currentSlide.value - 1 + slides.length) % slides.length
}

const setSlide = (index: number) => {
  currentSlide.value = index
}

const startAutoPlay = () => {
  intervalId = setInterval(nextSlide, 5000)
}

const pauseAutoPlay = () => clearInterval(intervalId)
const resumeAutoPlay = () => startAutoPlay()

onMounted(startAutoPlay)
onBeforeUnmount(pauseAutoPlay)
</script>

<style scoped lang="scss">
.promo-carousel {
  grid-column: span 2;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #0a0f25, #10182c, #1a233d);
  border-radius: 20px;
  padding: 40px 50px;
  min-height: 260px;
  overflow: hidden;
  box-shadow: 0 8px 28px rgba(0,0,0,0.25);
}

.carousel-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  gap: 40px;
}

.text h2 {
  font-size: 2rem;
  font-weight: 700;
  color: #f9fafb;
  max-width: 460px;
  line-height: 1.4;
}

.image img {
  max-width: 350px;
  width: 100%;
  filter: drop-shadow(0 10px 25px rgba(0,0,0,0.5));
  transition: transform 0.3s ease;
}

.image img:hover {
  transform: scale(1.03);
}

/* Botões navegação */
.nav-btn {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(255,255,255,0.08);
  border: none;
  color: #ffffff;
  font-size: 2rem;
  padding: 10px 16px;
  border-radius: 50%;
  cursor: pointer;
  transition: all 0.3s ease;
}

.nav-btn:hover {
  background: rgba(255,255,255,0.25);
  transform: scale(1.1) translateY(-50%);
}

.nav-btn.left { left: 14px; }
.nav-btn.right { right: 14px; }

/* Dots indicadores */
.dots {
  position: absolute;
  bottom: 14px;
  display: flex;
  gap: 8px;
}

.dot {
  width: 10px;
  height: 10px;
  background-color: rgba(255,255,255,0.4);
  border-radius: 50%;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

.dot.active {
  background-color: #ffffff;
}

/* Animação suave */
.fade-slide-enter-active,
.fade-slide-leave-active {
  transition: all 0.6s ease;
}

.fade-slide-enter-from { opacity: 0; transform: translateX(40px); }
.fade-slide-leave-to { opacity: 0; transform: translateX(-40px); }

/* Responsivo */
@media (max-width: 900px) {
  .carousel-content {
    flex-direction: column;
    text-align: center;
  }

  .image img { max-width: 260px; }

  .text h2 { font-size: 1.4rem; }
}
</style>
