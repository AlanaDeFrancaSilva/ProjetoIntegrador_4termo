/* ===========================================
   🟦 GET Usuário Logado ( /auth/users/me/ )
=========================================== */
export const getCurrentUser = async () => {
  if (!process.client) return null;

  const token = localStorage.getItem("auth_token");
  if (!token) throw new Error("Token não encontrado");

  const response = await fetch("http://localhost:8001/api/auth/users/me/", {
    headers: {
      "Content-Type": "application/json",
      Authorization: `Token ${token}`,
    },
  });

  if (!response.ok) {
    const err = await response.text();
    console.error("❌ Erro ao buscar usuário logado:", err);
    throw new Error("Erro ao buscar usuário logado");
  }

  return await response.json();
};



/* ===========================================
   🟩 GET LISTA DE USUÁRIOS (COM FILTRO OPCIONAL)
   Exemplo:
     getUsers({ role: "tecnico" })
=========================================== */
export const getUsers = async (params?: Record<string, any>) => {
  if (!process.client) return [];

  const token = localStorage.getItem("auth_token");

  console.log("🔑 TOKEN LOCALSTORAGE:", token);

  if (!token) {
    console.error("❌ Token NÃO encontrado! Requisição não será autenticada.");
    throw new Error("Token não encontrado");
  }

  // Monta a query string
  const query = new URLSearchParams(params || {}).toString();
  const url = `http://localhost:8001/api/auth/users/?${query}`;

  console.log("🌍 GET USERS →", url);

  const response = await fetch(url, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Token ${token}`,
    },
  });

  console.log("📡 STATUS GET USERS:", response.status);

  if (response.status === 401) {
    console.error("❌ FALHA: Backend recusou o token (401 Unauthorized)");
  }

  if (!response.ok) {
    const err = await response.text();
    console.error("❌ Erro backend ao buscar usuários:", err);
    throw new Error("Erro ao buscar usuários");
  }

  return await response.json();
};



/* ===========================================
   🟧 CREATE USER
=========================================== */
export const createUser = async (payload: any) => {
  if (!process.client) return null;

  const token = localStorage.getItem("auth_token");
  if (!token) throw new Error("Token não encontrado");

  const response = await fetch("http://localhost:8001/api/auth/users/", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Token ${token}`,
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const error = await response.json();
    console.error("❌ Erro ao criar usuário:", error);
    throw new Error(JSON.stringify(error));
  }

  return await response.json();
};



/* ===========================================
   🟨 UPDATE USER
=========================================== */
export const updateUser = async (id: number, payload: any) => {
  if (!process.client) return null;

  const token = localStorage.getItem("auth_token");
  if (!token) throw new Error("Token não encontrado");

  const response = await fetch(
    `http://localhost:8001/api/auth/users/${id}/`,
    {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Token ${token}`,
      },
      body: JSON.stringify(payload),
    }
  );

  if (!response.ok) {
    const error = await response.json();
    console.error("❌ Erro ao atualizar usuário:", error);
    throw new Error(JSON.stringify(error));
  }

  return await response.json();
};
