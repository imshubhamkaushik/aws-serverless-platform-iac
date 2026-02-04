import axios from "axios";

// Base URL for backend APIs
// - In Docker/K8s behind a reverse proxy, you can keep this as ""
// - For local development, set REACT_APP_API_BASE_URL in .env file
// const API_BASE = process.env.REACT_APP_API_BASE_URL || "";
const API_BASE = ""; //same origin

const USER_API_BASE = `${API_BASE}/api/users`;
const PRODUCT_API_BASE = `${API_BASE}/api/products`;

let currentUserId = null;

// --------USER APIs--------

export const loginUser = async (credentials) => {
  const res = await axios.post(`${USER_API_BASE}/login`, credentials);
  currentUserId = res.data.id; // Store logged-in user ID
  return res.data;
};

export const getUsers = async () => {
  const res = await axios.get(`${USER_API_BASE}`);
  return res.data;
};

export const createUser = async (user) => {
  const res = await axios.post(`${USER_API_BASE}/register`, user);
  return res.data;
};

export const deleteUser = async (id) => {
  const res = await axios.delete(`${USER_API_BASE}/${id}`);
  console.log("Deleted user response:", res.status, res.data);
  return res.data;
};

// --------PRODUCT APIs--------

export const getProducts = async () => {

  if (!currentUserId) {
    throw new Error("User not logged in");
  }

  const res = await axios.get(PRODUCT_API_BASE, {
    headers: {
      'X-USER-ID': currentUserId,
    },
  });
  return res.data;
};

export const createProduct = async (product) => {
  if (!currentUserId) {
    throw new Error("User not logged in");
  }

  const res = await axios.post(PRODUCT_API_BASE, product, {
    headers: {
      'X-USER-ID': currentUserId,
    },
  });
  return res.data;
};

export const deleteProduct = async (id) => {
  if (!currentUserId) {
    throw new Error("User not logged in");
  }

  const res = await axios.delete(`${PRODUCT_API_BASE}/${id}`, {
    headers: {
      'X-USER-ID': currentUserId,
    },
  });
  console.log("Deleted product response:", res.status, res.data);
  return res.data;
};
