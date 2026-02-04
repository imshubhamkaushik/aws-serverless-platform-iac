import React from "react";
import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import Users from "./components/Users";
import Products from "./components/Products";

function App() {
  return (
    <Router>
      <div style={{ textAlign: "center", padding: "20px" }}>
        <h1>🛒 Catalogix</h1>
        <nav>
          <Link to="/users" style={{ margin: "10px" }}>
            Users
          </Link>
          <Link to="/products" style={{ margin: "10px" }}>
            Products
          </Link>
        </nav>
        <Routes>
          <Route path="/users" element={<Users />} />
          <Route path="/products" element={<Products />} />
          <Route path="/" element={<h2>Welcome to Catalogix!</h2>} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
