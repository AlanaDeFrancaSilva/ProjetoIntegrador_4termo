/* =========================================== 
   🟦 GET Usuário Logado
=========================================== */
export const getCurrentUser = async () => {
  if (!process.client) return null;

  const token = localStorage.getItem("auth_token");
  if (!token) throw new Error("Token não encontrado");

  const response = await fetch(
    "https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net/api/auth/users/me/",
    {
      headers: {
        "Content-Type": "application/json",
        Authorization: `Token ${token}`,
      },
    }
  );

  if (!response.ok) {
    const error = await response.text();
    console.error("❌ Erro ao buscar usuário logado:", error);
    throw new Error("Erro ao buscar usuário logado");
  }

  return await response.json();
};



/* ===========================================
   🟩 GET LISTA DE USUÁRIOS
=========================================== */
export const getUsers = async (params?: Record<string, any>) => {
  if (!process.client) return [];

  const token = localStorage.getItem("auth_token");

  const query = new URLSearchParams(params || {}).toString();

  const url = `https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net/api/custom-user/?${query}`;

  console.log("📡 GET USERS →", url);

  const headers: any = {
    "Content-Type": "application/json",
  };

  if (token) headers["Authorization"] = `Token ${token}`;

  const response = await fetch(url, {
    method: "GET",
    headers,
  });

  console.log("📡 STATUS USERS:", response.status);

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

  const response = await fetch(
    "https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net/api/custom-user/",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Token ${token}`,
      },
      body: JSON.stringify(payload),
    }
  );

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
    `https://cage-int-cqg3ahh4a4hjbhb4.westus3-01.azurewebsites.net/api/custom-user/${id}/`,
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
