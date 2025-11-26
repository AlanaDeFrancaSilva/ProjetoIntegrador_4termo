<template>
  <div class="documentacao-container">
    <h1 class="page-title">Documentação do Projeto Integrador IV</h1>

    <div class="doc-section" v-for="section in sections" :key="section.title">
      <h2 class="section-title">{{ section.title }}</h2>

      <p v-if="section.text">{{ section.text }}</p>

      <ul v-if="section.items">
        <li v-for="(item, index) in section.items" :key="index">{{ item }}</li>
      </ul>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: 'dashboard-layout'
})

const sections = [
  {
    title: "1. Objetivo da Unidade Curricular",
    text: "Desenvolver capacidades técnicas e socioemocionais relacionadas às vulnerabilidades em aplicações mobile, propondo soluções para inconsistências."
  },
  {
    title: "2. Capacidades Técnicas",
    items: [
      "Definir requisitos de segurança da informação.",
      "Desenvolver aplicações mobile com boa experiência do usuário.",
      "Programar aplicações web com backend.",
      "Coordenar projetos de integração computacional.",
      "Desenvolver plano de negócio inovador.",
      "Aplicar conhecimentos da eletiva II."
    ]
  },
  {
    title: "3. Capacidades Socioemocionais",
    items: [
      "Agir com ética e responsabilidade.",
      "Trabalhar em equipe de forma colaborativa.",
      "Expressar-se de modo crítico e fundamentado.",
      "Ser proativo na resolução de problemas."
    ]
  },
  {
    title: "4. Requisitos Funcionais da Aplicação",
    items: [
      "API REST com autenticação e autorização.",
      "Níveis de usuário com permissões.",
      "Cadastro de ambientes e responsáveis.",
      "Cadastro de ativos e tarefas com fotos e urgência.",
      "Dashboard com filtros e indicadores.",
      "Status completo de chamados.",
      "Notificações automáticas por e-mail.",
      "App mobile com leitura de QR Code.",
      "Práticas de Cibersegurança aplicadas."
    ]
  },
  {
    title: "5. Sprint I – Entregas Formativas",
    items: [
      "Protótipo UI/UX no Figma.",
      "Modelagem UML completa.",
      "CRUD inicial backend.",
      "Frontend com criação de chamados.",
      "Infraestrutura com Terraform.",
      "Configuração inicial de segurança."
    ]
  },
  {
    title: "6. Sprint II – Entregas Somativas",
    items: [
      "Autenticação JWT.",
      "Login e cadastro no frontend.",
      "Regras de acesso por nível.",
      "Cancelar chamados após andamento.",
      "Dashboards com gráficos.",
      "Deploy completo.",
      "Configurações avançadas de segurança."
    ]
  },
  {
    title: "7. Situação Problema – Resumo",
    text: "A MANGE_TECH enfrenta dificuldades na gestão de chamados e ativos industriais. A solução visa melhorar suporte, rastreamento e desempenho operacional."
  },
  {
    title: "8. Indicadores Para Análises",
    items: [
      "Chamados abertos, concluídos e atrasados.",
      "Tempo médio de atendimento.",
      "Responsáveis mais eficientes.",
      "Ativos com maior recorrência de falhas."
    ]
  }
]
</script>

<style scoped lang="scss">
/* ===== CONTAINER GERAL ===== */
.documentacao-container {
  max-width: 900px;
  margin: 40px auto;
  padding: 30px;
  background: linear-gradient(180deg, #ffffff, #f9fafc);
  border-radius: 16px;
  box-shadow: 0px 6px 24px rgba(0, 0, 0, 0.08);
  font-family: 'Inter', sans-serif;
  color: #1f2937;
}

/* ===== TÍTULO PRINCIPAL ===== */
.page-title {
  text-align: center;
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 40px;
  color: #0a1635;
  text-transform: uppercase;
  letter-spacing: 1px;
  position: relative;
}

.page-title::after {
  content: "";
  display: block;
  width: 90px;
  height: 3px;
  background: #3b82f6;
  margin: 12px auto 0;
  border-radius: 2px;
}

/* ===== SEÇÕES ===== */
.doc-section {
  padding: 26px;
  margin-bottom: 22px;
  border-radius: 14px;
  background: #ffffff;
  box-shadow: 0 3px 14px rgba(0, 0, 0, 0.05);
  transition: transform 0.25s ease;
}

.doc-section:hover {
  transform: translateY(-4px);
}

/* ===== TÍTULO DAS SEÇÕES ===== */
.section-title {
  font-size: 1.3rem;
  font-weight: 600;
  color: #1e3a8a;
  margin-bottom: 12px;
}

/* ===== LISTAS ===== */
ul {
  margin-left: 20px;
}

ul li {
  margin-bottom: 6px;
  line-height: 1.5;
  position: relative;
  padding-left: 10px;
  color: #374151;
}

ul li::before {
  content: "•";
  position: absolute;
  left: -10px;
  color: #3b82f6;
}
</style>
