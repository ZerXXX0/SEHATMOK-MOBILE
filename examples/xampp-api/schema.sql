CREATE DATABASE IF NOT EXISTS sehatmok CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sehatmok;

CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(36) PRIMARY KEY,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  avatar_url VARCHAR(255) NULL,
  role VARCHAR(50) NOT NULL DEFAULT 'user',
  status VARCHAR(50) NOT NULL DEFAULT 'active',
  age INT NULL,
  weight DECIMAL(6,2) NULL,
  height DECIMAL(6,2) NULL,
  activity_level VARCHAR(50) NULL,
  target_calories INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS fridge_items (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  name VARCHAR(120) NOT NULL,
  category VARCHAR(80) NOT NULL,
  quantity DECIMAL(10,2) NOT NULL DEFAULT 0,
  unit VARCHAR(30) NOT NULL,
  expiry_date DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_fridge_user_id (user_id)
);

CREATE TABLE IF NOT EXISTS recipes (
  id VARCHAR(36) PRIMARY KEY,
  name VARCHAR(180) NOT NULL,
  description TEXT NULL,
  image_url VARCHAR(255) NULL,
  ingredients JSON NOT NULL,
  instructions JSON NOT NULL,
  preparation_time INT NULL,
  cooking_time INT NULL,
  servings INT NULL,
  difficulty VARCHAR(50) NULL,
  nutrition JSON NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
